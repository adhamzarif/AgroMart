// AiChatDrawer.jsx — slide-in chat panel for the farmer AI assistant.
import { useState, useRef, useEffect } from 'react';
import { useLang } from '../../context/LangContext.jsx';

const BASE = import.meta.env.VITE_API_URL || 'http://localhost:4000';

export default function AiChatDrawer({ open, onClose }) {
  const { t, lang } = useLang();
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [image, setImage] = useState(null);
  const [imagePreview, setImagePreview] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState(null);
  const bottomRef = useRef(null);
  const fileInputRef = useRef(null);

  useEffect(() => {
    if (open) bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, open]);

  useEffect(() => {
    // reset preview URL when image changes
    return () => imagePreview && URL.revokeObjectURL(imagePreview);
  }, [imagePreview]);

  function pickImage(e) {
    const file = e.target.files?.[0];
    if (!file) return;
    if (file.size > 4 * 1024 * 1024) {
      setError(t('ai_image_too_big'));
      return;
    }
    setImage(file);
    if (imagePreview) URL.revokeObjectURL(imagePreview);
    setImagePreview(URL.createObjectURL(file));
    setError(null);
  }

  function removeImage() {
    if (imagePreview) URL.revokeObjectURL(imagePreview);
    setImage(null);
    setImagePreview('');
    if (fileInputRef.current) fileInputRef.current.value = '';
  }

  async function send() {
    const text = input.trim();
    if (!text && !image) return;
    if (busy) return;

    setError(null);
    setBusy(true);

    const userMsg = { role: 'user', text, image: imagePreview };
    const nextMessages = [...messages, userMsg];
    setMessages(nextMessages);
    setInput('');

    try {
      const fd = new FormData();
      fd.append('message', text);
      // Send history for context (excluding the just-added user message)
      fd.append(
        'history',
        JSON.stringify(messages.map((m) => ({ role: m.role, text: m.text })))
      );
      if (image) fd.append('image', image);

      const res = await fetch(`${BASE}/api/ai/chat`, {
        method: 'POST',
        credentials: 'include',
        body: fd,
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);

      setMessages([...nextMessages, { role: 'assistant', text: data.reply }]);
      removeImage();
    } catch (err) {
      setError(err.message);
      // remove the optimistic user message on failure so they can retry
      setMessages(messages);
      setInput(text);
    } finally {
      setBusy(false);
    }
  }

  function onKey(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      send();
    }
  }

  if (!open) return null;

  return (
    <>
      {/* backdrop */}
      <div
        className="fixed inset-0 z-[900] bg-black/40"
        onClick={onClose}
      />
      {/* drawer */}
      <aside
        className="fixed right-0 top-0 z-[901] flex h-full w-full max-w-md flex-col bg-white shadow-2xl"
        style={{ animation: 'slidein 0.25s ease-out' }}
      >
        <style>{`@keyframes slidein { from { transform: translateX(100%); } to { transform: translateX(0); } }`}</style>

        {/* Header */}
        <header className="flex items-center justify-between bg-gradient-to-br from-m1-dark to-m1 px-4 py-3 text-white">
          <div className="flex items-center gap-2">
            <span className="text-2xl">🤖</span>
            <div>
              <div className="font-bold">{t('ai_title')}</div>
              <div className="text-xs text-white/80">{t('ai_subtitle')}</div>
            </div>
          </div>
          <button
            onClick={onClose}
            className="grid h-8 w-8 place-items-center rounded-full bg-white/20 hover:bg-white/30"
            aria-label="Close"
          >
            ✕
          </button>
        </header>

        {/* Messages */}
        <div className="flex-1 space-y-3 overflow-y-auto bg-gray-50 p-4">
          {messages.length === 0 && (
            <div className="text-center text-sm text-gray-500 pt-8">
              <div className="mb-2 text-4xl">🌱</div>
              <p className="mb-3 font-semibold text-gray-700">{t('ai_welcome_title')}</p>
              <p className="text-xs">{t('ai_welcome_hint')}</p>
              <div className="mt-4 space-y-2">
                {(lang === 'bn'
                  ? ['আজকের বাজারদর কী?', 'কোন ফসল লাগানো ভালো?', 'পাতায় দাগ কেন হয়?']
                  : ['What are today\'s prices?', 'Which crop should I grow?', 'Why are leaves spotting?']
                ).map((example) => (
                  <button
                    key={example}
                    onClick={() => setInput(example)}
                    className="block w-full rounded-full border border-gray-200 bg-white px-4 py-2 text-xs text-gray-600 hover:border-m1 hover:text-m1"
                  >
                    {example}
                  </button>
                ))}
              </div>
            </div>
          )}

          {messages.map((m, i) => (
            <div key={i} className={`flex ${m.role === 'user' ? 'justify-end' : 'justify-start'}`}>
              <div
                className={`max-w-[85%] rounded-2xl px-4 py-2 text-sm ${
                  m.role === 'user'
                    ? 'bg-m1 text-white'
                    : 'bg-white text-gray-800 shadow-sm border border-gray-100'
                }`}
              >
                {m.image && (
                  <img
                    src={m.image}
                    alt=""
                    className="mb-2 max-h-48 rounded-lg object-cover"
                  />
                )}
                {m.text && <div className="whitespace-pre-wrap">{m.text}</div>}
              </div>
            </div>
          ))}

          {busy && (
            <div className="flex justify-start">
              <div className="rounded-2xl bg-white px-4 py-2 shadow-sm border border-gray-100">
                <div className="flex gap-1">
                  <span className="h-2 w-2 animate-bounce rounded-full bg-m1" style={{ animationDelay: '0ms' }} />
                  <span className="h-2 w-2 animate-bounce rounded-full bg-m1" style={{ animationDelay: '150ms' }} />
                  <span className="h-2 w-2 animate-bounce rounded-full bg-m1" style={{ animationDelay: '300ms' }} />
                </div>
              </div>
            </div>
          )}

          <div ref={bottomRef} />
        </div>

        {/* Error banner */}
        {error && (
          <div className="border-t border-danger-dark/30 bg-danger-bg px-4 py-2 text-xs text-danger-dark">
            {error}
          </div>
        )}

        {/* Image preview above input */}
        {imagePreview && (
          <div className="border-t border-gray-200 bg-white px-4 py-2 flex items-center gap-3">
            <img src={imagePreview} alt="preview" className="h-16 w-16 rounded-lg object-cover" />
            <div className="flex-1 text-xs text-gray-600 truncate">{image?.name}</div>
            <button
              onClick={removeImage}
              className="text-danger-dark hover:opacity-80 text-lg"
              aria-label="Remove"
            >
              ✕
            </button>
          </div>
        )}

        {/* Input */}
        <div className="border-t border-gray-200 bg-white p-3">
          <div className="flex items-end gap-2">
            <button
              type="button"
              onClick={() => fileInputRef.current?.click()}
              disabled={busy}
              className="grid h-10 w-10 place-items-center rounded-full bg-gray-100 text-gray-600 hover:bg-gray-200 disabled:opacity-50"
              aria-label="Attach image"
              title={t('ai_attach')}
            >
              📎
            </button>
            <input
              ref={fileInputRef}
              type="file"
              accept="image/jpeg,image/png,image/webp"
              onChange={pickImage}
              className="hidden"
            />
            <textarea
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={onKey}
              placeholder={t('ai_input_placeholder')}
              rows={1}
              disabled={busy}
              className="flex-1 resize-none rounded-2xl border border-gray-200 px-4 py-2 text-sm outline-none focus:border-m1 disabled:bg-gray-50"
              style={{ maxHeight: '120px' }}
            />
            <button
              type="button"
              onClick={send}
              disabled={busy || (!input.trim() && !image)}
              className="grid h-10 w-10 place-items-center rounded-full bg-m1 text-white hover:bg-m1-dark disabled:opacity-50"
              aria-label="Send"
            >
              ➤
            </button>
          </div>
          <p className="mt-1 text-center text-[10px] text-gray-400">{t('ai_disclaimer')}</p>
        </div>
      </aside>
    </>
  );
}
