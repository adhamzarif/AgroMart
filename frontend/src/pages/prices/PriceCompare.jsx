// PriceCompare.jsx — beautiful price comparison across districts.
import { useEffect, useState } from 'react';
import { useLang } from '../../context/LangContext.jsx';
import { api } from '../../api/client.js';
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer,
  CartesianGrid, Legend, Cell,
} from 'recharts';

export default function PriceCompare() {
  const { t, lang } = useLang();
  const [crops, setCrops] = useState([]);
  const [selectedCrop, setSelectedCrop] = useState('');
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/api/prices/crops').then((r) => {
      const list = r.crops || [];
      setCrops(list);
      if (list.length && !selectedCrop) setSelectedCrop(list[0]);
    });
  }, []);

  useEffect(() => {
    if (!selectedCrop) return;
    setLoading(true);
    api
      .get(`/api/prices/compare?crop=${encodeURIComponent(selectedCrop)}`)
      .then((r) => setRows(r.rows || []))
      .finally(() => setLoading(false));
  }, [selectedCrop]);

  const cheapest = rows[0];
  const priciest = rows[rows.length - 1];
  const avg =
    rows.length > 0
      ? rows.reduce((s, r) => s + Number(r.retail_price), 0) / rows.length
      : 0;
  const unit = rows[0]?.unit || 'kg';
  const gap = priciest && cheapest ? priciest.retail_price - cheapest.retail_price : 0;
  const gapPct = cheapest ? (gap / cheapest.retail_price) * 100 : 0;

  return (
    <div className="bg-gray-50 pb-20">
      {/* Hero band */}
      <div className="border-b border-gray-100 bg-gradient-to-br from-green-50 via-white to-white">
        <div className="mx-auto max-w-6xl px-6 py-14">
          <div className="inline-block rounded-full bg-white px-4 py-1 text-xs font-semibold text-m1 shadow-sm">
            📊 {t('pc_badge')}
          </div>
          <h1 className="mt-4 text-4xl font-bold text-gray-900 sm:text-5xl font-display">
            {t('pc_title')}
          </h1>
          <p className="mt-3 max-w-2xl text-lg text-gray-500">{t('pc_sub')}</p>

          {/* Crop selector */}
          <div className="mt-8 inline-flex items-center gap-3 rounded-full border border-gray-200 bg-white p-2 pl-5 shadow-sm">
            <span className="text-sm font-semibold text-gray-700">
              {t('pc_select_crop')}
            </span>
            <select
              value={selectedCrop}
              onChange={(e) => setSelectedCrop(e.target.value)}
              className="rounded-full bg-m1 px-4 py-2 pr-8 text-sm font-semibold text-white focus:outline-none focus:ring-2 focus:ring-m1/40"
            >
              {crops.map((c) => (
                <option key={c} value={c} className="bg-white text-gray-900">
                  {c}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      <div className="mx-auto max-w-6xl px-6 py-10">
        {loading && (
          <div className="grid gap-4 sm:grid-cols-3">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-32 animate-pulse rounded-2xl bg-gray-100" />
            ))}
          </div>
        )}

        {!loading && rows.length > 0 && (
          <>
            {/* Stat cards */}
            <div className="mb-8 grid gap-4 sm:grid-cols-3">
              <Stat
                icon="🟢"
                label={t('pc_cheapest')}
                value={`৳${cheapest.retail_price}`}
                sub={`${cheapest.district_name} • ${t('pc_per')} ${unit}`}
                tone="green"
              />
              <Stat
                icon="🔴"
                label={t('pc_priciest')}
                value={`৳${priciest.retail_price}`}
                sub={`${priciest.district_name} • ${t('pc_per')} ${unit}`}
                tone="red"
              />
              <Stat
                icon="📊"
                label={t('pc_gap')}
                value={`৳${gap.toFixed(2)}`}
                sub={`${gapPct.toFixed(0)}% ${t('pc_gap_pct')} • ${t('pc_avg')} ৳${avg.toFixed(2)}`}
                tone="blue"
              />
            </div>

            {/* Chart */}
            <div className="mb-8 rounded-2xl border border-gray-100 bg-white p-6 shadow-sm sm:p-8">
              <div className="mb-4 flex flex-wrap items-baseline justify-between gap-2">
                <div>
                  <h2 className="text-xl font-bold text-gray-900 font-display">
                    {t('pc_chart_title')}
                  </h2>
                  <p className="text-sm text-gray-500">
                    {selectedCrop} • {rows.length} {t('pc_districts')}
                  </p>
                </div>
                <div className="flex gap-3 text-xs">
                  <LegendChip color="#94a3b8" label={t('pc_wholesale')} />
                  <LegendChip color="#16a34a" label={t('pc_retail')} />
                </div>
              </div>
              <div style={{ width: '100%', height: 360 }}>
                <ResponsiveContainer>
                  <BarChart
                    data={rows}
                    margin={{ top: 10, right: 10, left: 0, bottom: 10 }}
                    barGap={4}
                  >
                    <CartesianGrid vertical={false} stroke="#f1f5f9" />
                    <XAxis
                      dataKey="district_name"
                      tick={{ fontSize: 12, fill: '#64748b' }}
                      axisLine={false}
                      tickLine={false}
                    />
                    <YAxis
                      tick={{ fontSize: 12, fill: '#64748b' }}
                      axisLine={false}
                      tickLine={false}
                      tickFormatter={(v) => `৳${v}`}
                    />
                    <Tooltip
                      cursor={{ fill: '#f8fafc' }}
                      formatter={(v) => `৳${v}`}
                      contentStyle={{
                        borderRadius: 12,
                        border: '1px solid #e2e8f0',
                        boxShadow: '0 4px 12px rgba(0,0,0,0.05)',
                      }}
                    />
                    <Bar dataKey="wholesale_price" name={t('pc_wholesale')} radius={[6, 6, 0, 0]} fill="#94a3b8" />
                    <Bar dataKey="retail_price" name={t('pc_retail')} radius={[6, 6, 0, 0]}>
                      {rows.map((_, i) => (
                        <Cell
                          key={i}
                          fill={
                            i === 0
                              ? '#16a34a'
                              : i === rows.length - 1
                                ? '#dc2626'
                                : '#22c55e'
                          }
                        />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* Table */}
            <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
              <div className="border-b border-gray-100 px-6 py-4 sm:px-8">
                <h2 className="text-lg font-bold text-gray-900 font-display">
                  {t('pc_table_title')}
                </h2>
                <p className="mt-0.5 text-sm text-gray-500">
                  {t('pc_table_sub')}
                </p>
              </div>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead className="bg-gray-50 text-xs uppercase tracking-wider text-gray-500">
                    <tr>
                      <th className="px-6 py-3 text-left">#</th>
                      <th className="px-6 py-3 text-left">{t('pc_district')}</th>
                      <th className="px-6 py-3 text-right">{t('pc_wholesale')}</th>
                      <th className="px-6 py-3 text-right">{t('pc_retail')}</th>
                      <th className="px-6 py-3 text-right">{t('pc_savings')}</th>
                      <th className="px-6 py-3 text-left">{t('pc_updated')}</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {rows.map((r, i) => {
                      const savings = priciest.retail_price - r.retail_price;
                      const savingsPct = (savings / priciest.retail_price) * 100;
                      return (
                        <tr
                          key={r.district_id}
                          className={
                            i === 0
                              ? 'bg-green-50/60 hover:bg-green-50'
                              : 'hover:bg-gray-50'
                          }
                        >
                          <td className="px-6 py-4 text-gray-400">{i + 1}</td>
                          <td className="px-6 py-4">
                            <div className="flex items-center gap-2 font-semibold text-gray-900">
                              {r.district_name}
                              {i === 0 && (
                                <span className="rounded-full bg-green-100 px-2 py-0.5 text-xs font-semibold text-green-800">
                                  ✓ {t('pc_best')}
                                </span>
                              )}
                              {i === rows.length - 1 && (
                                <span className="rounded-full bg-red-100 px-2 py-0.5 text-xs font-semibold text-red-800">
                                  {t('pc_highest')}
                                </span>
                              )}
                            </div>
                          </td>
                          <td className="px-6 py-4 text-right text-gray-600">
                            ৳{r.wholesale_price}
                          </td>
                          <td className="px-6 py-4 text-right font-bold text-gray-900">
                            ৳{r.retail_price}
                          </td>
                          <td className="px-6 py-4 text-right">
                            {savings > 0 ? (
                              <span className="font-semibold text-green-700">
                                ৳{savings.toFixed(2)}{' '}
                                <span className="text-xs opacity-70">
                                  ({savingsPct.toFixed(0)}%)
                                </span>
                              </span>
                            ) : (
                              <span className="text-gray-300">—</span>
                            )}
                          </td>
                          <td className="px-6 py-4 text-xs text-gray-400">
                            {new Date(r.price_date).toLocaleDateString(
                              lang === 'bn' ? 'bn-BD' : 'en-GB'
                            )}
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>

            {/* Footnote */}
            <p className="mt-6 text-center text-xs text-gray-400">
              {t('pc_source')}: DAM • {t('pc_disclaimer')}
            </p>
          </>
        )}
      </div>
    </div>
  );
}

function Stat({ icon, label, value, sub, tone }) {
  const tones = {
    green: 'border-green-100 bg-gradient-to-br from-green-50 to-white text-green-700',
    red: 'border-red-100 bg-gradient-to-br from-red-50 to-white text-red-700',
    blue: 'border-blue-100 bg-gradient-to-br from-blue-50 to-white text-blue-700',
  };
  return (
    <div className={`rounded-2xl border p-6 shadow-sm ${tones[tone]}`}>
      <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider opacity-80">
        <span className="text-base">{icon}</span> {label}
      </div>
      <div className="mt-2 text-3xl font-bold text-gray-900 font-display">{value}</div>
      <div className="mt-1 text-xs text-gray-500">{sub}</div>
    </div>
  );
}

function LegendChip({ color, label }) {
  return (
    <span className="inline-flex items-center gap-1.5 text-gray-600">
      <span className="h-2.5 w-2.5 rounded-sm" style={{ backgroundColor: color }} />
      {label}
    </span>
  );
}
