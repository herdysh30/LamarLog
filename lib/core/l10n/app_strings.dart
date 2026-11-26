import 'package:flutter/material.dart';

import '../enums/application_enums.dart';

/// Inherited localization provider supporting English ('en') and Bahasa Indonesia ('id').
class AppLocaleScope extends InheritedWidget {
  const AppLocaleScope({
    super.key,
    required this.strings,
    required super.child,
  });

  final AppStrings strings;

  static AppStrings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    return scope?.strings ?? const AppStrings('en');
  }

  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) =>
      strings.languageCode != oldWidget.strings.languageCode ||
      !_mapEquals(strings.customStageNames, oldWidget.strings.customStageNames);

  static bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}

class AppStrings {
  const AppStrings(
    this.languageCode, {
    this.customStageNames = const {},
  });

  final String languageCode;
  final Map<String, String> customStageNames;
  bool get isId => languageCode == 'id';

  // Navigation
  String get navPipeline => 'Pipeline';
  String get navNotifications => isId ? 'Notifikasi' : 'Alerts';
  String get navAnalytics => isId ? 'Analitik' : 'Analytics';
  String get navSettings => isId ? 'Pengaturan' : 'Settings';

  // Custom Kanban Column Names
  String get renameColumn => isId ? 'Ubah Nama Kolom' : 'Rename Column';
  String get columnNameHint =>
      isId ? 'Masukkan nama kolom baru' : 'Enter custom column name';
  String get resetDefault => isId ? 'Reset Default' : 'Reset Default';
  String get kanbanColumnNames =>
      isId ? 'Nama Kolom Kanban' : 'Kanban Column Names';
  String get kanbanColumnNamesSub => isId
      ? 'Ubah nama 5 tahap aktif di papan Kanban'
      : 'Customize labels for your 5 active board columns';
  String get resetAllNames => isId ? 'Reset Semua' : 'Reset All';

  // Notifications Page
  String get notificationsTitle =>
      isId ? 'Notifikasi & Pengingat' : 'Reminders & Alerts';
  String get notificationsSubtitle => isId
      ? 'Jadwal interview mendatang dan status alarm pengingat lokal.'
      : 'Upcoming interview schedules and local reminder status.';
  String get upcoming => isId ? 'Mendatang' : 'Upcoming';
  String get past => isId ? 'Lewat' : 'Past';
  String get noUpcomingInterviews => isId
      ? 'Belum ada pengingat interview mendatang'
      : 'No upcoming interview reminders';
  String get noUpcomingSub => isId
      ? 'Jadwalkan interview agar pengingat 24 jam & 1 jam sebelumnya otomatis aktif.'
      : 'Schedule an interview to automatically trigger 24h & 1h local alerts.';
  String get noPastInterviews =>
      isId ? 'Belum ada riwayat interview lewat.' : 'No past interviews yet.';
  String get scheduleInterview =>
      isId ? 'Jadwalkan Interview' : 'Schedule Interview';
  String get pickApplicationFirst => isId
      ? 'Pilih lamaran untuk dijadwalkan'
      : 'Select an application to schedule';
  String get noAppsToSchedule => isId
      ? 'Tambahkan lamaran terlebih dahulu di Pipeline.'
      : 'Add a job application in Pipeline first.';
  String get enableReminders =>
      isId ? 'Aktifkan Pengingat' : 'Enable Reminders';
  String get permissionInactiveBanner => isId
      ? 'Beberapa jadwal memiliki pengingat tidak aktif. Ketuk untuk meminta izin notifikasi & menjadwalkan ulang.'
      : 'Some upcoming schedules have inactive reminders. Tap to request permission and reschedule.';
  String get completedLabel => isId ? 'Selesai' : 'Completed';
  String get startingSoon => isId ? 'Segera dimulai' : 'Starting soon';
  String inHours(int h) => isId ? 'Dalam $h jam' : 'In ${h}h';
  String inDays(int d) => isId ? 'Dalam $d hari' : 'In ${d}d';
  String get tomorrow => isId ? 'Besok' : 'Tomorrow';

