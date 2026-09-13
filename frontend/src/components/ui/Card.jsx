// Card.jsx — generic white rounded container with soft shadow.
// The base surface for product tiles, dashboard widgets, forms, etc.
export default function Card({ children, className = '', hover = false, ...props }) {
  return (
    <div
      className={`rounded-xl2 bg-white shadow-2 ${
        hover ? 'transition-shadow hover:shadow-4' : ''
      } ${className}`}
      {...props}
    >
      {children}
    </div>
  );
}
