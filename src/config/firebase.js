const admin = require('firebase-admin');
require('dotenv').config();

function normalizePrivateKey(serviceAccount) {
  if (serviceAccount && serviceAccount.private_key) {
    serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, '\n');
  }
  return serviceAccount;
}

function buildCredential() {
  if (process.env.FIREBASE_SERVICE_ACCOUNT_BASE64) {
    const jsonString = Buffer.from(
      process.env.FIREBASE_SERVICE_ACCOUNT_BASE64,
      'base64'
    ).toString('utf8');

    return admin.credential.cert(normalizePrivateKey(JSON.parse(jsonString)));
  }

  if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    return admin.credential.cert(
      normalizePrivateKey(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON))
    );
  }

  // Dipakai saat deploy di Google Cloud Run/App Engine/Compute Engine
  // dengan service account yang sudah diberi akses Firebase.
  return admin.credential.applicationDefault();
}

if (!admin.apps.length) {
  admin.initializeApp({
    credential: buildCredential(),
    projectId: process.env.FIREBASE_PROJECT_ID || undefined,
  });

  // Supaya field undefined dari object JavaScript tidak membuat request Firestore gagal.
  admin.firestore().settings({ ignoreUndefinedProperties: true });
}

module.exports = {
  admin,
  firestore: admin.firestore(),
  messaging: admin.messaging(),
  FieldValue: admin.firestore.FieldValue,
};
