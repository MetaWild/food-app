import { useRef, useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { auth } from '../firebaseConfig';

export default function CapturePage() {
  const videoRef = useRef(null);
  const canvasRef = useRef(null);
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);

  const startCamera = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: { ideal: 'environment' } }
      });
      videoRef.current.srcObject = stream;
    } catch (err1) {
      console.warn("Rear camera not available, trying fallback...", err1);
      try {
        const stream = await navigator.mediaDevices.getUserMedia({
          video: true
        });
        videoRef.current.srcObject = stream;
      } catch (err2) {
        alert("Camera access denied or not supported.");
        console.error("Failed to access any camera:", err2);
      }
    }
  };

  useEffect(() => {
    startCamera();
    return () => {
      if (videoRef.current?.srcObject) {
        videoRef.current.srcObject.getTracks().forEach(track => track.stop());
      }
    };
  }, []);

  // ✅ Handle capture and API call
  const captureAndSend = async () => {
    const canvas = canvasRef.current;
    const video = videoRef.current;
    const context = canvas.getContext('2d');
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    context.drawImage(video, 0, 0, canvas.width, canvas.height);
    const imageData = canvas.toDataURL('image/jpeg');
  
    try {
      setLoading(true);
  
      const analyzeRes = await axios.post('https://food-app-zpft.onrender.com/analyze-image', {
        image: imageData,
      });
      const mealData = analyzeRes.data;
  
      const user = auth.currentUser;
      const idToken = await user.getIdToken();
  
      const today = new Date().toLocaleDateString('en-CA'); 
        await axios.post("https://food-app-zpft.onrender.com/save-meal/save-meal", {
        ...mealData,
        date: today
        }, { headers: { Authorization: `Bearer ${idToken}` } });
  
      navigate('/');
    } catch (err) {
      console.error(err);
      alert('Error analyzing or saving meal.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={styles.container}>
      <video ref={videoRef} style={styles.video} autoPlay playsInline />
      <canvas ref={canvasRef} style={{ display: 'none' }} />
      <button onClick={captureAndSend} style={styles.captureButton}>
        {loading ? 'Analyzing...' : 'Capture'}
      </button>
    </div>
  );
}

const styles = {
  container: {
    background: '#000',
    height: '100vh',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
  },
  video: {
    width: '100%',
    maxHeight: '80vh',
    borderRadius: '8px',
  },
  captureButton: {
    marginTop: '20px',
    padding: '12px 24px',
    fontSize: '18px',
    borderRadius: '6px',
    backgroundColor: '#3f51b5',
    color: '#fff',
    border: 'none',
    cursor: 'pointer',
  }
};