import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

initializeApp();

export const deleteUser = onCall(async (request) => {
  const callerUid = request.auth?.uid;
  if (!callerUid) {
    throw new HttpsError("unauthenticated", "Debes iniciar sesión.");
  }

  const db = getFirestore();
  const caller = await db.collection("users").doc(callerUid).get();
  if (!caller.exists || caller.data()?.role !== "admin" ||
      caller.data()?.status !== "active") {
    throw new HttpsError("permission-denied", "Se requiere una cuenta administradora activa.");
  }

  const uid = request.data?.uid;
  if (typeof uid !== "string" || uid.length === 0) {
    throw new HttpsError("invalid-argument", "El identificador del usuario es obligatorio.");
  }
  if (uid === callerUid) {
    throw new HttpsError("failed-precondition", "No puedes eliminar tu propia cuenta.");
  }

  const targetRef = db.collection("users").doc(uid);
  const target = await targetRef.get();
  if (!target.exists || target.data()?.ownerAdminUid !== callerUid) {
    throw new HttpsError(
      "permission-denied",
      "No puedes eliminar una cuenta que pertenece a otro administrador.",
    );
  }
  if (target.data()?.role === "admin") {
    const managedUsers = await db.collection("users")
      .where("ownerAdminUid", "==", uid)
      .limit(1)
      .get();
    if (!managedUsers.empty) {
      throw new HttpsError(
        "failed-precondition",
        "Elimina primero las cuentas administradas por este administrador.",
      );
    }
  }

  await getAuth().deleteUser(uid);
  await targetRef.delete();
  return { deleted: true };
});