  // Pipeline Screen
  String get searchHint => isId
      ? 'Cari perusahaan, posisi, atau lokasi...'
      : 'Filter company, role, or location...';
  String get kanban => 'Kanban';
  String get list => isId ? 'Daftar' : 'List';
  String archiveCount(int n) => isId ? 'Arsip ($n)' : 'Archive ($n)';
  String get trackJob => isId ? 'Catat Lamaran' : 'Track Job';
  String activeSummary(int stages, int count) => isId
      ? '$stages Tahap aktif • $count lamaran aktif'
      : '$stages Active stages • $count active';
  String get pipelineFilter => isId ? 'Filter Pipeline' : 'Pipeline Filter';
  String get workplaceStyle => isId ? 'Tipe Kerja' : 'Workplace Style';
  String get priorityLevel => isId ? 'Tingkat Prioritas' : 'Priority Level';
  String get sorting => isId ? 'Urutkan' : 'Sorting';
  String get all => isId ? 'Semua' : 'All';
  String get sortLatest =>
      isId ? 'Perpindahan Terbaru' : 'Latest Stage Move';
  String get sortSalary =>
      isId ? 'Gaji (Tertinggi)' : 'Salary (High to Low)';
  String get reset => 'Reset';
  String get applyFilters => isId ? 'Terapkan Filter' : 'Apply Filters';
  String get terminalArchive => isId ? 'Arsip Hasil Akhir' : 'Terminal Archive';
  String acceptedCount(int n) => isId ? 'Diterima ($n)' : 'Accepted ($n)';
  String rejectedCount(int n) => isId ? 'Ditolak ($n)' : 'Rejected ($n)';
  String otherCount(int n) => isId ? 'Lainnya ($n)' : 'Other ($n)';
  String get noArchivedInCategory => isId
      ? 'Belum ada lamaran arsip di kategori ini.'
      : 'No archived applications in this category.';
  String get done => isId ? 'Selesai' : 'Done';
  String noJobsInStage(String stage) =>
      isId ? 'Belum ada di $stage' : 'No jobs in $stage';
  String get dropOrAddHint => isId
      ? 'Tahan kartu untuk geser ke sini\natau tambah lamaran baru'
      : 'Long-press a card to drag here\nor add a new track';
  String addToStage(String stage) =>
      isId ? 'Tambah ke $stage' : 'Add to $stage';
  String get emptyPipelineTitle =>
      isId ? 'Pipeline masih kosong' : 'Your pipeline is empty';
  String get emptyPipelineSubtitle => isId
      ? 'Catat lamaran pertamamu untuk mengatur jadwal interview, CV, dan offering.'
      : 'Track your first application to organize interviews, resumes, and offers.';
  String get trackFirstJob =>
      isId ? 'Catat Lamaran Pertama' : 'Track First Job';

  // Card
  String get salaryUnlisted => isId ? 'Gaji belum diisi' : 'Salary unlisted';
  String daysInStage(int days) {
    if (days == 0) return isId ? 'Hari ini' : 'Today';
    return isId ? '${days}h di tahap ini' : '${days}d in stage';
  }

