// StatCard.jsx — one tile in the hero stat row (e.g. "10k+ / Registered farmers").
export default function StatCard({ icon, value, label, tint = 'bg-success-bg' }) {
  return (
    <div className="flex items-center gap-3">
      <div className={`grid h-11 w-11 place-items-center rounded-xl2 ${tint}`}>
        {icon}
      </div>
      <div>
        <div className="text-2xl font-bold font-display text-gray-900">{value}</div>
        <div className="text-sm text-gray-500">{label}</div>
      </div>
    </div>
  );
}
