import { useNavigate, useLocation, useParams } from 'react-router-dom';

export default function MealDetailPage() {
  const { name } = useParams();
  const navigate = useNavigate();
  const { state } = useLocation();
  const meal = state?.meal;

  if (!meal) {
    return (
      <div style={styles.page}>
        <div style={styles.card}>
          <button onClick={() => navigate('/')} style={styles.backButton}>← Back</button>
          <p>No meal data provided.</p>
        </div>
      </div>
    );
  }

  return (
    <div style={styles.page}>
      <div style={styles.card}>
        <div style={styles.header}>
          <button onClick={() => navigate('/')} style={styles.backButton}>← Back</button>
          <h2 style={styles.title}>{meal.title}</h2>
        </div>

        <div style={styles.ingredientList}>
          {meal.nutrition.map((item, index) => (
            <div key={index} style={styles.ingredientCard}>
              <div style={styles.ingredientTop}>
                <strong>{item.name}</strong>
                <span>{item.calories} kcal</span>
              </div>
              <div style={styles.nutrients}>
                <span>Protein: {item.protein}g</span>
                <span>Fat: {item.fat}g</span>
                <span>Carbs: {item.carbs}g</span>
              </div>
            </div>
          ))}
        </div>
      </div>
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
    marginBottom: '10px',
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
  ingredientList: {
    display: 'flex',
    flexDirection: 'column',
    gap: '12px',
  },
  ingredientCard: {
    padding: '12px',
    border: '1px solid #ddd',
    borderRadius: '8px',
    backgroundColor: '#f9f9f9',
  },
  ingredientTop: {
    display: 'flex',
    justifyContent: 'space-between',
    marginBottom: '8px',
  },
  nutrients: {
    display: 'flex',
    justifyContent: 'space-between',
    fontSize: '14px',
  },
};