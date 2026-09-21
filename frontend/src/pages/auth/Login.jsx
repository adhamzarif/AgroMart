// FROM_QUERY_PATCHED
// DEMO_PANEL_REMOVED
// Login.jsx — sign-in page with demo account quick-fill buttons.
import { useState } from 'react';
import { Link, useNavigate, useLocation, useSearchParams } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';
import { useAuth } from '../../context/AuthContext.jsx';


export default function Login() {
  const { t } = useLang();
  const { login } = useAuth();
  const nav = useNavigate();
  const location = useLocation();
  const [searchParams] = useSearchParams();
  const from = searchParams.get('from') || location.state?.from || '/';

  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState(null);
  const [busy, setBusy] = useState(false);

  async function onSubmit(e) {
    e.preventDefault();
    setError(null);
    setBusy(true);
    try {
      const user = await login({ phone: phone.trim(), password });
      // route by role
      const roles = user.roles || [];
      const dest = from !== '/'
        ? from
        : roles.includes('admin')  ? '/admin'
        : roles.includes('farmer') ? '/farmer/dashboard'
        : roles.includes('buyer')  ? '/marketplace'
        : '/';
      nav(dest, { replace: true });
    } catch (err) {
      setError(err.message || 'Login failed');
    } finally {
      setBusy(false);
    }
  }
  return (
    <>
      {/* Green header band */}
      <section className="bg-gradient-to-br from-m1-dark via-m1 to-m1-light py-12 text-center text-white">
        <div className="mx-auto max-w-xl px-6">
          <h1 className="text-4xl font-bold font-display">{t('login_title')}</h1>
          <p className="mt-2 text-white/85">{t('login_sub')}</p>
        </div>
      </section>

      {/* Card, overlapping the band */}
      <div className="mx-auto -mt-8 max-w-md px-6 pb-16">
        <div className="rounded-xl2 bg-white p-6 shadow-3">
          <form onSubmit={onSubmit} className="space-y-4">
            <div>
              <label className="mb-1 block text-sm font-medium text-gray-700">
                {t('login_phone')}
              </label>
              <input
                type="tel"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                placeholder="01XXXXXXXXX"
                className="w-full rounded-lg border border-gray-200 px-3 py-2.5 text-sm outline-none focus:border-m1"
                autoComplete="username"
                required
              />
            </div>

            <div>
              <label className="mb-1 block text-sm font-medium text-gray-700">
                {t('login_password')}
              </label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full rounded-lg border border-gray-200 px-3 py-2.5 text-sm outline-none focus:border-m1"
                autoComplete="current-password"
                required
              />
            </div>

            {error && (
              <div className="rounded-lg bg-danger-bg px-3 py-2 text-sm text-danger-dark">
                {error}
              </div>
            )}

            <button
              type="submit"
              disabled={busy}
              className="w-full rounded-full bg-m1 py-3 text-sm font-semibold text-white hover:bg-m1-dark disabled:opacity-60"
            >
              {busy ? '…' : t('login_button')}
            </button>
          </form>

          <div className="mt-4 text-center text-sm text-gray-500">
            {t('login_no_account')}{' '}
            <Link to="/register" className="font-semibold text-m1 hover:underline">
              {t('register')}
            </Link>
          </div>
        </div>
      </div>
    </>
  );
}
