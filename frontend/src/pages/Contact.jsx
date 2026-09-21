// Contact.jsx — polished contact page with hero + floating form card.
import { useState } from 'react';
import { useLang } from '../context/LangContext.jsx';

const HERO_IMG = 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=1600';

export default function Contact() {
  const { t } = useLang();
  const [form, setForm] = useState({ name: '', email: '', phone: '', message: '' });
  const [status, setStatus] = useState(null);

  const update = (k) => (e) => setForm((f) => ({ ...f, [k]: e.target.value }));

  const submit = async (e) => {
    e.preventDefault();
    setStatus('sending');
    setTimeout(() => setStatus('sent'), 800);
  };

  return (
    <div className="bg-gray-50 pb-20">
      {/* Hero with background image */}
      <section
        className="relative overflow-hidden px-6 pb-32 pt-20 text-center text-white"
        style={{
          backgroundImage: `linear-gradient(rgba(0,0,0,0.6), rgba(0,0,0,0.6)), url(${HERO_IMG})`,
          backgroundSize: 'cover',
          backgroundPosition: 'center',
        }}
      >
        <div className="mx-auto max-w-3xl">
          <h1 className="text-4xl font-bold sm:text-5xl font-display drop-shadow">
            {t('contact_title')}
          </h1>
          <p className="mx-auto mt-4 max-w-2xl text-lg text-white/90">
            {t('contact_sub')}
          </p>
        </div>
      </section>

      {/* Floating card that overlaps the hero */}
      <section className="mx-auto -mt-24 max-w-6xl px-6">
        <div className="grid gap-0 overflow-hidden rounded-2xl bg-white shadow-xl lg:grid-cols-5">
          {/* Info side (2 cols) */}
          <div className="bg-m1 p-8 text-white lg:col-span-2">
            <h2 className="text-2xl font-bold font-display">{t('contact_info_title')}</h2>
            <p className="mt-2 text-sm text-white/80">{t('contact_info_sub')}</p>

            <div className="mt-8 space-y-6">
              <div className="flex gap-4">
                <div className="grid h-11 w-11 flex-shrink-0 place-items-center rounded-lg bg-white/15 text-xl">
                  📞
                </div>
                <div>
                  <div className="font-semibold">{t('contact_phone_title')}</div>
                  <div className="mt-0.5 text-sm text-white/85">+880 1XXX-XXXXXX</div>
                  <div className="text-xs text-white/60">{t('contact_hours')}</div>
                </div>
              </div>

              <div className="flex gap-4">
                <div className="grid h-11 w-11 flex-shrink-0 place-items-center rounded-lg bg-white/15 text-xl">
                  ✉️
                </div>
                <div>
                  <div className="font-semibold">{t('contact_email_title')}</div>
                  <div className="mt-0.5 text-sm text-white/85">support@agromart.com.bd</div>
                  <div className="text-xs text-white/60">{t('contact_email_hint')}</div>
                </div>
              </div>

              <div className="flex gap-4">
                <div className="grid h-11 w-11 flex-shrink-0 place-items-center rounded-lg bg-white/15 text-xl">
                  📍
                </div>
                <div>
                  <div className="font-semibold">{t('contact_office_title')}</div>
                  <div className="mt-0.5 text-sm text-white/85">{t('contact_address')}</div>
                </div>
              </div>
            </div>

            {/* Social row */}
            <div className="mt-10 border-t border-white/15 pt-6">
              <div className="text-xs uppercase tracking-wider text-white/60">
                {t('contact_follow')}
              </div>
              <div className="mt-3 flex gap-3">
                {['f', 'X', 'in', '@'].map((s) => (
                  <span key={s} className="grid h-9 w-9 place-items-center rounded-full bg-white/15 text-sm font-bold hover:bg-white/25">
                    {s}
                  </span>
                ))}
              </div>
            </div>
          </div>

          {/* Form side (3 cols) */}
          <div className="p-8 sm:p-10 lg:col-span-3">
            <h2 className="text-2xl font-bold text-gray-900 font-display">
              {t('contact_form_title')}
            </h2>
            <p className="mt-2 text-sm text-gray-500">{t('contact_form_sub')}</p>

            <form onSubmit={submit} className="mt-6 space-y-4">
              <div className="grid gap-4 sm:grid-cols-2">
                <Field label={t('contact_name')} value={form.name} onChange={update('name')} required />
                <Field label={t('contact_phone')} value={form.phone} onChange={update('phone')} placeholder="01XXXXXXXXX" required />
              </div>
              <Field label={t('contact_email')} type="email" value={form.email} onChange={update('email')} required />
              <div>
                <label className="mb-1.5 block text-sm font-semibold text-gray-700">
                  {t('contact_message')}
                </label>
                <textarea
                  required
                  rows={5}
                  value={form.message}
                  onChange={update('message')}
                  className="w-full resize-none rounded-lg border border-gray-200 px-4 py-3 text-sm text-gray-900 placeholder:text-gray-400 focus:border-m1 focus:outline-none focus:ring-2 focus:ring-m1/20"
                />
              </div>

              {status === 'sent' && (
                <div className="rounded-lg bg-green-50 px-4 py-3 text-sm font-medium text-green-800">
                  ✓ {t('contact_success')}
                </div>
              )}
              {status === 'error' && (
                <div className="rounded-lg bg-red-50 px-4 py-3 text-sm font-medium text-red-800">
                  {t('contact_error')}
                </div>
              )}

              <button
                type="submit"
                disabled={status === 'sending'}
                className="w-full rounded-full bg-m1 py-3 text-sm font-semibold text-white transition hover:bg-m1-dark disabled:opacity-50 sm:w-auto sm:px-8"
              >
                {status === 'sending' ? t('contact_sending') : `${t('contact_send')} →`}
              </button>
            </form>
          </div>
        </div>
      </section>
    </div>
  );
}

function Field({ label, ...props }) {
  return (
    <div>
      <label className="mb-1.5 block text-sm font-semibold text-gray-700">{label}</label>
      <input
        {...props}
        className="w-full rounded-lg border border-gray-200 px-4 py-3 text-sm text-gray-900 placeholder:text-gray-400 focus:border-m1 focus:outline-none focus:ring-2 focus:ring-m1/20"
      />
    </div>
  );
}
