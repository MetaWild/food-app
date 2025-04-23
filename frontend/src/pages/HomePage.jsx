import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { auth } from '../firebaseConfig';
import { signOut } from 'firebase/auth';
import axios from 'axios';

export default function HomePage() {
    const [meals, setMeals] = useState([]);

    useEffect(() => {
        const fetchMeals = async () => {
          const user = auth.currentUser;
          if (!user) return;
          const idToken = await user.getIdToken();
          const today = new Date().toLocaleDateString('en-CA');
          
          const res = await axios.get(`http://localhost:8000/meals`, {
            params: { userId: user.uid, date: today },
            headers: { Authorization: `Bearer ${idToken}` },
            withCredentials: false,
          });
          
            console.log("Fetched meals:", res.data); // 🔍 Add this
          setMeals(res.data);
        };
      
        fetchMeals();
      }, []);

  const navigate = useNavigate();

  const handleLogout = async () => {
    try {
      await signOut(auth);
      navigate('/auth');
    } catch (err) {
      alert('Error logging out: ' + err.message);
    }
  };

  const handleDailyTracker = () => {
    navigate('/tracker');
  };

  const handleMealClick = (meal) => {
    navigate(`/meal/${encodeURIComponent(meal.title)}`, { state: { meal } });
  };

  return (
    <div style={styles.page}>
      <div style={styles.card}>
        {/* Top Bar */}
        <div style={styles.topBar}>
          <button onClick={handleLogout} style={styles.linkButton}>
            Logout
          </button>
          <h2 style={styles.title}>Home</h2>
          <button onClick={handleDailyTracker} style={styles.linkButton}>
            Daily Tracker
          </button>
        </div>

        {/* Meal List */}
        <div style={styles.mealList}>
        {meals.map((meal, index) => (
            meal.title && meal.nutrition ? (
            <button
                key={index}
                style={styles.mealButton}
                onClick={() => handleMealClick(meal)}
            >
      {meal.title}
    </button>
  ) : null  // skip invalid or error objects
))}
        </div>
        {/* Camera Button */}
        <button onClick={() => navigate('/capture')} style={styles.cameraButton}>
        📷
        </button>
      </div>
    </div>
  );
}

const styles = {
  page: {
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
    width: '100%',
    maxWidth: '420px',
    height: '90vh',
    display: 'flex',
    flexDirection: 'column',
    borderRadius: '12px',
    boxShadow: '0 4px 20px rgba(0, 0, 0, 0.1)',
    padding: '16px',
    position: 'relative',
  },
  topBar: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: '16px',
  },
  title: {
    fontSize: '20px',
    fontWeight: 'bold',
    margin: 0,
  },
  linkButton: {
    backgroundColor: '#3f51b5',
    color: '#ffffff',
    fontWeight: 'bold',
    borderRadius: '16px',
    cursor: 'pointer',
    fontSize: '16px',
    border: '2px solid #3f51b5',
    padding: '4px 8px',
  },
  mealList: {
    flex: 1,
    overflowY: 'auto',
    display: 'flex',
    flexDirection: 'column',
    gap: '10px',
    paddingTop: '10px',
  },
  mealButton: {
    padding: '14px',
    borderRadius: '8px',
    border: '1px solid #3f51b5',
    backgroundColor: '#f7f7f7',
    fontSize: '16px',
    fontWeight: 'bold',
    color: '#3f51b5',
    textAlign: 'left',
    cursor: 'pointer',
  },
  cameraButton: {
    position: 'absolute',
    bottom: '20px',
    left: '50%',
    transform: 'translateX(-50%)',
    backgroundColor: '#3f51b5',
    color: 'white',
    border: 'none',
    borderRadius: '50%',
    width: '60px',
    height: '60px',
    fontSize: '28px',
    boxShadow: '0 4px 12px rgba(0, 0, 0, 0.2)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    cursor: 'pointer',
  }
};