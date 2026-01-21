import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/Layout';
import Home from './pages/Home';
import PrivacyPolicy from './pages/PrivacyPolicy';
import Terms from './pages/Terms';
import Support from './pages/Support';
import DeleteAccount from './pages/DeleteAccount';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Home />} />
          <Route path="privacy-policy" element={<PrivacyPolicy />} />
          <Route path="terms-and-conditions" element={<Terms />} />
          <Route path="support" element={<Support />} />
          <Route path="delete-account" element={<DeleteAccount />} />

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
