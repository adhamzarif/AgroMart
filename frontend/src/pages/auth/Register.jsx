// Register.jsx — create account. Green header + card, bilingual, required marks.
import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';
import { register } from '../../api/auth.api.js';

const EMPTY = { fullName: '', phone: '', email: '', password: '', role: 'farmer' };

export default function Register() {
  const { t } = useLang();
  const nav = useNavigate();
  const [form, setForm] = useState(EMPTY);
  const [fieldErrors, setFieldErrors] = useState({});
  const [status, setStatus] = useState(null);
  const [busy, setBusy] = useState(false);

  const upd = (k) => (e) => setForm({ ...form, [k]: e.target.value });

  async function onSubmit(e) {
    e.preventDefault();
    setStatus(null);
    setFieldErrors({});
    setBusy(true);
    try {
      const res = await register(form);
      setStatus({ type: 'success', msg: t('rg_success').replace('{name}', res.user.fullName) });
      setTimeout(() => nav('/login'), 1200);
    } catch (err) {
      if (err.fields) setFieldErrors(err.fields);
      setStatus({ type: 'error', msg: err.message || t('rg_error') });
    } finally {
      setBusy(false);
    }
  }

  return (
    <>
      {/* Green header */}
      <section className="bg-gradient-to-br from-m1-dark via-m1 to-m1-light py-12 text-center text-white">
        <div className="mx-auto max-w-xl px-6">
          <h1 className="text-4xl font-bold font-display">{t('rg_title')}</h1>
          <p className="mt-2 text-white/85">{t('rg_sub')}</p>
        </div>
      </section>

      {/* Card overlapping header */}
      <div className="mx-auto -mt-8 max-w-md px-6 pb-16">
        <div className="rounded-xl2 bg-white p-6 shadow-3">

          {status && (
            <div className={`mb-4 rounded-lg px-3 py-2 text-sm ${
              status.type === 'success'
                ? 'bg-success-bg text-m1-dark'
                : 'bg-danger-bg text-danger-dark'
            }`}>
              {status.msg}
            </div>
          )}

          <form onSubmit={onSubmit} className="space-y-4" noValidate>

            <Field label={t('rg_name')} required error={fieldErrors.fullName}>
              <input
                type="text"
                value={form.fullName}
                onChange={upd('fullName')}
                placeholder={t('rg_name_ph')}
                className={inputCls(fieldErrors.fullName)}
                autoComplete="name"
                required
              />
            </Field>

            <Field label={t('rg_phone')} required error={fieldErrors.phone}>
              <input
                type="tel"
                value={form.phone}
                onChange={upd('phone')}
                placeholder="01XXXXXXXXX"
                className={inputCls(fieldErrors.phone)}
                autoComplete="tel"
                required
              />
            </Field>

            <Field label={t('rg_email')} error={fieldErrors.email}>
              <input
                type="email"
                value={form.email}
                onChange={upd('email')}
                placeholder={t('rg_email_ph')}
                className={inputCls(fieldErrors.email)}
                autoComplete="email"
              />
            </Field>

            <Field label={t('rg_password')} required error={fieldErrors.password}>
              <input
                type="password"
                value={form.password}
                onChange={upd('password')}
                placeholder={t('rg_password_ph')}
                className={inputCls(fieldErrors.password)}
                autoComplete="new-password"
                required
              />
            </Field>

            <Field label={t('rg_role')} required error={fieldErrors.role}>
              <select
                value={form.role}
                onChange={upd('role')}
                className={inputCls(fieldErrors.role)}
              >
                <option value="farmer">{t('role_farmer')}</option>
                <option value="buyer">{t('role_buyer')}</option>
              </select>
            </Field>

            <button
              type="submit"
              disabled={busy}
              className="w-full rounded-full bg-m1 py-3 text-sm font-semibold text-white hover:bg-m1-dark disabled:opacity-60"
            >
              {busy ? t('rg_submitting') : t('rg_submit')}
            </button>
          </form>

          <div className="mt-4 text-center text-sm text-gray-500">
            {t('rg_have_account')}{' '}
            <Link to="/login" className="font-semibold text-m1 hover:underline">
              {t('login')}
            </Link>
          </div>
        </div>
      </div>
    </>
  );
}

function Field({ label, error, required, children }) {
  return (
    <div>
      <label className="mb-1 block text-sm font-medium text-gray-700">
        {label} {required && <span className="text-danger-dark">*</span>}
      </label>
      {children}
      {error && <p className="mt-1 text-xs text-danger-dark">{error}</p>}
    </div>
  );
}

function inputCls(err) {
  return `w-full rounded-lg border px-3 py-2.5 text-sm outline-none transition ${
    err ? 'border-danger-dark focus:border-danger-dark' : 'border-gray-200 focus:border-m1'
  }`;
}