  // Form
  String get addApplication => isId ? 'Tambah Lamaran' : 'Add Application';
  String get editApplication => isId ? 'Edit Lamaran' : 'Edit Application';
  String get coreDetails => isId ? 'Detail Utama' : 'Core Details';
  String get requiredTag => isId ? 'Wajib' : 'Required';
  String get companyName => isId ? 'Nama Perusahaan' : 'Company Name';
  String get companyHint => 'e.g. Stripe, Traveloka, Figma';
  String get companyRequired =>
      isId ? 'Masukkan nama perusahaan' : 'Please enter company name';
  String get roleTitle => isId ? 'Posisi / Jabatan' : 'Role Title';
  String get roleHint => 'e.g. Senior Flutter Engineer';
  String get roleRequired =>
      isId ? 'Masukkan nama posisi' : 'Please enter role title';
  String get location => isId ? 'Lokasi' : 'Location';
  String get locationHint =>
      isId ? 'Jakarta, ID atau Remote' : 'Jakarta, ID or Remote Worldwide';
  String get workArrangement =>
      isId ? 'Pengaturan Kerja' : 'Work & Job Arrangement';
  String get workplaceSetting => isId ? 'Sistem Kerja' : 'Workplace Setting';
  String get employmentContract =>
      isId ? 'Jenis Kontrak' : 'Employment Contract';
  String get pipelineStatusPriority =>
      isId ? 'Status Pipeline & Prioritas' : 'Pipeline Status & Priority';
  String get pipelineStage => isId ? 'Tahap Pipeline' : 'Pipeline Stage';
  String stageOf(int i, int total) =>
      isId ? 'Tahap $i dari $total' : 'Stage $i of $total';
  String get applicationUrgency =>
      isId ? 'Urgensi Lamaran' : 'Application Urgency';
  String get topFocus => isId ? 'Target Utama' : 'Top Focus';
  String get standard => isId ? 'Standar' : 'Standard';
  String get backburner => isId ? 'Cadangan' : 'Backburner';
  String get compensationRef =>
      isId ? 'Kompensasi & Referensi' : 'Compensation & Reference';
  String get expectedCompensation =>
      isId ? 'Ekspektasi Gaji' : 'Expected Compensation';
  String get offeredCompensation =>
      isId ? 'Gaji Ditawarkan (Offering)' : 'Offered Salary (Optional)';
  String get offeredLabel => isId ? 'Ditawarkan' : 'Offered';
  String get editNote => isId ? 'Edit Catatan' : 'Edit Note';
  String get deleteNoteTitle => isId ? 'Hapus Catatan?' : 'Delete Note?';
  String get deleteNoteBody => isId
      ? 'Hapus catatan timeline ini secara permanen?'
      : 'Permanently delete this timeline note?';
  String get backupSaved =>
      isId ? 'File backup berhasil disimpan.' : 'Backup file saved successfully.';
  String get backupCancelled =>
      isId ? 'Ekspor backup dibatalkan.' : 'Backup export cancelled.';

  // Onboarding
  String get skip => isId ? 'Lewati' : 'Skip';
  String get next => isId ? 'Lanjut' : 'Next';
  String get getStarted => isId ? 'Mulai Sekarang' : 'Get Started';
  String get onboard1Title =>
      isId ? 'Kelola Pipeline Lamaranmu' : 'Organize Your Career Pipeline';
  String get onboard1Body => isId
      ? 'Geser kartu lamaran antar tahap aktif di papan Kanban dan pisahkan hasil akhir secara rapi.'
      : 'Move applications smoothly across active Kanban stages while keeping terminal outcomes cleanly archived.';
  String get onboard2Title =>
      isId ? 'Jangan Lewatkan Interview' : 'Never Miss an Interview';
  String get onboard2Body => isId
      ? 'Atur pengingat otomatis 24 jam & 1 jam sebelum jadwal, simpan catatan timeline, dan lampirkan CV PDF spesifik.'
      : 'Schedule automatic 24h & 1h reminders, log round-by-round notes, and attach tailored PDF resumes.';
  String get onboard3Title =>
      isId ? 'Analitik Akurat & Privat' : 'Private Insights, Full Control';
  String get onboard3Body => isId
      ? 'Pantau rasio interview, kecepatan respon, serta cadangkan datamu kapan saja lewat ekspor JSON.'
      : 'Track real interview conversion and response velocity from transition history with full JSON backup ownership.';
  String get jobVacancyLink => isId ? 'Tautan Lowongan' : 'Job Vacancy Link';
  String get recruiterInfoOptional =>
      isId ? 'Info Recruiter (Opsional)' : 'Recruiter Info (Optional)';
  String get name => isId ? 'Nama' : 'Name';
  String get emailPhone => isId ? 'Email / Telepon' : 'Email / Phone';
  String get saveApplication => isId ? 'Simpan Lamaran' : 'Save Application';
  String get updateApplication =>
      isId ? 'Perbarui Lamaran' : 'Update Application';
  String get cancel => isId ? 'Batal' : 'Cancel';

