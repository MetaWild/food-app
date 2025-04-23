import { useEffect, useState } from 'react';
import { onAuthStateChanged } from 'firebase/auth';
import { auth } from '../firebaseConfig';

export default function useAuth() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true); // 🔹 added loading

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (firebaseUser) => {
      setUser(firebaseUser);
      setLoading(false); // ✅ done loading
    });
    return () => unsubscribe();
  }, []);

  return { user, loading };
}