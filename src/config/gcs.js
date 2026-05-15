const { Storage } = require('@google-cloud/storage');

const storage = new Storage({
  projectId: process.env.GCS_PROJECT_ID,
});

const bucket = storage.bucket(process.env.GCS_BUCKET_NAME);

module.exports = { storage, bucket };