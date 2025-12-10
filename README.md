# VLE Dashboard (hostingtubes)

Dokumentasi untuk folder `hostingtubes` yang berisi dua komponen utama:
- `config.py`: Layer koneksi database Postgres (Supabase) + helper query yang mengembalikan DataFrame.
- `app.py`: Aplikasi Streamlit untuk visualisasi dan analitik VLE (Virtual Learning Environment).

## Ringkasan Arsitektur
- Database: PostgreSQL (Supabase) dengan tabel: `user_account`, `course_module`, `presentation`, `enrollment`, `assessment`, `student_assessment`, `student_vle_activity`, `vle_item`.
- Backend data access: `psycopg` untuk koneksi + `pandas.read_sql_query` untuk mengambil hasil SQL.
- Frontend: Streamlit, dengan chart dari Plotly.
- Konfigurasi kredensial: melalui env (`.env` / `st.secrets`) atau langsung DSN di `config.py`.

## Konfigurasi Koneksi (`config.py`)
`config.py` bertanggung jawab untuk:
- Memuat environment (`python-dotenv`) dan `st.secrets` jika tersedia.
- Membangun `DB_URL` menggunakan prioritas: `DATABASE_URL` env → `st.secrets["db"]["url"]` → konstanta `SUPABASE_URL`.
- Membuka koneksi dengan `psycopg.connect(DB_URL)`.
- Menyediakan helper:
  - `get_df(sql, params=None)`: Eksekusi query SQL dan return `pandas.DataFrame`.
  - `ping_db()`: Cek koneksi (`SELECT 1`).
  - Serangkaian fungsi fetch_* untuk tiap kebutuhan data aplikasi.

### Menyetel Kredensial
Anda punya 3 opsi:
1) `.env` file
```
DATABASE_URL=postgresql://USER:PASSWORD@HOST:PORT/DBNAME?sslmode=require
```
2) Streamlit Secrets (`.streamlit/secrets.toml`)
```
[db]
url = "postgresql://USER:PASSWORD@HOST:PORT/DBNAME?sslmode=require"
```
3) Hardcode `SUPABASE_URL` di `config.py` (tidak direkomendasikan untuk produksi).

### Dependensi
Lihat `requirements.txt` di folder ini. Minimal: `streamlit`, `pandas`, `plotly`, `python-dotenv`, `psycopg[binary]`.

## Fungsi-Fungsi Data (`config.py`)
Berikut ringkasan fungsi dan SQL yang digunakan:

- `fetch_students()`
```
SELECT user_id AS student_id, name, gender, region, highest_education, date_of_birth
FROM user_account
WHERE role = 'student'
ORDER BY name;
```

- `fetch_instructors()`
```
SELECT user_id AS instructor_id, name, department
FROM user_account
WHERE role = 'instructor'
ORDER BY name;
```

- `fetch_presentations()`
```
SELECT p.presentation_id, p.semester, p.year,
       m.module_code, m.module_name,
       i.name AS instructor_name,
       i.user_id AS instructor_id
FROM presentation p
  JOIN course_module m ON p.module_id = m.module_id
  JOIN user_account i ON p.instructor_id = i.user_id
ORDER BY p.year DESC, p.semester ASC;
```

- `fetch_enrollment(presentation_id)`
```
SELECT e.enrollment_id, e.presentation_id, s.user_id AS student_id, s.name,
       e.studied_credits, e.final_result
FROM enrollment e
  JOIN user_account s ON e.student_id = s.user_id
WHERE e.presentation_id = %s AND s.role = 'student'
ORDER BY s.name;
```

- `fetch_assessments(presentation_id)`
```
SELECT a.assessment_id, a.assessment_name, a.weight
FROM assessment a
WHERE a.presentation_id = %s
ORDER BY a.assessment_id;
```

- `fetch_student_scores(enrollment_id)`
```
SELECT sa.student_assessment_id, a.assessment_id, a.assessment_name, sa.score, a.weight
FROM student_assessment sa
  JOIN assessment a ON sa.assessment_id = a.assessment_id
WHERE sa.enrollment_id = %s;
```

- `fetch_vle_activity(enrollment_id)`
```
SELECT sva.vle_id, v.vle_type, v.title, sva.activity_date, sva.clicks
FROM student_vle_activity sva
  JOIN vle_item v ON sva.vle_id = v.vle_id
WHERE sva.enrollment_id = %s
ORDER BY sva.activity_date;
```

- `fetch_enrollments_all()`
```
SELECT e.enrollment_id, e.presentation_id, e.student_id,
       e.final_result, e.studied_credits
FROM enrollment e;
```

- `fetch_final_scores_all(presentation_id=None)`
Menghitung skor akhir berbobot per `enrollment`.
```
SELECT e.enrollment_id,
       e.presentation_id,
       e.student_id,
       CASE WHEN NULLIF(SUM(a.weight),0) IS NOT NULL
            THEN SUM(sa.score * a.weight)::DECIMAL / NULLIF(SUM(a.weight),0)
            ELSE NULL END AS final_score
FROM enrollment e
  JOIN student_assessment sa ON sa.enrollment_id = e.enrollment_id
  JOIN assessment a ON a.assessment_id = sa.assessment_id
-- optional WHERE e.presentation_id = %s
GROUP BY e.enrollment_id, e.presentation_id, e.student_id;
```

