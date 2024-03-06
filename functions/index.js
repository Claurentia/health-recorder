const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.syncUserPoints = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("no access", "Unauthenticated user");
  }

  const userId = context.auth.uid;
  const newPoints = data.points;
  const usersCollection = admin.firestore().collection("users");
  const userDocRef = usersCollection.doc(userId);

  try {
    const doc = await userDocRef.get();
    if (!doc.exists) {
      await userDocRef.set({
        username: `user_${Math.floor(Math.random() * 9999)}`,
        points: newPoints,
      });
      return {points: newPoints};
    } else {
      const currentPoints = doc.data().points || 0;
      if (newPoints > currentPoints) {
        await userDocRef.update({points: newPoints});
        return {points: newPoints};
      } else {
        return {points: currentPoints};
      }
    }
  } catch (error) {
    console.error("Error syncing user points:", error);
    throw new functions.https.HttpsError("internal", "Failed to sync points.");
  }
});

exports.updateUserPoints = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("no access", "Unauthenticated user");
  }

  const pointsUpdate = data.points;
  const userId = context.auth.uid;

  const userRef = admin.firestore().collection("users").doc(userId);
  const userDoc = await userRef.get();

  if (!userDoc.exists) {
    console.error("User document not found");
    throw new functions.https.HttpsError("not-found", "User doc not found");
  }

  await userRef.update({
    points: admin.firestore.FieldValue.increment(pointsUpdate),
  });

  return {success: true, message: "Points updated"};
});
