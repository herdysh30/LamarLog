# LamarLog Report Worker (Auto GitHub Issues Proxy)

Cloudflare Worker ringan (gratis di Cloudflare Workers Free Tier) agar pengguna LamarLog bisa menekan **"Kirim Laporan Otomatis"** langsung dari HP **tanpa perlu akun GitHub**, sementara token GitHub tetap tersimpan aman di sisi server.

## Cara Deploy (3 Langkah)

### 1. Buat Fine-Grained GitHub Token (Minimal Permission)
1. Buka **GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens → Generate new token**.
2. Pilih **Only select repositories → `herdysh30/ApplyFlow`**.
3. Pada **Repository permissions**, aktifkan **hanya**:
   - **Issues:** `Read and write`
   - *(Semua izin lain biarkan `No access`.)*
4. Generate dan salin token tersebut.

### 2. Deploy ke Cloudflare Workers
Jalankan dari folder `tools/report-worker`:

```bash
cd tools/report-worker
npx wrangler login
npx wrangler secret put GITHUB_TOKEN
npx wrangler deploy
```

Setelah selesai, Wrangler akan menampilkan URL Worker, misalnya:
```text
https://lamarlog-report-worker.<subdomain>.workers.dev
```

Endpoint laporan aktif berada di:
```text
https://lamarlog-report-worker.<subdomain>.workers.dev/report
```

### 3. Hubungkan ke Aplikasi Flutter & GitHub Release
- **Saat build/run lokal:**
  ```bash
  flutter run --dart-define=REPORT_ENDPOINT=https://lamarlog-report-worker.<subdomain>.workers.dev/report
  ```
- **Untuk build rilis otomatis di GitHub Actions (`.github/workflows/release.yml`):**
  1. Buka repo GitHub → **Settings → Secrets and variables → Actions → New repository secret**.
  2. Name: `REPORT_ENDPOINT`
  3. Value: `https://lamarlog-report-worker.<subdomain>.workers.dev/report`

Selesai! Setiap APK rilis berikutnya akan otomatis mengirim laporan bug/crash ke GitHub Issues secara anonim dan aman.
