# API Endpoints

## Authentication

| Method | Endpoint |
|---|---|
| POST | /api/auth/register |
| POST | /api/auth/login |
| POST | /api/auth/logout |
| GET | /api/auth/me |

---

## Laporan

| Method | Endpoint |
|---|---|
| POST | /api/laporan |
| GET | /api/laporan |
| GET | /api/laporan/user |
| GET | /api/laporan/:id |
| PUT | /api/laporan/:id |
| PUT | /api/laporan/:id/cancel |
| POST | /api/laporan/:id/foto |

---

## Kategori

| Method | Endpoint |
|---|---|
| GET | /api/kategori |
| POST | /api/kategori |
| PUT | /api/kategori/:id |
| DELETE | /api/kategori/:id |

---

## Penanganan

| Method | Endpoint |
|---|---|
| POST | /api/penanganan |
| GET | /api/penanganan/:laporan_id |
| PUT | /api/penanganan/laporan/:laporan_id |

---

## Riwayat Respon

| Method | Endpoint |
|---|---|
| GET | /api/riwayat-respon/:laporan_id |

---

## Users

| Method | Endpoint |
|---|---|
| GET | /api/users |
| GET | /api/users/:id |
| PUT | /api/users/:id |
| DELETE | /api/users/:id |

---

## Dashboard

| Method | Endpoint |
|---|---|
| GET | /api/dashboard/statistik |
| GET | /api/dashboard/hari-ini |
| GET | /api/dashboard/prioritas-tinggi |
| GET | /api/dashboard/area-rawan |
| GET | /api/dashboard/laporan-masuk |

---

## Maps

| Method | Endpoint |
|---|---|
| GET | /api/maps/active-reports |
| GET | /api/maps/heatmap |

---

## Notifikasi

| Method | Endpoint |
|---|---|
| GET | /api/notifikasi |
| PUT | /api/notifikasi/:id/read |