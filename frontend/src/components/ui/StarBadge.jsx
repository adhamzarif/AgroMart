// StarBadge.jsx — compact rating display (star + score + review count).
export default function StarBadge({ rating, count, size = 'sm' }) {
  if (!count || Number(count) === 0) return null;

  const num = Number(rating).toFixed(1);
  const sizes = {
    sm: 'text-xs px-2 py-0.5',
    md: 'text-sm px-2.5 py-1',
    lg: 'text-base px-3 py-1.5',
  };

  return (
    <span className={`inline-flex items-center gap-1 rounded-full bg-amber-50 font-semibold text-amber-800 ${sizes[size]}`}>
      <span className="text-amber-500">★</span>
      <span>{num}</span>
      <span className="text-amber-600/70">({count})</span>
    </span>
  );
}
