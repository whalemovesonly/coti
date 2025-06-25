const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors");
admin.initializeApp();

const corsHandler = cors({ origin: true }); // Allow all origins for dev

exports.createUserWithRole = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    try {
      const idToken = req.headers.authorization?.split("Bearer ")[1];
      if (!idToken) {
        return res.status(401).json({ error: "Missing Authorization token" });
      }

      const decoded = await admin.auth().verifyIdToken(idToken);
      const uid = decoded.uid;

      const adminDoc = await admin.firestore().collection("users").doc(uid).get();
      if (!adminDoc.exists || adminDoc.data().role !== "admin") {
        return res.status(403).json({ error: "Only admins can create users" });
      }

      const { email, password, role } = req.body;

      const newUser = await admin.auth().createUser({ email, password });

      await admin.firestore().collection("users").doc(newUser.uid).set({
        email,
        role,
        createdAt: new Date().toISOString(),
      });

      return res.status(200).json({ uid: newUser.uid });
    } catch (error) {
      console.error("🔥 Error:", error);
      return res.status(500).json({ error: error.message });
    }
  });
});