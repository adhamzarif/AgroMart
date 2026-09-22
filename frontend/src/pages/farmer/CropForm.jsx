// CropForm.jsx — farmer lists a new crop. Green header + card, previews, required marks.
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';
import { createCrop, getCategories } from '../../api/crops.api.js';

const UNITS = ['kg', 'ton', 'mon', 'piece'];
const EMPTY = {
  cropName: '', cropVariety: '', categoryId: '',
  quantity: '', unit: 'kg', pricePerUnit: '',
  description: '', isOrganic: false,
};

export default function CropForm() {
  const { t, lang } = useLang();
  const nav = useNavigate();
  const [form, setForm] = useState(EMPTY);
  const [files, setFiles] = useState([]);
  const [previews, setPreviews] = useState([]);
  const [categories, setCategories] = useState([]);
  const [errors, setErrors] = useState({});
  const [status, setStatus] = useState(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    getCategories()
      .then((r) => setCategories(r.categories || []))
      .catch(() => setCategories([]));
  }, []);

  // Free preview URLs when component unmounts or files change
  useEffect(() => {
    return () => previews.forEach((url) => URL.revokeObjectURL(url));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [previews]);

  const upd = (k) => (e) =>
    setForm({ ...form, [k]: e.target.type === 'checkbox' ? e.target.checked : e.target.value });

  function onFiles(e) {
    const picked = Array.from(e.target.files).slice(0, 4);
    setFiles(picked);
    // revoke old previews then create new
    previews.forEach((url) => URL.revokeObjectURL(url));
    setPreviews(picked.map((f) => URL.createObjectURL(f)));
  }

  function removeImage(idx) {
    const nextFiles = files.filter((_, i) => i !== idx);
    const nextPreviews = previews.filter((_, i) => i !== idx);
    URL.revokeObjectURL(previews[idx]);
    setFiles(nextFiles);
    setPreviews(nextPreviews);
  }

  async function onSubmit(e) {
    e.preventDefault();
    setStatus(null);
    setErrors({});
    setBusy(true);
    try {
      const fd = new FormData();
      Object.entries(form).forEach(([k, v]) => fd.append(k, v));
      files.forEach((f) => fd.append('images', f));
      await createCrop(fd);
      setStatus({ type: 'success', msg: t('cf_success') });
      // redirect to farmer dashboard so they see their new crop
      setTimeout(() => nav('/farmer/dashboard'), 900);
    } catch (err) {
      if (err.fields) setErrors(err.fields);
      setStatus({ type: 'error', msg: err.message || t('cf_error') });
    } finally {
      setBusy(false);
    }
  }

  return (
    <>
      {/* Green header */}
      <section className="bg-gradient-to-br from-m1-dark via-m1 to-m1-light py-10 text-white">
        <div className="mx-auto max-w-3xl px-6">
          <h1 className="text-3xl font-bold font-display">{t('cf_title')}</h1>
          <p className="mt-1 text-white/85">{t('cf_sub')}</p>
        </div>
      </section>

      {/* Card overlapping the header */}
      <div className="mx-auto -mt-8 max-w-3xl px-6 pb-16">
        <div className="rounded-xl2 bg-white p-6 shadow-3 sm:p-8">

          {status && (
            <div className={`mb-5 rounded-lg px-4 py-3 text-sm ${
              status.type === 'success'
                ? 'bg-success-bg text-m1-dark'
                : 'bg-danger-bg text-danger-dark'
            }`}>
              {status.msg}
            </div>
          )}

          <form onSubmit={onSubmit} className="space-y-5" noValidate>

            {/* Crop name */}
            <div>
              <label className="mb-1 block text-sm font-medium text-gray-700">
                {t('cf_crop_name')} <Req />
              </label>
              <input
                type="text"
                value={form.cropName}
                onChange={upd('cropName')}
                placeholder={t('cf_crop_name_ph')}
                className={inputCls(errors.cropName)}
                required
              />
              {errors.cropName && <FieldError msg={errors.cropName} />}
            </div>

            {/* Variety (optional) */}
            <div>
              <label className="mb-1 block text-sm font-medium text-gray-700">
                {t('cf_variety')}
              </label>
              <input
                type="text"
                value={form.cropVariety}
                onChange={upd('cropVariety')}
                placeholder={t('cf_variety_ph')}
                className={inputCls()}
              />
            </div>

            {/* Category */}
            <div>
              <label className="mb-1 block text-sm font-medium text-gray-700">
                {t('cf_category')} <Req />
              </label>
              <select
                value={form.categoryId}
                onChange={upd('categoryId')}
                className={inputCls(errors.categoryId)}
                required
              >
                <option value="">{t('cf_category_ph')}</option>
                {categories.map((c) => (
                  <option key={c.category_id} value={c.category_id}>
                    {lang === 'bn' ? (c.category_name_bn || c.category_name) : c.category_name}
                  </option>
                ))}
              </select>
              {errors.categoryId && <FieldError msg={errors.categoryId} />}
            </div>

            {/* Quantity + Unit side by side */}
            <div className="grid gap-4 sm:grid-cols-3">
              <div className="sm:col-span-2">
                <label className="mb-1 block text-sm font-medium text-gray-700">
                  {t('cf_quantity')} <Req />
                </label>
                <input
                  type="number"
                  min="0"
                  step="0.01"
                  value={form.quantity}
                  onChange={upd('quantity')}
                  placeholder="0.00"
                  className={inputCls(errors.quantity)}
                  required
                />
                {errors.quantity && <FieldError msg={errors.quantity} />}
              </div>
              <div>
                <label className="mb-1 block text-sm font-medium text-gray-700">
                  {t('cf_unit')} <Req />
                </label>
                <select
                  value={form.unit}
                  onChange={upd('unit')}
                  className={inputCls(errors.unit)}
                >
                  {UNITS.map((u) => (
                    <option key={u} value={u}>{t(`cf_unit_${u}`)}</option>
                  ))}
                </select>
              </div>
            </div>

            {/* Price per unit */}
            <div>
              <label className="mb-1 block text-sm font-medium text-gray-700">
                {t('cf_price')} <Req />
              </label>
              <div className="relative">
                <span className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-gray-500">৳</span>
                <input
                  type="number"
                  min="0"
                  step="0.01"
                  value={form.pricePerUnit}
                  onChange={upd('pricePerUnit')}
                  placeholder="0.00"
                  className={inputCls(errors.pricePerUnit) + ' pl-8'}
                  required
                />
              </div>
              <p className="mt-1 text-xs text-gray-500">
                {t('cf_price_hint')} {form.unit && `(${t(`cf_per_${form.unit}`)})`}
              </p>
              {errors.pricePerUnit && <FieldError msg={errors.pricePerUnit} />}
            </div>

            {/* Description */}
            <div>
              <label className="mb-1 block text-sm font-medium text-gray-700">
                {t('cf_description')}
              </label>
              <textarea
                value={form.description}
                onChange={upd('description')}
                rows={3}
                placeholder={t('cf_description_ph')}
                className={inputCls()}
              />
            </div>

            {/* Organic checkbox */}
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={form.isOrganic}
                onChange={upd('isOrganic')}
                className="h-4 w-4 rounded border-gray-300 text-m1 focus:ring-m1"
              />
              <span className="text-sm text-gray-700">{t('cf_organic')}</span>
            </label>

            {/* Image upload with previews */}
            <div>
              <label className="mb-2 block text-sm font-medium text-gray-700">
                {t('cf_images')}
              </label>
              <input
                type="file"
                accept="image/jpeg,image/png,image/webp"
                multiple
                onChange={onFiles}
                className="block w-full text-sm text-gray-600 file:mr-3 file:rounded-lg file:border-0 file:bg-m1 file:px-4 file:py-2 file:text-sm file:font-semibold file:text-white hover:file:bg-m1-dark"
              />
              <p className="mt-1 text-xs text-gray-500">{t('cf_images_hint')}</p>

              {previews.length > 0 && (
                <div className="mt-3 grid grid-cols-2 gap-3 sm:grid-cols-4">
                  {previews.map((src, i) => (
                    <div key={i} className="relative group">
                      <img
                        src={src}
                        alt={`preview ${i + 1}`}
                        className="h-24 w-full rounded-lg object-cover border border-gray-200"
                      />
                      <button
                        type="button"
                        onClick={() => removeImage(i)}
                        className="absolute top-1 right-1 rounded-full bg-white/90 p-1 text-xs text-danger-dark opacity-0 group-hover:opacity-100 transition"
                        aria-label="Remove"
                      >
                        ✕
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Submit */}
            <div className="pt-2 flex gap-3">
              <button
                type="submit"
                disabled={busy}
                className="flex-1 rounded-full bg-m1 py-3 text-sm font-semibold text-white hover:bg-m1-dark disabled:opacity-60"
              >
                {busy ? t('cf_submitting') : t('cf_submit')}
              </button>
              <button
                type="button"
                onClick={() => nav('/farmer/dashboard')}
                className="rounded-full border border-gray-200 px-6 py-3 text-sm font-semibold text-gray-600 hover:bg-gray-50"
              >
                {t('cf_cancel')}
              </button>
            </div>
          </form>
        </div>
      </div>
    </>
  );
}

function Req() {
  return <span className="text-danger-dark">*</span>;
}

function FieldError({ msg }) {
  return <p className="mt-1 text-xs text-danger-dark">{msg}</p>;
}

function inputCls(err) {
  return `w-full rounded-lg border px-3 py-2.5 text-sm outline-none transition ${
    err ? 'border-danger-dark focus:border-danger-dark' : 'border-gray-200 focus:border-m1'
  }`;
}
