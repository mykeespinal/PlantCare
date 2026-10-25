"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteUser = void 0;
const app_1 = require("firebase-admin/app");
const auth_1 = require("firebase-admin/auth");
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
(0, app_1.initializeApp)();
exports.deleteUser = (0, https_1.onCall)(async (request) => {
    const callerUid = request.auth?.uid;
    if (!callerUid) {
        throw new https_1.HttpsError("unauthenticated", "Debes iniciar sesión.");
    }
    const db = (0, firestore_1.getFirestore)();
    const caller = await db.collection("users").doc(callerUid).get();
    if (!caller.exists || caller.data()?.role !== "admin" ||
        caller.data()?.status !== "active") {
        throw new https_1.HttpsError("permission-denied", "Se requiere una cuenta administradora activa.");
    }
    const uid = request.data?.uid;
    if (typeof uid !== "string" || uid.length === 0) {
        throw new https_1.HttpsError("invalid-argument", "El identificador del usuario es obligatorio.");
    }
    if (uid === callerUid) {
        throw new https_1.HttpsError("failed-precondition", "No puedes eliminar tu propia cuenta.");
    }
    const targetRef = db.collection("users").doc(uid);
    const target = await targetRef.get();
    if (!target.exists || target.data()?.ownerAdminUid !== callerUid) {
        throw new https_1.HttpsError("permission-denied", "No puedes eliminar una cuenta que pertenece a otro administrador.");
    }
    if (target.data()?.role === "admin") {
        const managedUsers = await db.collection("users")
            .where("ownerAdminUid", "==", uid)
            .limit(1)
            .get();
        if (!managedUsers.empty) {
            throw new https_1.HttpsError("failed-precondition", "Elimina primero las cuentas administradas por este administrador.");
        }
    }
    await (0, auth_1.getAuth)().deleteUser(uid);
    await targetRef.delete();
    return { deleted: true };
});
