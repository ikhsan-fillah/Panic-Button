import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getMessaging } from 'firebase/messaging';

const firebaseConfig = {
  apiKey: "AIzaSyC3nY6ySOOzfGeA3IlsJFgGGzE9HY3lwIY",
  authDomain: "kelas-if-b-kelompok-16.firebaseapp.com",
  projectId: "kelas-if-b-kelompok-16",
  storageBucket: "kelas-if-b-kelompok-16.firebasestorage.app",
  messagingSenderId: "311142907128",
  appId: "1:311142907128:web:4668165205f0a1cb78cf0d",
  measurementId: "G-MP2SHXQ4ZB"
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
export const messaging = getMessaging(app);