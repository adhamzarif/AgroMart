// AdminDashboard.jsx — admin stats + users + crops tabs.
import { useEffect, useState } from 'react';
import { useLang } from '../../context/LangContext.jsx';
import { useAuth } from '../../context/AuthContext.jsx';

const BASE = import.meta.env.VITE_API_URL || 'http://localhost:4000';

export default function AdminDashboard() {
  const { t } = useLang();
  const { user } = useAuth();
  const [stats, setStats] = useState(null);
  const [tab, setTab] = useState('users');
  const [users, setUsers] = useState([]);
  const [crops, setCrops] = useState([]);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('');
  const [busy, setBusy] = useState(true);

  useEffect(() => {
    fetch(`${BASE}/api/admin/stats`, { credentials: 'include' })
      .then((r) => r.json()).then((d) => setStats(d)).catch(() => {});
  }, []);

  useEffect(() => {
    setBusy(true);
    if (tab === 'users') {
      const qs = new URLSearchParams();
      if (search) qs.set('q', search);
      if (roleFilter) qs.set('role', roleFilter);
      fetch(`${BASE}/api/admin/users?${qs}`, { credentials: 'include' })
        .then((r) => r.json()).then((d) => setUsers(d.users || [])).catch(() => {}).finally(() => setBusy(false));
    } else {
      fetch(`${BASE}/api/admin/crops`, { credentials: 'include' })
        .then((r) => r.json()).then((d) => setCrops(d.crops || [])).catch(() => {}).finally(() => setBusy(false));
    }
  }, [tab, search, roleFilter]);

  return (
    <>
      <section className="bg-gradient-to-br from-danger-dark via-red-600 to-red-500 py-10 text-white">
        <div className="mx-auto max-w-6xl px-6">
          <h1 className="text-3xl font-bold font-display">{t('ad_title')}</h1>
          <p className="mt-1 text-white/85">{t('ad_sub')}, {user?.fullName}</p>
        </div>
      </section>
      <div className="mx-auto max-w-6xl px-6 py-8">
        <div className="mb-8 grid grid-cols-2 gap-4 sm:grid-cols-4">
          <StatCard label={t('ad_stat_users')} value={stats?.totalUsers ?? '…'} />
          <StatCard label={t('ad_stat_crops')} value={stats?.totalCrops ?? '…'} />
          <StatCard label={t('ad_stat_active')} value={stats?.activeListings ?? '…'} />
          <StatCard label={t('ad_stat_today')} value={stats?.newUsersToday ?? '…'} />
        </div>

        <div className="mb-6 flex items-center gap-2 border-b border-gray-200">
          <TabButton active={tab === 'users'} onClick={() => setTab('users')}>{t('ad_tab_users')}</TabButton>
          <TabButton active={tab === 'crops'} onClick={() => setTab('crops')}>{t('ad_tab_crops')}</TabButton>
        </div>

        {tab === 'users' && (
          <>
            <div className="mb-4 flex flex-col gap-3 sm:flex-row">
              <input
                type="search"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder={t('ad_search_users')}
                className="flex-1 rounded-lg border border-gray-200 px-3 py-2 text-sm outline-none focus:border-m1"
              />
              <select
                value={roleFilter}
                onChange={(e) => setRoleFilter(e.target.value)}
                className="rounded-lg border border-gray-200 px-3 py-2 text-sm outline-none focus:border-m1 sm:w-48"
              >
                <option value="">{t('ad_all_roles')}</option>
                <option value="admin">{t('role_admin')}</option>
                <option value="farmer">{t('role_farmer')}</option>
                <option value="buyer">{t('role_buyer')}</option>
              </select>
            </div>
            {busy && <div className="rounded-xl2 bg-gray-50 p-6 text-center text-gray-500">{t('fd_loading')}</div>}
            {!busy && (
              <div className="overflow-hidden rounded-xl2 border border-gray-100 bg-white shadow-1">
                <table className="w-full">
                  <thead className="bg-gray-50 text-xs uppercase tracking-wide text-gray-500">
                    <tr>
                      <th className="px-4 py-3 text-left">{t('ad_col_name')}</th>
                      <th className="px-4 py-3 text-left">{t('ad_col_phone')}</th>
                      <th className="px-4 py-3 text-left">{t('ad_col_roles')}</th>
                      <th className="px-4 py-3 text-left">{t('ad_col_status')}</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {users.map((u) => (
                      <tr key={u.user_id} className="hover:bg-gray-50">
                        <td className="px-4 py-3">
                          <div className="font-semibold text-gray-900">{u.full_name}</div>
                          {u.email && <div className="text-xs text-gray-500">{u.email}</div>}
                        </td>
                        <td className="px-4 py-3 text-sm text-gray-700">{u.phone}</td>
                        <td className="px-4 py-3">
                          <div className="flex flex-wrap gap-1">
                            {(u.roles || []).map((r) => (
                              <span key={r} className="rounded-full bg-success-bg px-2 py-0.5 text-xs font-semibold text-m1-dark">{t(`role_${r}`)}</span>
                            ))}
                          </div>
                        </td>
                        <td className="px-4 py-3"><span className="rounded-full bg-info-bg px-2 py-0.5 text-xs font-semibold text-info-dark">{u.account_status}</span></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </>
        )}

        {tab === 'crops' && (
          <>
            {busy && <div className="rounded-xl2 bg-gray-50 p-6 text-center text-gray-500">{t('fd_loading')}</div>}
            {!busy && (
              <div className="overflow-hidden rounded-xl2 border border-gray-100 bg-white shadow-1">
                <table className="w-full">
                  <thead className="bg-gray-50 text-xs uppercase tracking-wide text-gray-500">
                    <tr>
                      <th className="px-4 py-3 text-left">{t('fd_col_name')}</th>
                      <th className="px-4 py-3 text-left">{t('ad_col_farmer')}</th>
                      <th className="px-4 py-3 text-left">{t('fd_col_qty')}</th>
                      <th className="px-4 py-3 text-left">{t('fd_col_price')}</th>
                      <th className="px-4 py-3 text-left">{t('fd_col_status')}</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {crops.map((c) => (
                      <tr key={c.crop_id} className="hover:bg-gray-50">
                        <td className="px-4 py-3 font-semibold text-gray-900">{c.crop_name}</td>
                        <td className="px-4 py-3">
                          <div className="text-sm text-gray-700">{c.farmer_name || '—'}</div>
                          {c.farmer_phone && <div className="text-xs text-gray-500">{c.farmer_phone}</div>}
                        </td>
                        <td className="px-4 py-3 text-sm">{c.quantity} {c.unit}</td>
                        <td className="px-4 py-3 text-sm font-semibold text-m1">{'\u09F3' + Number(c.price_per_unit).toLocaleString()}</td>
                        <td className="px-4 py-3">
                          <span className={`rounded-full px-2 py-0.5 text-xs font-semibold ${c.status === 'available' ? 'bg-success-bg text-m1-dark' : c.status === 'sold' ? 'bg-info-bg text-info-dark' : 'bg-gray-100 text-gray-600'}`}>{c.status}</span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </>
        )}
      </div>
    </>
  );
}

function StatCard({ label, value }) {
  return (
    <div className="rounded-xl2 bg-white p-5 shadow-1">
      <div className="text-xs uppercase tracking-wide text-gray-500">{label}</div>
      <div className="mt-1 text-2xl font-bold text-gray-900">{value}</div>
    </div>
  );
}
function TabButton({ active, onClick, children }) {
  return (
    <button
      onClick={onClick}
      className={`border-b-2 px-4 py-2 text-sm font-semibold transition ${active ? 'border-m1 text-m1' : 'border-transparent text-gray-500 hover:text-gray-700'}`}
    >{children}</button>
  );
}
