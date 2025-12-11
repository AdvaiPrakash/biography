// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyDI2cbapoZfZBc3Lu_uH2ucCx9dPngBoKU",
  authDomain: "biography-b7be4.firebaseapp.com",
  projectId: "biography-b7be4",
  storageBucket: "biography-b7be4.firebasestorage.app",
  messagingSenderId: "49854212410",
  appId: "1:49854212410:web:cafd8c039046ca89c6c803",
  measurementId: "G-433ML9LTMT"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
const db = getFirestore(app);
const auth = getAuth(app);

export { app, analytics, db, auth };