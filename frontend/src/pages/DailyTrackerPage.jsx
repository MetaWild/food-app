import { useNavigate } from 'react-router-dom';
import { useEffect, useState } from 'react';
import { auth } from '../firebaseConfig';
import axios from 'axios';

export default function DailyTrackerPage() {
  const navigate = useNavigate();
  const [totals, setTotals] = useState(null);

  useEffect(() => {
    const fetchMealsAndSum = async () => {
      try {
        const user = auth.currentUser;
        if (!user) return;

        const idToken = await user.getIdToken();
        const today = new Date().toLocaleDateString('en-CA');

        const res = await axios.get("https://food-app-zpft.onrender.com/meals", {
          params: { userId: user.uid, date: today },
          headers: { Authorization: `Bearer ${idToken}` },
        });

        const meals = res.data;
        const totals = meals.reduce(
          (sum, meal) => {
            if (meal.total) {
              sum.calories += meal.total.calories || 0;
              sum.protein += meal.total.protein || 0;
              sum.carbs += meal.total.carbs || 0;
              sum.fats += meal.total.fat || 0;
            }
            return sum;
          },
          { calories: 0, protein: 0, carbs: 0, fats: 0 }
        );

        setTotals(totals);
      } catch (err) {
        console.error("Failed to load meals:", err);
      }
    };

    fetchMealsAndSum();
  }, []);

  return (
    <div style={styles.page}>
      <div style={styles.card}>
        <div style={styles.header}>
          <button onClick={() => navigate('/')} style={styles.backButton}>← Back</button>
          <h2 style={styles.title}>Daily Tracker</h2>
        </div>

        {totals ? (
          <div style={styles.statsList}>
            <Stat label="Total Calories" value={`${totals.calories} kcal`} />
            <Stat label="Protein" value={`${totals.protein} g`} />
            <Stat label="Carbs" value={`${totals.carbs} g`} />
            <Stat label="Fats" value={`${totals.fats} g`} />
          </div>
        ) : (
          <p style={{ textAlign: 'center' }}>Loading...</p>
        )}
      </div>
    </div>
  );
}

function Stat({ label, value }) {
  return (
    <div style={styles.statRow}>
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  );
}

const styles = {
  page: {
    backgroundColor: '#ffffff',
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
    borderRadius: '12px',
    boxShadow: '0 4px 20px rgba(0, 0, 0, 0.1)',
    padding: '24px',
    display: 'flex',
    flexDirection: 'column',
    gap: '16px',
  },
  header: {
    position: 'relative',
    height: '40px',
    marginBottom: '20px',
  },
  backButton: {
    position: 'absolute',
    left: '0',
    top: '0',
    bottom: '0',
    background: 'none',
    border: 'none',
    fontSize: '16px',
    color: '#3f51b5',
    cursor: 'pointer',
  },
  title: {
    position: 'absolute',
    left: '50%',
    top: '50%',
    transform: 'translate(-50%, -50%)',
    fontSize: '20px',
    margin: 0,
  },
  statsList: {
    marginTop: '20px',
    display: 'flex',
    flexDirection: 'column',
    gap: '14px',
  },
  statRow: {
    display: 'flex',
    justifyContent: 'space-between',
    fontSize: '18px',
    padding: '10px 0',
    borderBottom: '1px solid #eee',
  },
};