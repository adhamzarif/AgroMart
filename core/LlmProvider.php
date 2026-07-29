<?php
/**
 * LlmProvider
 * ─────────────────────────────────────────────────────────────
 * Strategy-pattern wrapper for Large Language Model APIs.
 *
 * Active provider chosen via .env LLM_PROVIDER:
 *   none       — disabled; AssistantModel falls back to rule-based replies (default)
 *   anthropic  — Anthropic Claude API
 *   openai     — OpenAI chat-completions API
 *
 * RAG (Retrieval-Augmented Generation) pattern:
 *   1. AssistantModel detects intent + fetches real DB data (already happens)
 *   2. We pass user_query + retrieved_data + system_instructions to the LLM
 *   3. The LLM produces a fluent Bangla response grounded in the actual data
 *
 * Cost control:
 *   - Bounded prompt size (we never send arbitrary DB rows — always summarized)
 *   - Bounded max_tokens response
 *   - Per-user daily quota via Cache layer (LLM_DAILY_QUOTA_PER_USER)
 *   - Falls back to rule-based reply if the API fails
 *
 * Safety:
 *   - Never sends user passwords, payment details, or NID
 *   - LLM never invokes tools; it only formats text
 *   - Provider-specific safety_settings respected
 * ─────────────────────────────────────────────────────────────
 */
class LlmProvider {

    const SYSTEM_PROMPT_BN = <<<PROMPT
You are AgroFin Assistant, a helpful agriculture assistant for Bangladeshi farmers, buyers, and agents. Always respond in Bangla (Bengali script) — never English or transliteration — unless the user explicitly writes in English.

Rules:
- Answer using ONLY the data provided in the "Retrieved Data" section. Never invent prices, weather alerts, or loan amounts.
- If the retrieved data is empty, say so politely and suggest alternatives.
- Keep responses concise (2-4 short paragraphs maximum).
- Use simple, rural-friendly Bangla — avoid technical jargon.
- Include the relevant Taka amounts, dates, and numbers from the data.
- End with one helpful next-step suggestion when natural.
- Use emojis sparingly (1-2 per response, only when they aid clarity).
- Never ask the user for personal information.
PROMPT;

    /** Is LLM enabled and properly configured? */
    public static function isAvailable() {
        $provider = Env::get('LLM_PROVIDER', 'none');
        if ($provider === 'none' || $provider === '') return false;
        return !empty(Env::get('LLM_API_KEY', ''));
    }

    /**
     * Generate a response. Returns:
     *   ['ok'=>bool, 'response'=>string, 'tokens_used'=>int, 'cost_estimate'=>float, 'error'=>string|null]
     *
     * On failure, caller should fall back to rule-based.
     */
    public static function generate($userQuery, $retrievedData, $userContext = []) {
        $provider = Env::get('LLM_PROVIDER', 'none');
        if (!self::isAvailable()) {
            return ['ok' => false, 'response' => '', 'tokens_used' => 0, 'cost_estimate' => 0,
                    'error' => 'LLM_PROVIDER not configured'];
        }

        // Per-user daily quota
        $userId = $userContext['user_id'] ?? 0;
        $quotaResult = self::checkQuota($userId);
        if (!$quotaResult['ok']) {
            return ['ok' => false, 'response' => '', 'tokens_used' => 0, 'cost_estimate' => 0,
                    'error' => 'Daily LLM quota exceeded — using rule-based reply'];
        }

        // Build the messages
        $userMessage = self::buildRagPrompt($userQuery, $retrievedData, $userContext);

        // Dispatch to provider
        $startMs = microtime(true) * 1000;
        try {
            switch ($provider) {
                case 'anthropic':
                    $result = self::callAnthropic($userMessage);
                    break;
                case 'openai':
                    $result = self::callOpenAI($userMessage);
                    break;
                case 'gemini':
                    $result = self::callGemini($userMessage);
                    break;
                default:
                    return ['ok' => false, 'response' => '', 'tokens_used' => 0, 'cost_estimate' => 0,
                            'error' => "Unknown provider: $provider"];
            }
            $result['elapsed_ms'] = (int)(microtime(true) * 1000 - $startMs);
            if ($result['ok']) {
                self::recordUsage($userId, $result['tokens_used']);
            }
            return $result;
        } catch (Throwable $e) {
            return ['ok' => false, 'response' => '', 'tokens_used' => 0, 'cost_estimate' => 0,
                    'error' => $e->getMessage()];
        }
    }

