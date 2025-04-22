import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { auth } from '../firebaseConfig';
import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signInWithPopup,
  GoogleAuthProvider,
} from 'firebase/auth';

export default function AuthPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLogin, setIsLogin] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    if (auth.currentUser) {
      navigate('/');
    }
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (isLogin) {
        await signInWithEmailAndPassword(auth, email, password);
      } else {
        await createUserWithEmailAndPassword(auth, email, password);
      }
      navigate('/');
    } catch (err) {
      alert(err.message);
    }
  };

  const handleGoogleLogin = async () => {
    const provider = new GoogleAuthProvider();
    try {
      await signInWithPopup(auth, provider);
      navigate('/');
    } catch (err) {
      alert(err.message);
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.card}>
        <h2 style={styles.title}>{isLogin ? 'Login' : 'Register'}</h2>
        <form onSubmit={handleSubmit} style={styles.form}>
          <input
            placeholder="Email"
            value={email}
            onChange={e => setEmail(e.target.value)}
            style={styles.input}
            required
          />
          <input
            placeholder="Password"
            type="password"
            value={password}
            onChange={e => setPassword(e.target.value)}
            style={styles.input}
            required
          />
          <button type="submit" style={styles.button}>
            {isLogin ? 'Login' : 'Register'}
          </button>
        </form>

        <button onClick={handleGoogleLogin} style={styles.googleButton}>
        <img
            src="https://developers.google.com/identity/images/g-logo.png"
            alt="Google logo"
            style={styles.googleIcon}
        />
        Continue with Google
        </button>

        <p style={styles.switchText}>
          {isLogin ? "Don't have an account?" : 'Already have an account?'}{' '}
          <span
            onClick={() => setIsLogin(!isLogin)}
            style={styles.link}
          >
            {isLogin ? 'Register' : 'Login'}
          </span>
        </p>
      </div>
    </div>
  );
}

const styles = {
    container: {
      backgroundColor: '#ffffff',
      color: '#000000',
      minHeight: '100vh',
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      padding: '20px',
      fontFamily: 'sans-serif',
    },
    card: {
      background: '#fff',
      padding: '30px 40px',
      borderRadius: '12px',
      boxShadow: '0 4px 20px rgba(0, 0, 0, 0.1)',
      width: '100%',
      maxWidth: '400px',
      textAlign: 'center',
        border: '1px solid #ccc',
        borderRadius: '8px',
        boxShadow: '0 4px 8px rgba(0, 0, 0, 0.1)',
    },
    title: {
      marginBottom: '20px',
      fontSize: '24px',
    },
    form: {
      display: 'flex',
      flexDirection: 'column',
      gap: '12px',
    },
    input: {
      padding: '12px',
      fontSize: '16px',
      borderRadius: '6px',
      border: '1px solid #ccc',
    },
    button: {
      padding: '12px',
      fontSize: '16px',
      borderRadius: '6px',
      border: 'none',
      backgroundColor: '#3f51b5',
      color: '#fff',
      cursor: 'pointer',
      marginTop: '10px',
    },
    googleButton: {
      marginTop: '15px',
      padding: '12px',
      fontSize: '16px',
      borderRadius: '6px',
      border: '1px solid #ccc',
      backgroundColor: '#fff',
      cursor: 'pointer',
    },
    googleIcon: {
        width: '20px',
        height: '20px',
        marginRight: '10px',
        verticalAlign: 'middle',
        paddingRight: '5px',
      },
    switchText: {
      marginTop: '15px',
      fontSize: '14px',
    },
    link: {
      color: '#3f51b5',
      fontWeight: 'bold',
      cursor: 'pointer',
    },
  };