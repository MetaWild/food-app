import { auth } from '../firebaseConfig';
import { signOut } from 'firebase/auth';
import { useEffect, useState } from 'react';

export default function HomePage() {
  const [userEmail, setUserEmail] = useState("");

  useEffect(() => {
    if (auth.currentUser) {
      setUserEmail(auth.currentUser.email);
    }
  }, []);

  const handleLogout = async () => {
    try {
      await signOut(auth);
    } catch (err) {
      alert("Failed to log out: " + err.message);
    }
  };

  return (
    <div style={{ padding: 20 }}>
      <h1>Welcome to your Food Tracker App!</h1>
      <p>Signed in as: <strong>{userEmail}</strong></p>
      <p>We'll soon let you track meals, ingredients, and nutrition breakdowns here.</p>
      <button onClick={handleLogout}>Logout</button>
    </div>
  );
}