// Button.jsx — the green pill button in two variants.
export default function Button({ variant = 'solid', children, className = '', ...props }) {
  const base =
    'inline-flex items-center gap-2 rounded-full px-6 py-3 font-semibold transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-m1-light';
  const variants = {
    solid: 'bg-m1 text-white hover:bg-m1-dark',
    outline: 'border border-white/40 text-white hover:bg-white/10',
    ghost: 'text-m1 hover:bg-success-bg',
  };
  return (
    <button className={`${base} ${variants[variant]} ${className}`} {...props}>
      {children}
    </button>
  );
}
