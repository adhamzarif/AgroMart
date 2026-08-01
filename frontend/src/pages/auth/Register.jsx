// Register.jsx — farmer/buyer registration form (slice A1).
import { useState } from 'react';
import { register } from '../../api/auth.api.js';

const EMPTY = { fullName: '', phone: '', password: '', email: '', role: 'farmer' };

export default function Register() {
  const [form, setForm] = useState(EMPTY);
  const [fieldErrors, setFieldErrors] = useState({});
  const [status, setStatus] = useState(null); // {type:'success'|'error', msg}
  const [submitting, setSubmitting] = useState(false);

  const update = (k) => (e) => setForm({ ...form, [k]: e.target.value });

  async function onSubmit(e) {
    e.preventDefault();
    setStatus(null);
    setFieldErrors({});
    setSubmitting(true);
    try {
      const res = await register(form);
      setStatus({ type: 'success', msg: `Registered! Welcome, ${res.user.fullName}.` });
      setForm(EMPTY);
    } catch (err) {
      if (err.fields) setFieldErrors(err.fields);
      setStatus({ type: 'error', msg: err.message });
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div style={{ maxWidth: 420, margin: '40px auto', fontFamily: 'system-ui' }}>
      <h1>Create your AgroMart account</h1>

      {status && (
        <p style={{ color: status.type === 'success' ? 'green' : 'crimson' }}>
          {status.msg}
        </p>
      )}

      <form onSubmit={onSubmit} noValidate>
        <Field label="Full name" error={fieldErrors.fullName}>
          <input value={form.fullName} onChange={update('fullName')} />
        </Field>

        <Field label="Phone (01XXXXXXXXX)" error={fieldErrors.phone}>
          <input value={form.phone} onChange={update('phone')} />
        </Field>

        <Field label="Email (optional)" error={fieldErrors.email}>
          <input type="email" value={form.email} onChange={update('email')} />
        </Field>

        <Field label="Password (min 8 chars)" error={fieldErrors.password}>
          <input type="password" value={form.password} onChange={update('password')} />
        </Field>

        <Field label="I am a" error={fieldErrors.role}>
          <select value={form.role} onChange={update('role')}>
            <option value="farmer">Farmer</option>
            <option value="buyer">Buyer</option>
          </select>
        </Field>

        <button type="submit" disabled={submitting} style={{ marginTop: 12 }}>
          {submitting ? 'Creating…' : 'Register'}
        </button>
      </form>
    </div>
  );
}

function Field({ label, error, children }) {
  return (
    <label style={{ display: 'block', marginBottom: 10 }}>
      <div>{label}</div>
      {children}
      {error && <div style={{ color: 'crimson', fontSize: 13 }}>{error}</div>}
    </label>
  );
}
