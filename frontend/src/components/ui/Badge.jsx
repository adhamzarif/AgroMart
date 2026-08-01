// Badge.jsx — small pill label. Used for category chips ("সবজি") and the "নতুন" tag.
// tone controls the color; use 'category' for the soft-green chips, 'new' for the star badge.
export default function Badge({ tone = 'category', children, className = '' }) {
  const tones = {
    category: 'bg-success-bg text-m1-dark',
    new: 'bg-white text-m1 shadow-1',
    info: 'bg-info-bg text-info-dark',
    warning: 'bg-warning-bg text-warning-dark',
    danger: 'bg-danger-bg text-danger-dark',
    neutral: 'bg-gray-100 text-gray-600',
  };
  return (
    <span
      className={`inline-flex items-center gap-1 rounded-full px-3 py-1 text-xs font-semibold ${tones[tone]} ${className}`}
    >
      {children}
    </span>
  );
}