    /** Build the user-message prompt from query + retrieved data. */
    private static function buildRagPrompt($userQuery, $retrievedData, $userContext) {
        $role = $userContext['role'] ?? 'user';
        $district = $userContext['district_name'] ?? '—';

        $dataSection = "(no data retrieved)";
        if (!empty($retrievedData)) {
            // Strip any keys that could contain sensitive info before sending to the LLM
            $clean = self::sanitizeForLlm($retrievedData);
            $dataSection = json_encode($clean, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
        }

        return <<<MSG
User context:
- Role: {$role}
- District: {$district}

User question:
{$userQuery}

Retrieved Data (from AgroFin database):
{$dataSection}

Now respond to the user's question in Bangla, using only the retrieved data above.
MSG;
    }

    /** Strip sensitive fields before sending to a third-party API. */
    private static function sanitizeForLlm($data) {
        $sensitiveKeys = ['password', 'password_hash', 'nid_number', 'phone', 'email', 'account_number',
                          'api_key', 'token', 'csrf_token', 'session_id'];
        if (is_array($data)) {
            $clean = [];
            foreach ($data as $k => $v) {
                if (in_array(strtolower((string)$k), $sensitiveKeys, true)) continue;
                $clean[$k] = self::sanitizeForLlm($v);
            }
            return $clean;
        }
        return $data;
    }

    // ── Provider: Anthropic Claude API ──
    private static function callAnthropic($userMessage) {
        $apiKey = Env::get('LLM_API_KEY', '');
        $model = Env::get('LLM_MODEL', 'claude-haiku-4-5');
        $maxTokens = Env::getInt('LLM_MAX_TOKENS', 800);

        $payload = [
            'model' => $model,
            'max_tokens' => $maxTokens,
            'system' => self::SYSTEM_PROMPT_BN,
            'messages' => [['role' => 'user', 'content' => $userMessage]],
        ];

        $ch = curl_init('https://api.anthropic.com/v1/messages');
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($payload, JSON_UNESCAPED_UNICODE),
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'x-api-key: ' . $apiKey,
                'anthropic-version: 2023-06-01',
            ],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 30,
            CURLOPT_CONNECTTIMEOUT => 10,
        ]);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $err = curl_error($ch);
        curl_close($ch);

        if ($err) return ['ok' => false, 'response' => '', 'tokens_used' => 0, 'cost_estimate' => 0, 'error' => 'cURL: ' . $err];

        $parsed = json_decode($response, true) ?: [];
        if ($httpCode !== 200) {
            $errMsg = $parsed['error']['message'] ?? "HTTP $httpCode";
            return ['ok' => false, 'response' => '', 'tokens_used' => 0, 'cost_estimate' => 0, 'error' => $errMsg];
        }

        $text = '';
        foreach ($parsed['content'] ?? [] as $block) {
            if (($block['type'] ?? '') === 'text') $text .= $block['text'];
        }
        $inputTokens = $parsed['usage']['input_tokens'] ?? 0;
        $outputTokens = $parsed['usage']['output_tokens'] ?? 0;
        $tokens = $inputTokens + $outputTokens;
        // Haiku 4.5: ~$1/M input, ~$5/M output ≈ avg $0.003 per call at our typical sizes
        $cost = ($inputTokens / 1000000 * 1.0) + ($outputTokens / 1000000 * 5.0);

        return [
            'ok' => trim($text) !== '',
            'response' => trim($text),
            'tokens_used' => $tokens,
            'cost_estimate' => $cost,
            'error' => null,
            'provider' => 'anthropic',
            'model' => $model,
        ];
    }

    // ── Provider: OpenAI ──
    private static function callOpenAI($userMessage) {
        $apiKey = Env::get('LLM_API_KEY', '');
        $model = Env::get('LLM_MODEL', 'gpt-4o-mini');
        $maxTokens = Env::getInt('LLM_MAX_TOKENS', 800);

        $payload = [
            'model' => $model,
            'max_tokens' => $maxTokens,
            'messages' => [
                ['role' => 'system', 'content' => self::SYSTEM_PROMPT_BN],
                ['role' => 'user', 'content' => $userMessage],
            ],
        ];

        $ch = curl_init('https://api.openai.com/v1/chat/completions');
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($payload, JSON_UNESCAPED_UNICODE),
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'Authorization: Bearer ' . $apiKey,
            ],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 30,
            CURLOPT_CONNECTTIMEOUT => 10,
        ]);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $err = curl_error($ch);
        curl_close($ch);

        if ($err) return ['ok' => false, 'response' => '', 'tokens_used' => 0, 'cost_estimate' => 0, 'error' => 'cURL: ' . $err];

        $parsed = json_decode($response, true) ?: [];
        if ($httpCode !== 200) {
            $errMsg = $parsed['error']['message'] ?? "HTTP $httpCode";
            return ['ok' => false, 'response' => '', 'tokens_used' => 0, 'cost_estimate' => 0, 'error' => $errMsg];
        }
        $text = $parsed['choices'][0]['message']['content'] ?? '';
        $tokens = $parsed['usage']['total_tokens'] ?? 0;
        $cost = ($parsed['usage']['prompt_tokens'] ?? 0) / 1000000 * 0.15 +
                ($parsed['usage']['completion_tokens'] ?? 0) / 1000000 * 0.60;

        return [
            'ok' => trim($text) !== '',
            'response' => trim($text),
            'tokens_used' => $tokens,
            'cost_estimate' => $cost,
            'error' => null,
            'provider' => 'openai',
            'model' => $model,
        ];
    }

    // ── Provider: Google Gemini ──
    private static function callGemini($userMessage) {
        $apiKey = Env::get('LLM_API_KEY', '');
        $model = Env::get('LLM_MODEL', 'gemini-2.5-flash');
        $maxTokens = Env::getInt('LLM_MAX_TOKENS', 800);

        // Gemini API: system instruction is a top-level field, not a message role
        $url = sprintf(
            'https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s',
            urlencode($model), urlencode($apiKey)
        );

        $payload = [
            'system_instruction' => [
                'parts' => [['text' => self::SYSTEM_PROMPT_BN]],
            ],
            'contents' => [
                ['role' => 'user', 'parts' => [['text' => $userMessage]]],
            ],
            'generationConfig' => [
                'maxOutputTokens' => $maxTokens,
                'temperature' => 0.7,
            ],
            // Block harmful content but allow regular agricultural/financial discussion
            'safetySettings' => [
                ['category' => 'HARM_CATEGORY_HARASSMENT',        'threshold' => 'BLOCK_ONLY_HIGH'],
                ['category' => 'HARM_CATEGORY_HATE_SPEECH',       'threshold' => 'BLOCK_ONLY_HIGH'],
                ['category' => 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold' => 'BLOCK_ONLY_HIGH'],
                ['category' => 'HARM_CATEGORY_DANGEROUS_CONTENT', 'threshold' => 'BLOCK_ONLY_HIGH'],
            ],
        ];

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($payload, JSON_UNESCAPED_UNICODE),
            CURLOPT_HTTPHEADER => ['Content-Type: application/json'],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 30,
            CURLOPT_CONNECTTIMEOUT => 10,
        ]);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $err = curl_error($ch);
        curl_close($ch);

        if ($err) return ['ok' => false, 'response' => '', 'tokens_used' => 0, 'cost_estimate' => 0, 'error' => 'cURL: ' . $err];

        $parsed = json_decode($response, true) ?: [];
        if ($httpCode !== 200) {
            $errMsg = $parsed['error']['message'] ?? "HTTP $httpCode";
            return ['ok' => false, 'response' => '', 'tokens_used' => 0, 'cost_estimate' => 0, 'error' => $errMsg];
        }

        // Gemini response structure: candidates[0].content.parts[0].text
        $text = '';
        $candidates = $parsed['candidates'] ?? [];
        if (!empty($candidates[0]['content']['parts'])) {
            foreach ($candidates[0]['content']['parts'] as $part) {
                if (!empty($part['text'])) $text .= $part['text'];
            }
        }
        $finishReason = $candidates[0]['finishReason'] ?? null;
        if ($text === '' && $finishReason === 'SAFETY') {
            return ['ok' => false, 'response' => '', 'tokens_used' => 0, 'cost_estimate' => 0,
                    'error' => 'Gemini blocked response due to safety filter'];
        }

        // Token usage (Gemini reports under usageMetadata)
        $usage = $parsed['usageMetadata'] ?? [];
        $inputTokens = $usage['promptTokenCount'] ?? 0;
        $outputTokens = $usage['candidatesTokenCount'] ?? 0;
        $tokens = $inputTokens + $outputTokens;

        // Pricing (Gemini 2.5 Flash, as of 2026):
        //   Input:  $0.075 per 1M tokens
        //   Output: $0.30  per 1M tokens
        $cost = ($inputTokens / 1000000 * 0.075) + ($outputTokens / 1000000 * 0.30);

        return [
            'ok' => trim($text) !== '',
            'response' => trim($text),
            'tokens_used' => $tokens,
            'cost_estimate' => $cost,
            'error' => null,
            'provider' => 'gemini',
            'model' => $model,
        ];
    }

    // ── Quota tracking ──
    private static function checkQuota($userId) {
        $limit = Env::getInt('LLM_DAILY_QUOTA_PER_USER', 50);
        if ($limit <= 0) return ['ok' => true, 'used' => 0, 'remaining' => 999];

        $key = 'llm:quota:' . date('Y-m-d') . ':' . (int)$userId;
        $used = (int)(Cache::get($key) ?: 0);
        return [
            'ok' => $used < $limit,
            'used' => $used,
            'remaining' => max(0, $limit - $used),
        ];
    }

    private static function recordUsage($userId, $tokens) {
        $key = 'llm:quota:' . date('Y-m-d') . ':' . (int)$userId;
        $used = (int)(Cache::get($key) ?: 0);
        Cache::set($key, $used + 1, 86400);

        // Total tokens (admin metric)
        $totalKey = 'llm:total_tokens:' . date('Y-m-d');
        $total = (int)(Cache::get($totalKey) ?: 0);
        Cache::set($totalKey, $total + $tokens, 86400);
    }

    /** Admin stats — used in /admin/assistant page. */
    public static function adminStats() {
        return [
            'provider' => Env::get('LLM_PROVIDER', 'none'),
            'model' => Env::get('LLM_MODEL', '—'),
            'configured' => self::isAvailable(),
            'tokens_today' => (int)(Cache::get('llm:total_tokens:' . date('Y-m-d')) ?: 0),
            'daily_quota_per_user' => Env::getInt('LLM_DAILY_QUOTA_PER_USER', 50),
        ];
    }
}