  // Detail
  String get applicationDetails =>
      isId ? 'Detail Lamaran' : 'Application Details';
  String get compensation => isId ? 'Kompensasi' : 'Compensation';
  String appliedOn(String date) => isId ? 'Dilamar $date' : 'Applied $date';
  String get notAppliedYet =>
      isId ? 'Belum dilamar (Wishlist)' : 'Not applied yet (Wishlist)';
  String get applicationState => isId ? 'Status Lamaran' : 'Application State';
  String get change => isId ? 'Ubah' : 'Change';
  String get stageSuffix => isId ? 'Tahap' : 'Stage';
  String get outcomeSuffix => isId ? 'Hasil' : 'Outcome';
  String get interviewSchedule =>
      isId ? 'Jadwal Interview' : 'Interview Schedule';
  String get schedule => isId ? 'Jadwalkan' : 'Schedule';
  String get noInterviewsYet => isId
      ? 'Belum ada jadwal interview. Tambahkan jadwal untuk mengaktifkan pengingat 24 jam & 1 jam sebelumnya.'
      : 'No interviews scheduled yet. Add a session to activate 24h & 1h local reminders.';
  String get remindersActiveBoth => isId
      ? 'Pengingat aktif: 24 jam & 1 jam sebelum'
      : 'Reminders active: 24h & 1h before';
  String get reminderActive1h =>
      isId ? 'Pengingat aktif: 1 jam sebelum' : 'Reminder active: 1h before';
  String get remindersInactive =>
      isId ? 'Pengingat tidak aktif' : 'Reminders inactive';
  String get copy => isId ? 'Salin' : 'Copy';
  String get linkCopied => isId ? 'Tautan disalin' : 'Link copied';
  String get tailoredResume => isId ? 'Lampiran CV (PDF)' : 'Tailored Resume (PDF)';
  String get attachPdf => isId ? 'Lampirkan PDF' : 'Attach PDF';
  String get replace => isId ? 'Ganti' : 'Replace';
  String get noPdfAttached => isId
      ? 'Belum ada PDF terlampir (maks. 10 MB).'
      : 'No PDF resume attached yet (max 10 MB).';
  String get preview => isId ? 'Pratinjau' : 'Preview';
  String get fileNotFound =>
      isId ? 'File tidak ditemukan' : 'File not found';
  String get reattach => isId ? 'Lampirkan Ulang' : 'Re-attach';
  String get timelineActivity =>
      isId ? 'Timeline & Aktivitas' : 'Timeline & Activity';
  String get addNote => isId ? 'Tambah Catatan' : 'Add Note';
  String get noActivityYet => isId
      ? 'Belum ada catatan aktivitas. Tambahkan catatan interview atau tindak lanjut.'
      : 'No activity recorded yet. Add interview notes or follow-ups.';
  String get editJobDetails =>
      isId ? 'Edit Detail Lamaran' : 'Edit Job Details';
  String get updateStateTitle =>
      isId ? 'Ubah Status Lamaran' : 'Update Application State';
  String get activeStagesHeader =>
      isId ? 'Tahapan Pipeline Aktif' : 'Active Pipeline Stages';
  String get terminalOutcomesHeader => isId
      ? 'Hasil Akhir (Pindah ke Arsip)'
      : 'Terminal Outcomes (Move to Archive)';
  String get deleteAppTitle => isId ? 'Hapus Lamaran?' : 'Delete Application?';
  String deleteAppBody(String company, String role) => isId
      ? 'Hapus permanen "$company — $role" beserta catatan timeline, jadwal interview, dan PDF terlampir?'
      : 'Permanently delete "$company — $role", including timeline notes, interview schedules, and attached PDF?';
  String get delete => isId ? 'Hapus' : 'Delete';
  String get save => isId ? 'Simpan' : 'Save';

