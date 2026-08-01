// validate.js — input validation helpers.
// Ports from: core/Helpers.php (is_valid_phone, clean_str).
// Fix: phone regex is 01[3-9] (matches SMS provider), not the looser 01[0-9]
// that let un-textable numbers register in the old code.

export function isValidPhone(phone) {
  return /^01[3-9]\d{8}$/.test(phone);
}

export function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

export function cleanStr(s) {
  if (typeof s !== 'string') return '';
  return s.trim();
}

/**
 * Validate a registration payload. Returns { ok, errors, value }.
 * Keeps the rules in one place so controller stays thin.
 */
export function validateRegistration(body) {
  const errors = {};
  const fullName = cleanStr(body.fullName);
  const phone = cleanStr(body.phone);
  const password = body.password ?? '';
  const email = body.email ? cleanStr(body.email) : null;
  const role = cleanStr(body.role);

  if (fullName.length < 2) errors.fullName = 'Full name is required';
  if (!isValidPhone(phone)) errors.phone = 'Enter a valid Bangladeshi phone (01XXXXXXXXX)';
  if (password.length < 8) errors.password = 'Password must be at least 8 characters';
  if (email && !isValidEmail(email)) errors.email = 'Enter a valid email';
  if (!['farmer', 'buyer'].includes(role)) errors.role = 'Choose farmer or buyer';

  return {
    ok: Object.keys(errors).length === 0,
    errors,
    value: { fullName, phone, password, email, role },
  };
}
