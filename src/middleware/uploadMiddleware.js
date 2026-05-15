const multer = require('multer');
const { bucket } = require('../config/gcs');

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = ['image/jpeg', 'image/png', 'image/jpg'];
    if (allowed.includes(file.mimetype)) cb(null, true);
    else cb(new Error('File harus berupa gambar JPG/PNG'), false);
  }
});

const uploadToGCS = (req, res, next) => {
  if (!req.file) return next();

  const fileName = `foto_kejadian/${Date.now()}-${req.file.originalname.replace(/\s+/g, '-')}`;
  const blob = bucket.file(fileName);
  const blobStream = blob.createWriteStream({
    resumable: false,
    contentType: req.file.mimetype,
  });

  blobStream.on('error', (err) => {
    return res.status(500).json({ message: 'Upload ke GCS gagal: ' + err.message });
  });

  blobStream.on('finish', () => {
    req.file.gcsUrl = `https://storage.googleapis.com/${process.env.GCS_BUCKET_NAME}/${fileName}`;
    next();
  });

  blobStream.end(req.file.buffer);
};

module.exports = { upload, uploadToGCS };