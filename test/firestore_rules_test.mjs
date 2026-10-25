import { readFile } from "node:fs/promises";
import { after, before, test } from "node:test";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  Bytes,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
} from "firebase/firestore";

let environment;

before(async () => {
  environment = await initializeTestEnvironment({
    projectId: "demo-plantas",
    firestore: {
      host: "127.0.0.1",
      port: 8080,
      rules: await readFile(new URL("../firestore.rules", import.meta.url), "utf8"),
    },
  });
  await environment.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "users/user-1"), {
      uid: "user-1",
      role: "user",
      status: "active",
      email: "user@example.com",
      ownerAdminUid: "admin-1",
    });
    await setDoc(doc(db, "users/user-2"), {
      uid: "user-2",
      role: "user",
      status: "active",
      email: "other@example.com",
    });
    await setDoc(doc(db, "users/inactive-user"), {
      uid: "inactive-user",
      role: "user",
      status: "inactive",
      email: "inactive@example.com",
    });
    await setDoc(doc(db, "users/admin-1"), {
      uid: "admin-1",
      role: "admin",
      status: "active",
      email: "admin@example.com",
      ownerAdminUid: "admin-1",
    });
    await setDoc(doc(db, "users/admin-2"), {
      uid: "admin-2",
      role: "admin",
      status: "active",
      email: "admin-2@example.com",
      ownerAdminUid: "admin-1",
    });
    await setDoc(doc(db, "users/other-admin-user"), {
      uid: "other-admin-user",
      role: "user",
      status: "active",
      email: "other-admin-user@example.com",
      ownerAdminUid: "admin-2",
    });
    await setDoc(doc(db, "settings/admin"), { ownerAdminUid: "admin-1" });
    await setDoc(doc(db, "recipes/published"), { published: true });
    await setDoc(doc(db, "recipes/draft"), { published: false });
  });
});

after(async () => {
  await environment?.cleanup();
});

test("users read only published recipes and cannot grant themselves admin", async () => {
  const db = environment.authenticatedContext("user-1").firestore();
  const registeringUser = environment
    .authenticatedContext("new-user", { email: "new@example.com" })
    .firestore();
  await assertSucceeds(getDoc(doc(registeringUser, "settings/admin")));
  await assertSucceeds(
    setDoc(doc(registeringUser, "users/new-user"), {
      uid: "new-user",
      role: "user",
      status: "active",
      email: "new@example.com",
      ownerAdminUid: "admin-1",
      nombre: "Nuevo",
      apellidos: "Usuario",
      createdAt: new Date(),
    }),
  );
  const forgedRegistration = environment
    .authenticatedContext("forged-registration", { email: "new@example.com" })
    .firestore();
  await assertFails(
    setDoc(doc(forgedRegistration, "users/forged-registration"), {
      uid: "forged-registration",
      role: "user",
      status: "active",
      email: "new@example.com",
      ownerAdminUid: "admin-2",
      nombre: "Nuevo",
      apellidos: "Usuario",
      createdAt: new Date(),
    }),
  );
  await assertSucceeds(getDoc(doc(db, "recipes/published")));
  await assertFails(getDoc(doc(db, "recipes/draft")));
  await assertSucceeds(
    getDocs(query(collection(db, "recipes"), where("published", "==", true))),
  );
  await assertFails(getDocs(collection(db, "recipes")));
  await assertFails(updateDoc(doc(db, "users/user-1"), { role: "admin" }));
  await assertFails(
    setDoc(doc(db, "users/attacker"), {
      uid: "attacker",
      role: "admin",
      status: "active",
      email: "attacker@example.com",
    }),
  );
  await assertFails(setDoc(doc(db, "recipes/attacker"), { published: true }));
  await assertFails(setDoc(doc(db, "categories/attacker"), { name: "Test" }));
});

test("favorites are private to each active user and remain writable", async () => {
  const ownerDb = environment.authenticatedContext("user-1").firestore();
  const otherDb = environment.authenticatedContext("user-2").firestore();
  const favorite = doc(ownerDb, "users/user-1/favorites/published");
  await assertSucceeds(setDoc(favorite, { createdAt: new Date() }));
  await assertSucceeds(getDoc(favorite));
  await assertFails(
    setDoc(doc(ownerDb, "users/user-1/favorites/draft"), {
      createdAt: new Date(),
    }),
  );
  await assertFails(getDoc(doc(otherDb, "users/user-1/favorites/published")));
  await assertFails(
    setDoc(doc(otherDb, "users/user-1/favorites/published"), {
      createdAt: new Date(),
    }),
  );
  await assertSucceeds(deleteDoc(favorite));
  const inactiveDb = environment
    .authenticatedContext("inactive-user")
    .firestore();
  await assertFails(
    setDoc(doc(inactiveDb, "users/inactive-user/favorites/published"), {
      createdAt: new Date(),
    }),
  );
});

test("administrators can publish or withdraw recipes", async () => {
  const db = environment.authenticatedContext("admin-1").firestore();
  await assertSucceeds(updateDoc(doc(db, "recipes/draft"), { published: true }));
  await assertSucceeds(getDoc(doc(db, "recipes/draft")));
  await assertSucceeds(updateDoc(doc(db, "recipes/published"), { published: false }));
  await assertSucceeds(setDoc(doc(db, "categories/new"), { name: "Nueva" }));
  await assertSucceeds(
    setDoc(doc(db, "recipes/with-image"), {
      published: true,
      imageBytes: Bytes.fromUint8Array(new Uint8Array(700 * 1024)),
    }),
  );
  await assertFails(
    setDoc(doc(db, "recipes/oversized-image"), {
      published: true,
      imageBytes: Bytes.fromUint8Array(new Uint8Array(700 * 1024 + 1)),
    }),
  );
});

test("administrators can only manage accounts assigned to their tenant", async () => {
  const db = environment.authenticatedContext("admin-1").firestore();
  await assertSucceeds(getDoc(doc(db, "users/admin-1")));
  await assertSucceeds(getDoc(doc(db, "users/user-1")));
  await assertFails(getDoc(doc(db, "users/other-admin-user")));
  await assertSucceeds(
    getDocs(
      query(collection(db, "users"), where("ownerAdminUid", "==", "admin-1")),
    ),
  );
  await assertFails(getDocs(collection(db, "users")));
  const childDb = environment.authenticatedContext("admin-2").firestore();
  await assertSucceeds(getDoc(doc(childDb, "users/admin-2")));
  await assertSucceeds(getDoc(doc(childDb, "users/other-admin-user")));
  await assertFails(getDoc(doc(childDb, "users/user-1")));
  await assertSucceeds(
    getDocs(
      query(collection(childDb, "users"), where("ownerAdminUid", "==", "admin-2")),
    ),
  );
  await assertSucceeds(
    setDoc(doc(db, "users/created-by-admin"), {
      uid: "created-by-admin",
      role: "admin",
      status: "active",
      email: "created@example.com",
      ownerAdminUid: "admin-1",
    }),
  );
  await assertFails(
    setDoc(doc(db, "users/forged-owner"), {
      uid: "forged-owner",
      role: "user",
      status: "active",
      email: "forged@example.com",
      ownerAdminUid: "admin-2",
    }),
  );
  await assertSucceeds(
    updateDoc(doc(db, "users/user-1"), { status: "inactive" }),
  );
  await assertFails(
    updateDoc(doc(db, "users/other-admin-user"), { status: "inactive" }),
  );
  await assertFails(deleteDoc(doc(db, "users/other-admin-user")));
});
