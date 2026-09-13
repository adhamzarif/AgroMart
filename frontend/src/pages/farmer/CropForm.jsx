// CropForm.jsx — farmer lists a new crop, with image upload (slice B2).
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';
import { createCrop } from '../../api/crops.api.js';
import { getCategories } from '../../api/crops.api.js';

const UNITS = ['kg', 'ton', 'mon', 'piece'];
const EMPTY = { cropName: '', categoryId: '', quantity: '', unit: 'kg', pricePerUnit: '', description: '', isOrganic: false };

export default function CropForm() {
  const { t } = useLang();
  const nav = useNavigate();
  const [form, setForm] = useState(EMPTY);
  const [files, setFiles] = useState([]);
  const [previews, setPreviews] = useState([]);
  const [categories, setCategories] = useState([]);
  const [errors, setErrors] = useState({});
  const [status, setStatus] = useState(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    getCategories().then((r) => setCategories(r.categories || [])).catch(() => {});
  }, []);

  const upd = (k) => (e) =>
    setForm({ ...form, [k]: e.target.type === 'checkbox' ? e.target.checked : e.target.value });

  function onFiles(e) {
    const picked = Array.from(e.target.files).slice(0, 4);
    setFiles(picked);
    setPreviews(picked.map((f) => URL.createObjectURL(f)));
  }

  async function onSubmit(e) {
    e.preventDefault();
    setStatus(null); setErrors({}); setBusy(true);
    try {
      const fd = new FormData();
      Object.entries(form).forEach(([k, v]) => fd.append(k, v));
      files.forEach((f) => fd.append('images', f));
      const res = await createCrop(fd);
      setStatus({ type: 'success', msg: t('crop_added') });
      setTimeout(() => nav('/marketplace'), 900);
    } catch (err) {
      if (err.fields) setErrors(err.fields);
      setStatus({ type: 'error', msg: err.message });
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="mx-auto max-w-xl px-6 py-10">
      <h1 className="mb-6 text-2xl font-bold text-gray-900 font-display">{t('list_crop')}</h1>

      {status && (
        <p className={`mb-4 ${status.type === 'success' ? 'text-m1' : 'text-danger-dark'}`}>
          {status.msg}
        </p>
      )}

      <form onSubmit={onSubmit} className="space-y-4">
        <Field label={t('crop_name')} error={errors.cropName}>
          <input className="w-full rounded-lg border border-gray-200 px-3 py-2"
                 value={form.cropName} onChange={upd('cropName')} />
        </Field>

        <Field label={t('category')} error={errors.categoryId}>
          <select className="w-full rounded-lg border border-gray-200 px-3 py-2"
                  value={form.categoryId} onChange={upd('categoryId')}>
            <option value="">—</option>
            {categories.map((c) => (
              <option key={c.category_id} value={c.category_id}>{c.category_name_bn}</option>
            ))}
          </select>
        </Field>

        <div className="grid grid-cols-2 gap-4">
          <Field label={t('quantity')} error={errors.quantity}>
            <input type="number" min="0" step="0.01" className="w-full rounded-lg border border-gray-200 px-3 py-2"
                   value={form.quantity} onChange={upd('quantity')} />
          </Field>
          <Field label={t('unit')} error={errors.unit}>
            <select className="w-full rounded-lg border border-gray-200 px-3 py-2"
                    value={form.unit} onChange={upd('unit')}>
              {UNITS.map((u) => <option key={u} value={u}>{u}</option>)}
            </select>
          </Field>
        </div>

        <Field label={t('price_per_unit')} error={errors.pricePerUnit}>
          <input type="number" min="0" step="0.01" className="w-full rounded-lg border border-gray-200 px-3 py-2"
                 value={form.pricePerUnit} onChange={upd('pricePerUnit')} />
        </Field>

        <Field label={t('description')}>
          <textarea rows="3" className="w-full rounded-lg border border-gray-200 px-3 py-2"
                    value={form.description} onChange={upd('description')} />
        </Field>

        <label className="flex items-center gap-2 text-sm">
          <input type="checkbox" checked={form.isOrganic} onChange={upd('isOrganic')} />
          {t('is_organic')}
        </label>

        <Field label={t('crop_images')}>
          <input type="file" accept="image/jpeg,image/png,image/webp" multiple onChange={onFiles} />
          {previews.length > 0 && (
            <div className="mt-2 flex gap-2">
              {previews.map((src, i) => (
                <img key={i} src={src} alt="" className="h-16 w-16 rounded-lg object-cover" />
              ))}
            </div>
          )}
        </Field>

        <button type="submit" disabled={busy}
                className="rounded-full bg-m1 px-6 py-3 font-semibold text-white hover:bg-m1-dark disabled:opacity-60">
          {busy ? '…' : t('submit_crop')}
        </button>
      </form>
    </div>
  );
}

function Field({ label, error, children }) {
  return (
    <label className="block">
      <div className="mb-1 text-sm font-medium text-gray-700">{label}</div>
      {children}
      {error && <div className="mt-1 text-sm text-danger-dark">{error}</div>}
    </label>
  );
}
