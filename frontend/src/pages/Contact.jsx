// Contact.jsx — contact form + info panel.
import { useState } from 'react';
import { useLang } from '../context/LangContext.jsx';

export default function Contact() {
  const { t } = useLang();
  const [form, setForm] = useState({ name: '', email: '', phone: '', message: '' });
  const [status, setStatus] = useState(null); // null | 'sending' | 'sent' | 'error'

  const update = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }));

  const submit = async (e) => {
    e.preventDefault();
    setStatus('sending');
    // No backend endpoint yet — simulate. Wire to /api/contact when built.
    setTimeout(() => setStatus('sent'), 800);
  };

  return (
    <section className="mx-auto max-w-6xl px-6 py-14">
      {/* Header */}
      <div className="mb-12 text-center">
        <span className="inline-block rounded-full bg-green-50 px-4 py-1 text-xs font-semibold text-green-800">
          {t('contact_badge')}
        </span>
        <h1 className="mt-4 text-3xl font-bold text-gray-900 sm:text-4xl font-display">
          {t('contact_title')}
        </h1>
        <p className="mx-auto mt-3 max-w-2xl text-gray-500">{t('contact_sub')}</p>
      </div>

      {/* Two columns */}
      <div className="grid gap-8 lg:grid-cols-3">
        {/* Info side (1 col) */}
        <div className="space-y-4">
          <div className="rounded-xl border border-gray-100 bg-white p-6 shadow-sm">
            <div className="mb-2 text-2xl">📞</div>
            <h3 className="font-bold text-gray-900">{t('contact_phone_title')}</h3>
            <p className="mt-1 text-sm text-gray-600">+880 1XXX-XXXXXX</p>
            <p className="text-xs text-gray-400">{t('contact_hours')}</p>
          </div>
          <div className="rounded-xl border border-gray-100 bg-white p-6 shadow-sm">
            <div className="mb-2 text-2xl">✉️</div>
            <h3 className="font-bold text-gray-900">{t('contact_email_title')}</h3>
            <p className="mt-1 text-sm text-gray-600">support@agromart.com.bd</p>
            <p className="text-xs text-gray-400">{t('contact_email_hint')}</p>
          </div>
          <div className="rounded-xl border border-gray-100 bg-white p-6 shadow-sm">
            <div className="mb-2 text-2xl">📍</div>
            <h3 className="font-bold text-gray-900">{t('contact_office_title')}</h3>
            <p className="mt-1 text-sm text-gray-600">{t('contact_address')}</p>
          </div>
        </div>

        {/* Form side (2 cols) */}
        <div className="lg:col-span-2">
          <form onSubmit={submit} className="rounded-xl border border-gray-100 bg-white p-6 shadow-sm sm:p-8">
            <div className="grid gap-4 sm:grid-cols-2">
              <div>
                <label className="mb-1 block text-sm font-semibold text-gray-700">
                  {t('contact_name')}
                </label>
                <input
                  required
                  value={form.name}
                  onChange={update('name')}
                  className="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm focus:border-m1 focus:outline-none focus:ring-1 focus:ring-m1"
                />
              </div>
              <div>
                <label className="mb-1 block text-sm font-semibold text-gray-700">
                  {t('contact_phone')}
                </label>
                <input
                  required
                  value={form.phone}
                  onChange={update('phone')}
                  placeholder="01XXXXXXXXX"
                  className="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm focus:border-m1 focus:outline-none focus:ring-1 focus:ring-m1"
                />
              </div>
            </div>

            <div className="mt-4">
              <label className="mb-1 block text-sm font-semibold text-gray-700">
                {t('contact_email')}
              </label>
              <input
                type="email"
                required
                value={form.email}
                onChange={update('email')}
                className="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm focus:border-m1 focus:outline-none focus:ring-1 focus:ring-m1"
              />
            </div>

            <div className="mt-4">
              <label className="mb-1 block text-sm font-semibold text-gray-700">
                {t('contact_message')}
              </label>
              <textarea
                required
                rows={5}
                value={form.message}
                onChange={update('message')}
                className="w-full resize-none rounded-lg border border-gray-200 px-3 py-2 text-sm focus:border-m1 focus:outline-none focus:ring-1 focus:ring-m1"
              />
            </div>

            {status === 'sent' && (
              <div className="mt-4 rounded-lg bg-green-50 px-4 py-3 text-sm text-green-800">
                {t('contact_success')}
              </div>
            )}
            {status === 'error' && (
              <div className="mt-4 rounded-lg bg-red-50 px-4 py-3 text-sm text-red-800">
                {t('contact_error')}
              </div>
            )}

            <button
              type="submit"
              disabled={status === 'sending'}
              className="mt-6 rounded-full bg-m1 px-6 py-3 text-sm font-semibold text-white hover:bg-m1-dark disabled:opacity-50"
            >
              {status === 'sending' ? t('contact_sending') : t('contact_send')}
            </button>
          </form>
        </div>
      </div>
    </section>
  );
}