  // Analytics
  String get analyticsInsights =>
      isId ? 'Analitik & Wawasan' : 'Analytics & Insights';
  String get analyticsSubtitle => isId
      ? 'Diagnostik pipeline dari riwayat transisi status lamaranmu.'
      : 'Pipeline diagnostics computed from your StatusTransition history.';
  String get allTime => isId ? 'Semua Waktu' : 'All Time';
  String get past30Days => isId ? '30 Hari Terakhir' : 'Past 30 Days';
  String get past90Days => isId ? '90 Hari Terakhir' : 'Past 90 Days';
  String get totalApplied => isId ? 'Total Dilamar' : 'Total Applied';
  String get interviewRate => isId ? 'Rasio Interview' : 'Interview Rate';
  String get offerRate => isId ? 'Rasio Offering' : 'Offer Rate';
  String get respVelocity => isId ? 'Kecepatan Respon' : 'Resp. Velocity';
  String totalTrackedSub(int n) =>
      isId ? '$n total tercatat' : '$n total tracked';
  String appliedRatioSub(int reached, int applied) =>
      isId ? '$reached / $applied dilamar' : '$reached / $applied applied';
  String offersReachedSub(int n) =>
      isId ? '$n mencapai offering' : '$n offers reached';
  String get needResponses => isId ? 'Menunggu respon' : 'Need responses';
  String get appliedToResponse =>
      isId ? 'Dilamar → Respon' : 'Applied → Response';
  String get applicationFunnel =>
      isId ? 'Funnel Lamaran' : 'Application Funnel';
  String get funnelSubtitle => isId
      ? 'Progres konversi dari awal hingga offering'
      : 'End-to-end conversion progression';
  String leadsCount(int n) => isId ? '$n Prospek' : '$n Leads';
  String reachedCount(int n) => isId ? '$n tercapai' : '$n reached';
  String get stageVelocity => isId ? 'Kecepatan Tahap' : 'Stage Velocity';
  String get pacingAvg => isId ? 'Rata-rata' : 'Pacing Avg';
  String get keyFunnelInsight =>
      isId ? 'Wawasan Utama' : 'Key Funnel Insight';

