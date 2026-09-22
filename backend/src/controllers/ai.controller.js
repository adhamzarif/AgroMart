// ai.controller.js — Gemini AI proxy using @google/genai (supports AQ.* keys).
import { GoogleGenAI } from '@google/genai';
import fs from 'fs';

const SYSTEM_PROMPT = `You are an AI assistant for AgroMart, a Bangladeshi agricultural marketplace.
Your users are farmers, buyers, and agents.

Your job:
- Help farmers with crop advice (varieties, planting, harvesting, care)
- Identify crop diseases from photos
- Answer questions about market prices, weather, and best practices
- Explain how AgroMart features work (listing crops, pricing, delivery)
- Suggest which crops to grow based on season, region, or market demand
- Answer in a warm, respectful, encouraging tone

Language rule: Reply in the same language the user writes in.
- If they write in Bengali (বাংলা), reply in Bengali.
- If they write in English, reply in English.
- If mixed, default to Bengali.

Keep answers practical, short, and actionable. Use simple words. Number steps when giving instructions.`;

let client = null;
function getClient() {
  if (!process.env.GEMINI_API_KEY) {
    throw new Error('GEMINI_API_KEY is not set in backend/.env');
  }
  if (!client) client = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
  return client;
}

export async function chat(req, res, next) {
  try {
    const message = String(req.body.message || '').trim();
    const history = req.body.history ? JSON.parse(req.body.history) : [];

    if (!message && !req.file) {
      return res.status(400).json({ error: 'Message or image required' });
    }

    const genai = getClient();

    // Build message content: text + optional inline image
    const parts = [];
    if (message) parts.push({ text: message });
    if (req.file) {
      const fileBytes = fs.readFileSync(req.file.path);
      parts.push({
        inlineData: {
          mimeType: req.file.mimetype,
          data: fileBytes.toString('base64'),
        },
      });
    }

    // Convert history to Gemini format
    const geminiHistory = history
      .filter((h) => h.role === 'user' || h.role === 'assistant')
      .map((h) => ({
        role: h.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: h.text || '' }],
      }));

    const contents = [...geminiHistory, { role: 'user', parts }];

    const result = await genai.models.generateContent({
      model: 'gemini-3.6-flash',
      contents,
      config: { systemInstruction: SYSTEM_PROMPT },
    });

    const responseText = result.text || result.candidates?.[0]?.content?.parts?.[0]?.text || '';

    // Clean up uploaded temp file
    if (req.file) { try { fs.unlinkSync(req.file.path); } catch {} }

    res.json({ reply: responseText });
  } catch (err) {
    if (req.file) { try { fs.unlinkSync(req.file.path); } catch {} }
    console.error('AI chat error:', err.message);
    if (err.message.includes('GEMINI_API_KEY')) {
      return res.status(500).json({ error: 'AI service not configured. Contact administrator.' });
    }
    if (err.message.includes('API_KEY_INVALID') || err.message.includes('authentication')) {
      return res.status(500).json({ error: 'AI service authentication failed.' });
    }
    if (err.status === 429 || err.message.includes('quota')) {
      return res.status(429).json({ error: 'AI is busy right now. Please try again.' });
    }
    res.status(500).json({ error: 'AI failed to respond. Please try again.' });
  }
}
