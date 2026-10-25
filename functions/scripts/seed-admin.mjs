import { applicationDefault, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore } from "firebase-admin/firestore";

const email = "admin@plantas.com";
const password = process.env.ADMIN_PASSWORD;

if (!process.env.GOOGLE_APPLICATION_CREDENTIALS &&
    !process.env.FIREBASE_CONFIG &&
    !process.env.GCLOUD_PROJECT &&
    !process.env.FIREBASE_PROJECT_ID) {
  throw new Error("Define las credenciales ADC y el proyecto Firebase antes de ejecutar la semilla.");
}

initializeApp({ credential: applicationDefault() });

const auth = getAuth();
let user;
try {
  user = await auth.getUserByEmail(email);
} catch (error) {
  if (error.code !== "auth/user-not-found") throw error;
  if (!password || password.length < 12) {
    throw new Error("Define ADMIN_PASSWORD con al menos 12 caracteres para crear la cuenta inicial.");
  }
  user = await auth.createUser({ email, password, displayName: "Administrador Plantas" });
}

const db = getFirestore();
await db.collection("users").doc(user.uid).set({
  uid: user.uid,
  nombre: "Administrador",
  apellidos: "Plantas",
  email,
  role: "admin",
  status: "active",
  ownerAdminUid: user.uid,
  createdAt: FieldValue.serverTimestamp(),
}, { merge: true });
await db.collection("settings").doc("admin").set({
  ownerAdminUid: user.uid,
}, { merge: true });

const users = await db.collection("users").get();
let batch = db.batch();
let pendingUpdates = 0;
for (const profile of users.docs) {
  if (typeof profile.data().ownerAdminUid === "string" &&
      profile.data().ownerAdminUid.length > 0) {
    continue;
  }
  batch.update(profile.ref, { ownerAdminUid: user.uid });
  pendingUpdates += 1;
  if (pendingUpdates === 450) {
    await batch.commit();
    batch = db.batch();
    pendingUpdates = 0;
  }
}
if (pendingUpdates > 0) await batch.commit();

console.log(`Cuenta administradora inicial preparada: ${email} (${user.uid})`);
console.log("Las cuentas existentes sin administrador asignado se asignaron a la cuenta inicial.");