  // Settings
  String get settingsSubtitle => isId
      ? 'Konfigurasi tampilan, bahasa, & brankas data'
      : 'Local configuration & private data vault';
  String get localVault => isId ? 'Penyimpanan Lokal' : 'Local Storage';
  String get appearancePreferences =>
      isId ? 'Tampilan & Preferensi' : 'Appearance & Preferences';
  String get themeMode => isId ? 'Mode Tema' : 'Theme Mode';
  String get themeSystem => isId ? 'Sistem' : 'System';
  String get themeLight => isId ? 'Terang' : 'Light';
  String get themeDark => isId ? 'Gelap' : 'Dark';
  String get colorPalette => isId ? 'Pola Warna' : 'Color Palette';
  String get language => isId ? 'Bahasa' : 'Language';
  String get languageSubtitle =>
      isId ? 'Bahasa tampilan aplikasi' : 'Display language & formatting';
  String get defaultCurrency =>
      isId ? 'Mata Uang Default' : 'Default Currency';
  String get defaultCurrencySubtitle =>
      isId ? 'Kompensasi & tawaran gaji' : 'Compensation & salary offers';
  String get dataVaultBackup =>
      isId ? 'Brankas Data & Cadangan' : 'Data Vault & Backup';
  String get privacyAssurance => isId
      ? 'Semua data lamaran, jadwal interview, catatan, dan CV PDF tersimpan secara offline di HP ini. Datamu tidak pernah keluar dari perangkat kecuali kamu mengekspornya secara manual.'
      : 'All applications, interview schedules, notes, and PDF resumes are stored offline on this device. Your data never leaves your phone unless you export it manually.';
  String get footerStorageNote => isId
      ? 'Semua data tersimpan secara offline di HP ini'
      : 'All data is stored offline on this device';
  String get exportBackup => isId ? 'Ekspor Backup (.json)' : 'Export Backup (.json)';
  String get exportBackupSub => isId
      ? 'Simpan salinan JSON berisi seluruh lamaran & catatan'
      : 'Save full JSON snapshot of applications & logs';
  String get restoreBackup =>
      isId ? 'Pulihkan Backup (.json)' : 'Restore Backup (.json)';
  String get restoreBackupSub => isId
      ? 'Ganti database lokal dari file backup .json'
      : 'Replace local database from a valid .json backup';
  String get warningPlaintext =>
      isId ? 'Peringatan: Format Teks Biasa' : 'Warning: Plaintext Format';
  String get warningPlaintextBody => isId
      ? 'File backup disimpan sebagai JSON tanpa enkripsi yang berisi kontak, gaji, dan catatan. Simpan di tempat aman.'
      : 'Backup files are unencrypted plain JSON containing contacts, salary figures, and notes. Store them safely.';
  String get storageDangerZone =>
      isId ? 'Penyimpanan & Zona Berbahaya' : 'Storage & Danger Zone';
  String get localStorageUsage =>
      isId ? 'Penggunaan Penyimpanan Lokal' : 'Local Storage Usage';
  String storageBreakdown(int apps, int pdfs) => isId
      ? '$apps lamaran • $pdfs file CV PDF tersimpan privat.'
      : '$apps applications • $pdfs private PDF resumes cached.';
  String get irreversibleOp =>
      isId ? 'Tindakan Tidak Dapat Dibatalkan' : 'Irreversible Operation';
  String get clearDataDesc => isId
      ? 'Hapus permanen seluruh lamaran, riwayat transisi, jadwal, dan file PDF tersimpan.'
      : 'Permanently delete all local applications, transition history, schedules, and cached PDF resumes.';
  String get clearAllData => isId ? 'Hapus Semua Data' : 'Clear All Data';
  String get selectLanguage => isId ? 'Pilih Bahasa' : 'Select Language';

  // Enum labels (checks custom Kanban column names first)
  String defaultStatusLabel(ApplicationStatus status) {
    if (!isId) return status.label;
    return switch (status) {
      ApplicationStatus.wishlist => 'Wishlist',
      ApplicationStatus.applied => 'Dilamar',
      ApplicationStatus.screening => 'Screening',
      ApplicationStatus.interview => 'Interview',
      ApplicationStatus.offering => 'Offering',
      ApplicationStatus.offerAccepted => 'Tawaran Diterima',
      ApplicationStatus.offerDeclined => 'Tawaran Ditolak',
      ApplicationStatus.rejected => 'Ditolak',
      ApplicationStatus.withdrawn => 'Ditarik',
      ApplicationStatus.noResponse => 'Tanpa Respon',
    };
  }

  String statusLabel(ApplicationStatus status) {
    final custom = customStageNames[status.name]?.trim();
    if (custom != null && custom.isNotEmpty) return custom;
    return defaultStatusLabel(status);
  }

  String priorityLabel(PriorityLevel level, {bool compact = false}) {
    if (!isId) {
      if (compact && level == PriorityLevel.medium) return 'Med';
      return level.label;
    }
    return switch (level) {
      PriorityLevel.high => 'Tinggi',
      PriorityLevel.medium => compact ? 'Sedang' : 'Sedang',
      PriorityLevel.low => 'Rendah',
    };
  }

  String workplaceLabel(WorkplaceType type) {
    if (!isId) return type.label;
    return switch (type) {
      WorkplaceType.remote => 'Remote',
      WorkplaceType.hybrid => 'Hybrid',
      WorkplaceType.onsite => 'Onsite',
    };
  }

  String jobTypeLabel(JobType type) {
    if (!isId) return type.label;
    return switch (type) {
      JobType.fullTime => 'Full-time',
      JobType.contract => 'Kontrak',
      JobType.partTime => 'Paruh Waktu',
      JobType.freelance => 'Freelance',
    };
  }
}
