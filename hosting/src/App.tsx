import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/Layout';
import Home from './pages/Home';
import PrivacyPolicy from './pages/PrivacyPolicy';
import Terms from './pages/Terms';
import Support from './pages/Support';

// Temporary placeholder components until files are created
// const Home = () => <div className="p-10"><h1>Home Page</h1></div>;
// const PrivacyPolicy = () => <div className="p-10"><h1>Privacy Policy</h1></div>;
// const Terms = () => <div className="p-10"><h1>Terms</h1></div>;
// const Support = () => <div className="p-10"><h1>Support</h1></div>;

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Home />} />
          <Route path="privacy-policy" element={<PrivacyPolicy />} />
          <Route path="terms-and-conditions" element={<Terms />} />
          <Route path="support" element={<Support />} />

          {/* Redirects for common typos or old links */}
          <Route path="privacy" element={<Navigate to="/privacy-policy" replace />} />
          <Route path="terms" element={<Navigate to="/terms-and-conditions" replace />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
