// Layout.jsx — page shell: Navbar on top, page content, Footer at bottom.
// Wrap any page in <Layout>...</Layout>, or use it once around <Routes> in App.jsx.
import Navbar from './Navbar.jsx';
import Footer from './Footer.jsx';

export default function Layout({ children }) {
  return (
    <div className="flex min-h-screen flex-col">
      <Navbar />
      <main className="flex-1">{children}</main>
      <Footer />
    </div>
  );
}
