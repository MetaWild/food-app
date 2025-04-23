import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyDQKZcWC40YomDtCbpvo3jj22aRhAhFfeA",
  authDomain: "food-app-536ba.firebaseapp.com",
  projectId: "food-app-536ba",
  storageBucket: "food-app-536ba.firebasestorage.app",
  messagingSenderId: "962291467131",
  appId: "1:962291467131:web:553c8dd4ec549921b873de",
  measurementId: "G-4PN0ZCMV9W"
};

const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
export const auth = getAuth(app);
