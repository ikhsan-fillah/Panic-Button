const express = require('express');
const router = express.Router();

const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');
const { upload, uploadToGCS } = require('../middleware/uploadMiddleware');

const authController = require('../controllers/authController');
const laporanController = require('../controllers/laporanController');
const kategoriController = require('../controllers/kategoriController');
const penangananController = require('../controllers/penangananController');
const riwayatResponController = require('../controllers/riwayatResponController');
const userController = require('../controllers/userController');
const dashboardController = require('../controllers/dashboardController');
const mapsController = require('../controllers/mapsController');
const notifikasiController = require('../controllers/notifikasiController');


// AUTH
router.post('/auth/register', authController.register);
router.post('/auth/login', authController.login);
router.post('/auth/logout', authMiddleware, roleMiddleware('warga', 'satpam'), authController.logout);
router.get('/auth/me', authMiddleware, roleMiddleware('warga', 'satpam'), authController.me);


// LAPORAN
router.post('/laporan', authMiddleware, roleMiddleware('warga'), laporanController.store);
router.get('/laporan', authMiddleware, roleMiddleware('warga', 'satpam'), laporanController.index);
router.get('/laporan/user', authMiddleware, roleMiddleware('warga'), laporanController.userLaporan);
router.get('/laporan/:id', authMiddleware, roleMiddleware('warga', 'satpam'), laporanController.show);
router.put('/laporan/:id', authMiddleware, roleMiddleware('satpam'), laporanController.update);
router.put('/laporan/:id/cancel', authMiddleware, roleMiddleware('warga'), laporanController.cancel);
router.post('/laporan/:id/foto', authMiddleware, roleMiddleware('warga'), upload.single('foto'), uploadToGCS, laporanController.uploadFoto);


// KATEGORI
router.get('/kategori', authMiddleware, roleMiddleware('warga', 'satpam'), kategoriController.index);
router.post('/kategori', authMiddleware, roleMiddleware('satpam'), kategoriController.store);
router.put('/kategori/:id', authMiddleware, roleMiddleware('satpam'), kategoriController.update);
router.delete('/kategori/:id', authMiddleware, roleMiddleware('satpam'), kategoriController.destroy);


// PENANGANAN
router.post('/penanganan', authMiddleware, roleMiddleware('satpam'), penangananController.store);
router.get('/penanganan/:laporan_id', authMiddleware, roleMiddleware('warga', 'satpam'), penangananController.show);
router.put('/penanganan/laporan/:laporan_id', authMiddleware, roleMiddleware('satpam'), penangananController.updateByLaporan);


// RIWAYAT RESPON
router.get('/riwayat-respon/:laporan_id', authMiddleware, roleMiddleware('satpam'), riwayatResponController.show);


// USERS
router.get('/users', authMiddleware, roleMiddleware('satpam'), userController.index);
router.get('/users/:id', authMiddleware, roleMiddleware('satpam'), userController.show);
router.put('/users/:id', authMiddleware, roleMiddleware('satpam'), userController.update);
router.delete('/users/:id', authMiddleware, roleMiddleware('satpam'), userController.destroy);


// DASHBOARD
router.get('/dashboard/statistik', authMiddleware, roleMiddleware('satpam'), dashboardController.statistik);
router.get('/dashboard/hari-ini', authMiddleware, roleMiddleware('satpam'), dashboardController.hariIni);
router.get('/dashboard/prioritas-tinggi', authMiddleware, roleMiddleware('satpam'), dashboardController.prioritasTinggi);
router.get('/dashboard/area-rawan', authMiddleware, roleMiddleware('satpam'), dashboardController.areaRawan);
router.get('/dashboard/laporan-masuk', authMiddleware, roleMiddleware('satpam'), dashboardController.laporanMasuk);


// MAPS
router.get('/maps/active-reports', authMiddleware, roleMiddleware('satpam'), mapsController.activeReports);
router.get('/maps/heatmap', authMiddleware, roleMiddleware('satpam'), mapsController.heatmap);


// NOTIFIKASI
router.get('/notifikasi', authMiddleware, roleMiddleware('warga', 'satpam'), notifikasiController.index);
router.put('/notifikasi/:id/read', authMiddleware, roleMiddleware('warga', 'satpam'), notifikasiController.markRead);

module.exports = router;