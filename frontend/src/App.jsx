import useAuth from './hooks/useAuth';
import AuthPage from './pages/AuthPage';
import HomePage from './pages/HomePage';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';

export default function App() {
  const user = useAuth();

  if (user === undefined) {
    return <div>Loading...</div>; // you can make this a spinner or something later
  }

  return (
    <Router>
      <Routes>
        <Route path="/auth" element={<AuthPage />} />
        <Route path="/" element={user ? <HomePage /> : <Navigate to="/auth" />} />
      </Routes>
    </Router>
  );
}