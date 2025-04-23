import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import AuthPage from './pages/AuthPage';
import HomePage from './pages/HomePage';
import useAuth from './hooks/useAuth';
import CapturePage from './pages/CapturePage';import DailyTrackerPage from './pages/DailyTrackerPage';
import MealDetailPage from './pages/MealDetailPage';

export default function App() {
  const { user, loading } = useAuth();

  if (loading) return <div>Loading...</div>; // 🔄 wait before rendering anything

  return (
    <Router>
      <Routes>
        <Route path="/auth" element={<AuthPage />} />
        <Route path="/" element={user ? <HomePage /> : <Navigate to="/auth" />} />
        <Route path="/capture" element={<CapturePage />} />
        <Route path="/tracker" element={<DailyTrackerPage />} />
        <Route path="/meal/:name" element={<MealDetailPage />} />
      </Routes>
    </Router>
  );
}