- `fetch_final_results_distribution(presentation_id)`
```
SELECT final_result, COUNT(*) AS cnt
FROM enrollment
WHERE presentation_id = %s
GROUP BY final_result
ORDER BY cnt DESC;
```

- `fetch_total_clicks_all(presentation_id=None)`
Total klik VLE per enrollment.
```
SELECT e.enrollment_id,
       e.presentation_id,
       COALESCE(SUM(sva.clicks),0) AS total_clicks
FROM student_vle_activity sva
  RIGHT JOIN enrollment e ON e.enrollment_id = sva.enrollment_id
-- optional WHERE e.presentation_id = %s
GROUP BY e.enrollment_id, e.presentation_id;
```

- `fetch_vle_avg_timeline_by_presentation(presentation_id)`
Rata-rata klik harian untuk suatu presentasi.
```
SELECT sva.activity_date::date AS activity_date,
       AVG(sva.clicks) AS avg_clicks
FROM student_vle_activity sva
  JOIN enrollment e ON e.enrollment_id = sva.enrollment_id
WHERE e.presentation_id = %s
GROUP BY activity_date
ORDER BY activity_date;
```

- `fetch_assessment_scores_by_enrollment(enrollment_id)`
Skor per assessment untuk satu enrollment.
```
SELECT a.assessment_id,
       a.assessment_name,
       a.weight,
       sa.score
FROM assessment a
  LEFT JOIN student_assessment sa
    ON sa.assessment_id = a.assessment_id
   AND sa.enrollment_id = %s
WHERE a.presentation_id = (
    SELECT presentation_id FROM enrollment WHERE enrollment_id = %s
)
ORDER BY a.assessment_id;
```

- `fetch_students_by_module_counts()`
Jumlah mahasiswa per `module_code`.
```
SELECT m.module_code,
       COUNT(*) AS student_count
FROM enrollment e
  JOIN presentation p ON p.presentation_id = e.presentation_id
  JOIN course_module m ON m.module_id = p.module_id
GROUP BY m.module_code
ORDER BY student_count DESC;
```

## Aplikasi Streamlit (`app.py`)
Fitur utama:
- Pengaturan tema dan styling agar nyaman di mode gelap.
- Sidebar filter global: semester dan instructor.
- Halaman:
  - Overview: metrik total, distribusi region/gender, siswa per modul/semester/instructor, demografi usia, KPI engagement.
  - Classes: daftar kelas, siswa per kelas, distribusi skor assessment, skor akhir berbobot, final result pie, timeline VLE.
  - Students: profil siswa, daftar enrollment, aktivitas VLE per enrollment, ringkasan skor vs klik, assessments & skor.
  - Analytics: scatter klik vs skor dengan korelasi, boxplot skor per gender/region, tren enrolled vs withdrawn, distribusi bobot assessment.
  - Instructors: kelas yang diajar, KPI rata-rata skor dan pass rate, perbandingan kelas.

`app.py` memanfaatkan fungsi `fetch_*` dari `config.py` dan menggunakan `@st.cache_data(ttl=300)` untuk caching.

## Menjalankan Aplikasi
1) Pastikan dependensi terpasang:
```powershell
pip install -r ".\visualisasi\hostingtubes\requirements.txt"
```
2) Siapkan kredensial DB (lihat bagian Konfigurasi Koneksi di atas).
3) Jalankan Streamlit dari folder proyek (atau langsung dari folder ini):
```powershell
streamlit run ".\visualisasi\hostingtubes\app.py"
```

Jika koneksi gagal, aplikasi akan menampilkan peringatan: cek `DATABASE_URL` atau `st.secrets[db].url`.

## Contoh Penggunaan SQL Manual
Anda dapat menjalankan query manual menggunakan helper `get_df`:
```python
from config import get_df

# Semua enrollment
df = get_df("SELECT * FROM enrollment;")

# Distribusi final_result untuk satu presentasi
pid = 1
q = """
SELECT final_result, COUNT(*) AS cnt
FROM enrollment
WHERE presentation_id = %s
GROUP BY final_result
ORDER BY cnt DESC;
"""
df2 = get_df(q, params=(pid,))
```

## Catatan Keamanan
- Hindari hardcode kredensial (`SUPABASE_URL`) di repo publik.
- Gunakan `.env` atau `st.secrets` untuk produksi.
- Pastikan `sslmode=require` pada koneksi Supabase.

## Struktur Tabel Singkat
- `user_account(role: 'student'|'instructor')`: data pengguna.
- `course_module`: metadata modul.
- `presentation(module_id, instructor_id, semester, year)`: kelas/presentasi.
- `enrollment(student_id, presentation_id, studied_credits, final_result)`: keikutsertaan siswa.
- `assessment(presentation_id, weight, assessment_name)`: penilaian.
- `student_assessment(enrollment_id, assessment_id, score)`: skor penilaian.
- `vle_item(vle_id, vle_type, title)`: item VLE.
- `student_vle_activity(enrollment_id, vle_id, activity_date, clicks)`: aktivitas klik.

Dengan dokumentasi ini, Anda dapat memahami alur data `config.py`, fitur visualisasi di `app.py`, dan cara menjalankan serta memperluas dashboard VLE Anda.
