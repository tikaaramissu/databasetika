-- 1. TABEL MASTER SEKOLAH
CREATE TABLE m_sekolah (
    npsn VARCHAR(10) PRIMARY KEY, -- Nomor Pokok Sekolah Nasional sebagai ID Unik
    nama_sekolah VARCHAR(150) NOT NULL,
    jenjang VARCHAR(5) NOT NULL, -- 'SMA' atau 'SMK'
    status_sekolah VARCHAR(10) NOT NULL, -- 'NEGERI' atau 'SWASTA'
    alamat TEXT,
    kecamatan VARCHAR(100) NOT NULL
);

-- =========================================================================
-- MODUL 1: DATA BEASISWA (JENJANG SMA & SMK)
-- =========================================================================

-- 2. TABEL MASTER PROGRAM BEASISWA
CREATE TABLE m_beasiswa (
    id_beasiswa UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nama_program VARCHAR(150) NOT NULL, -- Contoh: "Beasiswa Jabar Juara", "PIP"
    sumber_dana VARCHAR(100) NOT NULL, -- APBD, APBN, Swasta/CSR
    tahun_anggaran INT NOT NULL,
    nominal_per_siswa NUMERIC(12, 2) NOT NULL
);

-- 3. TABEL PENERIMA BEASISWA (Transaksi Banyak Data)
CREATE TABLE t_penerima_beasiswa (
    id_penerima UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_beasiswa UUID REFERENCES m_beasiswa(id_beasiswa),
    npsn VARCHAR(10) REFERENCES m_sekolah(npsn),
    nisn VARCHAR(12) NOT NULL, -- Nomor Induk Siswa Nasional
    nama_siswa VARCHAR(150) NOT NULL,
    kelas VARCHAR(5) NOT NULL, -- '10', '11', '12'
    tanggal_pencairan DATE,
    status_verifikasi VARCHAR(20) DEFAULT 'PROSES' -- PROSES, CAIR, DITOLAK
);

-- =========================================================================
-- MODUL 2: PROFIL LULUSAN (SNBP, SNBT, SELEKSI MANDIRI)
-- =========================================================================

-- 4. TABEL DATA LULUSAN & JALUR PTN/PTS
CREATE TABLE t_profil_lulusan (
    id_lulusan UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    npsn VARCHAR(10) REFERENCES m_sekolah(npsn),
    nisn VARCHAR(12) NOT NULL,
    nama_siswa VARCHAR(150) NOT NULL,
    tahun_lulus INT NOT NULL, -- Contoh: 2026
    
    -- Jalur Penerimaan: 'SNBP', 'SNBT', 'MANDIRI', 'KERJA', 'WIRAUSAHA'
    jalur_penerimaan VARCHAR(15) NOT NULL, 
    
    nama_ptn_pts VARCHAR(150), -- Nama Kampus (misal: Universitas Gadjah Mada)
    nama_prodi VARCHAR(150), -- Nama Program Studi
    
    -- Kolom NoSQL tambahan untuk menyimpan bukti kelulusan (misal: kartu peserta, dll)
    metadata_kelulusan JSONB DEFAULT '[]'::jsonb 
);

-- =========================================================================
-- MODUL 3: DATA KETUA MGMP
-- =========================================================================

-- 5. TABEL MASTER MATA PELAJARAN
CREATE TABLE m_mata_pelajaran (
    id_mapel UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nama_mapel VARCHAR(100) NOT NULL, -- Contoh: "Matematika", "Fisika", "Bahasa Inggris"
    jenjang_mapel VARCHAR(5) NOT NULL -- 'SMA' atau 'SMK'
);

-- 6. TABEL KETUA MGMP (Musyawarah Guru Mata Pelajaran)
CREATE TABLE t_ketua_mgmp (
    id_mgmp UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_mapel UUID REFERENCES m_mata_pelajaran(id_mapel),
    npsn_sekolah_asal VARCHAR(10) REFERENCES m_sekolah(npsn), -- Sekolah tempat mengajar aktif
    nuptk_nip VARCHAR(20) UNIQUE NOT NULL, -- Nomor unik guru
    nama_ketua VARCHAR(150) NOT NULL,
    nomor_whatsapp VARCHAR(20),
    periode_mulai DATE NOT NULL,
    periode_selesai DATE NOT NULL,
    status_aktif BOOLEAN DEFAULT TRUE
);

-- =========================================================================
-- OPTIMALISASI INDEX UNTUK DATA BESAR (BIG DATA READ)
-- =========================================================================
CREATE INDEX idx_penerima_nisn ON t_penerima_beasiswa(nisn);
CREATE INDEX idx_lulusan_sekolah_tahun ON t_profil_lulusan(npsn, tahun_lulus);
CREATE INDEX idx_lulusan_jalur ON t_profil_lulusan(jalur_penerimaan);
CREATE INDEX idx_mgmp_aktif ON t_ketua_mgmp(status_aktif);