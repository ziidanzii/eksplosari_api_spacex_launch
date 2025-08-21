
# 🚀 Eksplorasi API SpaceX Launch

Aplikasi Flutter untuk menampilkan daftar peluncuran roket **SpaceX** dengan memanfaatkan [SpaceX API v5](https://api.spacexdata.com/v5/launches).
Aplikasi ini mendukung **filter berdasarkan tahun, bulan, dan status sukses peluncuran**, serta detail informasi setiap misi.

## 📸 Preview

(Tambahkan screenshot aplikasi di sini agar lebih menarik, contoh `assets/screenshot1.png`)

---

## ✨ Fitur Utama

* Menampilkan daftar semua peluncuran **SpaceX** dari API resmi.
* **Filter dinamis** berdasarkan:

  * Status keberhasilan peluncuran (Sukses/Gagal).
  * Tahun peluncuran.
  * Bulan peluncuran.
* Halaman detail misi dengan informasi:

  * Nama misi
  * Status (Sukses/Gagal)
  * Tanggal peluncuran
  * Rocket ID
  * Deskripsi misi
* UI modern dengan tema **dark mode** dan **gradient background**.

---

## 🛠️ Teknologi yang Digunakan

* [Flutter](https://flutter.dev/)
* [Dart](https://dart.dev/)
* [http](https://pub.dev/packages/http) → untuk request API
* [SpaceX API](https://github.com/r-spacex/SpaceX-API)

---

## 🚀 Instalasi & Menjalankan Proyek

1. Clone repository ini:

   ```bash
   git clone https://github.com/ziidanzii/eksplosari_api_spacex_launch.git
   ```
2. Masuk ke folder project:

   ```bash
   cd eksplosari_api_spacex_launch
   ```
3. Install dependencies:

   ```bash
   flutter pub get
   ```
4. Jalankan aplikasi:

   ```bash
   flutter run
   ```

---

## 📂 Struktur Proyek (Singkat)

```
lib/
 ├── main.dart             # Entry point aplikasi
---

## 🔮 Pengembangan Selanjutnya

* [ ] Tambahkan gambar patch misi dari API (`links.patch.small`)
* [ ] Fitur pencarian misi berdasarkan nama
* [ ] Tambahkan favorit/bookmark misi
* [ ] Tambahkan mode offline dengan cache data

---

## 👨‍💻 Kontributor

* **[Zidan Zii](https://github.com/ziidanzii)** – Developer & Maintainer

---

## 📜 Lisensi

Proyek ini menggunakan lisensi **MIT**. Silakan gunakan dan kembangkan sesuai kebutuhan.

---
