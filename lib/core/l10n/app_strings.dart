import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../enums/application_enums.dart';
import '../models/pipeline_stage_config.dart';

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
      !_listEquals(strings.pipelineStages, oldWidget.strings.pipelineStages);

  static bool _listEquals(
    List<PipelineStageConfig> a,
    List<PipelineStageConfig> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class AppStrings {
  const AppStrings(
    this.languageCode, {
    this.customPipelineStages,
  });

  final String languageCode;
  final List<PipelineStageConfig>? customPipelineStages;
  bool get isId => languageCode == 'id';

  /// Active Kanban stages configured by the user (or the default 5 stages).
  List<PipelineStageConfig> get pipelineStages =>
      customPipelineStages ?? PipelineStageConfig.defaults(isId: isId);

  /// Stage label lookup map (`stageId -> label`) for exports/analytics.
  Map<String, String> get stageLabelMap => {
        for (final stage in pipelineStages) stage.id: stage.label,
        for (final term in ApplicationStatus.terminalOutcomes)
          term.name: defaultStatusLabel(term),
      };

  PipelineStageConfig? stageById(String statusId) {
    for (final stage in pipelineStages) {
      if (stage.id == statusId) return stage;
    }
    return null;
  }

  Color stageDotColorById(String statusId, Brightness brightness) {
    final custom = stageById(statusId);
    if (custom != null) return custom.colorKey.dotColor(brightness);
    final builtIn = ApplicationStatus.values
        .where((e) => e.name == statusId)
        .firstOrNull;
    if (builtIn != null) return AppColors.stageDotColor(builtIn, brightness);
    return StageColorKey.violet.dotColor(brightness);
  }

  (Color bg, Color fg, Color dot) stageColorsById(
    String statusId,
    Brightness brightness,
    ColorScheme cs,
  ) {
    final custom = stageById(statusId);
    if (custom != null) {
      final (bg, fg) = custom.colorKey.chipColors(brightness);
      return (bg, fg, custom.colorKey.dotColor(brightness));
    }
    final builtIn = ApplicationStatus.values
        .where((e) => e.name == statusId)
        .firstOrNull;
    if (builtIn != null) {
      final (bg, fg) = AppColors.statusBadgeColors(builtIn, brightness, cs);
      return (bg, fg, AppColors.stageDotColor(builtIn, brightness));
    }
    final (bg, fg) = StageColorKey.violet.chipColors(brightness);
    return (bg, fg, StageColorKey.violet.dotColor(brightness));
  }

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

  // Application Platform (Source)
  String get sourcePlatform =>
      isId ? 'Platform Lamaran (Opsional)' : 'Application Platform (Optional)';
  String get sourcePlatformHint =>
      isId ? 'Contoh: LinkedIn, Glints, JobStreet' : 'e.g. LinkedIn, Glints, Referral';
  String get platformLabel => isId ? 'Platform' : 'Platform';
  List<String> get platformPresets => isId
      ? const [
          'LinkedIn',
          'Glints',
          'JobStreet',
          'Kalibrr',
          'Dealls',
          'Website Perusahaan',
          'Referral',
          'Email',
        ]
      : const [
          'LinkedIn',
          'Glints',
          'JobStreet',
          'Kalibrr',
          'Dealls',
          'Company Site',
          'Referral',
          'Email',
        ];

  // Direct contact & URL launcher
  String get openLink => isId ? 'Buka Tautan' : 'Open Link';
  String get sendEmail => isId ? 'Kirim Email' : 'Send Email';
  String get callPhone => isId ? 'Telepon' : 'Call';
  String get chatWhatsApp => isId ? 'WhatsApp' : 'WhatsApp';
  String get copyAction => isId ? 'Salin' : 'Copy';
  String get copiedToClipboard =>
      isId ? 'Disalin ke clipboard' : 'Copied to clipboard';
  String get couldNotOpenLink =>
      isId ? 'Tidak dapat membuka tautan ini.' : 'Could not open this link.';

  // Stale application follow-up
  String needsFollowUpBadge(int days) =>
      isId ? 'Follow-up • ${days}h' : 'Follow-up • ${days}d';
  String staleBannerTitle(int count) => isId
      ? '$count lamaran belum ada kabar (≥14 hari)'
      : '$count applications awaiting reply (≥14 days)';
  String get staleBannerSub => isId
      ? 'Ketuk untuk melihat lamaran yang perlu di-follow-up'
      : 'Tap to filter applications that need a follow-up';
  String staleDetailTitle(int days) => isId
      ? 'Sudah $days hari tanpa pembaruan'
      : 'No updates for $days days';
  String get staleDetailBody => isId
      ? 'Pertimbangkan kirim pesan follow-up ke rekruter atau pindahkan ke Tanpa Respon jika sudah tidak ada kabar.'
      : 'Consider sending a polite follow-up to the recruiter or moving this to No Response.';
  String get logFollowUpBtn =>
      isId ? 'Catat Follow-up' : 'Log Follow-up';
  String get markNoResponseBtn =>
      isId ? 'Tanpa Respon' : 'No Response';
  String get followUpLoggedMsg =>
      isId ? 'Follow-up dicatat di linimasa!' : 'Follow-up logged to timeline!';
  String get staleOnlyFilter =>
      isId ? 'Hanya Perlu Follow-up (≥14h)' : 'Needs Follow-up Only (≥14d)';

  // CSV Export
  String get exportCsv =>
      isId ? 'Ekspor Spreadsheet (.csv)' : 'Export Spreadsheet (.csv)';
  String get exportCsvSub => isId
      ? 'Simpan daftar lamaran dalam format CSV untuk Excel / Sheets'
      : 'Save applications table as CSV for Excel / Google Sheets';
  String get csvSaved =>
      isId ? 'File CSV berhasil disimpan!' : 'CSV file saved successfully!';
  String get csvCancelled =>
      isId ? 'Ekspor CSV dibatalkan.' : 'CSV export cancelled.';
  String get csvEmpty => isId
      ? 'Belum ada lamaran untuk diekspor.'
      : 'No applications to export yet.';

  // Offline Indonesia regions autocomplete & Google Maps
  String get locationAutocompleteHint => isId
      ? 'Ketik kecamatan, kota, atau alamat kantor...'
      : 'Type district, city, or office address...';
  String get openInMaps => isId ? 'Buka di Maps' : 'Open in Maps';
  String get districtTag => isId ? 'Kecamatan' : 'District';
  String get cityTag => isId ? 'Kota/Kab' : 'City';
  String get provinceTag => isId ? 'Provinsi' : 'Province';

  // Customizable Pipeline Stages Manager
  String get managePipelineStages =>
      isId ? 'Kelola Tahapan Pipeline' : 'Manage Pipeline Stages';
  String get managePipelineStagesSub => isId
      ? 'Tambah, ubah nama/warna, atur urutan, atau hapus kolom Kanban'
      : 'Add, rename, recolor, reorder, or delete Kanban columns';
  String get addStage => isId ? 'Tambah Tahap' : 'Add Stage';
  String get addStageTitle =>
      isId ? 'Tambah Tahap Pipeline' : 'Add Pipeline Stage';
  String get stageNameHint => isId
      ? 'Contoh: Psikotes, Technical Test, HR Interview'
      : 'e.g. Technical Test, HR Interview, Medical';
  String get stageColorLabel => isId ? 'Warna Indikator' : 'Indicator Color';
  String deleteStageTitle(String name) =>
      isId ? 'Hapus tahap "$name"?' : 'Delete "$name" stage?';
  String get deleteStageBody => isId
      ? 'Tahap ini akan dihapus dari papan Kanban.'
      : 'This stage will be removed from your Kanban board.';
  String deleteStageReassignNote(int count, String fallbackName) => isId
      ? 'Ada $count lamaran di tahap ini. Semuanya akan dipindahkan otomatis ke "$fallbackName" agar tidak hilang.'
      : '$count applications are currently in this stage. They will be moved safely to "$fallbackName".';
  String get cannotDeleteLastStage => isId
      ? 'Minimal harus ada 1 tahap aktif di Pipeline.'
      : 'At least 1 active pipeline stage is required.';
  String stageCountBadge(int count) => isId
      ? '$count tahap aktif (maks. 12)'
      : '$count active stages (max 12)';
  String get reorderOrEditHint => isId
      ? 'Ketuk nama untuk mengubah, panah untuk mengatur urutan, atau tambah tahap baru.'
      : 'Tap a stage to edit name/color, use arrows to reorder, or add new stages.';
  String get moveUp => isId ? 'Naikkan' : 'Move Up';
  String get moveDown => isId ? 'Turunkan' : 'Move Down';

  // Error handling & validation messages
  String get retry => isId ? 'Coba Lagi' : 'Retry';
  String get dbLoadErrorTitle =>
      isId ? 'Gagal memuat data lokal' : 'Failed to load local data';
  String get unexpectedErrorTitle =>
      isId ? 'Terjadi kendala tak terduga' : 'Something went wrong';
  String get actionFailedGeneric => isId
      ? 'Tindakan gagal diproses. Coba beberapa saat lagi.'
      : 'Action failed to complete. Please try again.';
  String get exportFailed => isId
      ? 'Gagal mengekspor file. Pastikan penyimpanan cukup.'
      : 'Failed to export file. Please check available storage.';
  String get clearDataFailed => isId
      ? 'Gagal menghapus sebagian data lokal. Coba lagi.'
      : 'Failed to clear local data. Please try again.';
  String get pdfAttachFailed => isId
      ? 'Gagal melampirkan PDF. Pastikan file valid dan penyimpanan cukup.'
      : 'Failed to attach PDF. Ensure the file is valid and storage is available.';
  String get pdfFileNotFoundTitle =>
      isId ? 'File tidak ditemukan' : 'File not found';
  String get pdfFileNotFoundBody => isId
      ? 'File PDF di penyimpanan privat hilang atau rusak. Silakan lampirkan ulang.'
      : 'The PDF file in private storage is missing or corrupted. Please re-attach it.';
  String pdfLoadError(String err) => isId
      ? 'Gagal membuka PDF: $err'
      : 'Error loading PDF: $err';
  String get backupUnsupportedSchema => isId
      ? 'Versi schema backup tidak didukung.'
      : 'Unsupported backup schemaVersion.';
  String get backupRestoredOk => isId
      ? 'Backup berhasil dipulihkan.'
      : 'Backup restored successfully.';
  String get backupInvalidFile => isId
      ? 'File backup JSON tidak valid atau rusak. Pemulihan dibatalkan.'
      : 'Invalid or corrupted JSON backup file. Restore cancelled.';
  String get reminderScheduleFailed => isId
      ? 'Jadwal disimpan, namun alarm pengingat dibatasi oleh sistem perangkat.'
      : 'Schedule saved, but reminder alarms are restricted by this device.';
  String get roundNameRequired => isId
      ? 'Nama tahap interview tidak boleh kosong.'
      : 'Interview round name cannot be empty.';
  String get pastInterviewError => isId
      ? 'Pilih tanggal dan waktu di masa mendatang.'
      : 'Please pick a future date and time.';
  String get noteSaveFailed => isId
      ? 'Gagal menyimpan catatan. Coba lagi.'
      : 'Failed to save note. Please try again.';
  String get scheduleSaveFailed => isId
      ? 'Gagal menyimpan jadwal interview. Coba lagi.'
      : 'Failed to save interview schedule. Please try again.';

  // About page
  String get aboutApp => isId ? 'Tentang LamarLog' : 'About LamarLog';
  String get aboutAppSub => isId
      ? 'Versi aplikasi, privasi data, tautan GitHub, dan lisensi'
      : 'App version, data privacy, GitHub repository & licenses';
  String get aboutTagline => isId
      ? 'Pelacak lamaran kerja offline-first untuk mengelola pipeline karier secara rapi dan privat.'
      : 'Offline-first job application tracker designed to organize your career pipeline privately.';
  String get aboutHighlightsTitle =>
      isId ? 'Prinsip & Kemampuan Utama' : 'Core Principles & Highlights';
  String get aboutStorageTitle =>
      isId ? '100% Lokal & Privat' : '100% Local & Private';
  String get aboutStorageDesc => isId
      ? 'Seluruh lamaran, jadwal interview, catatan, dan CV PDF tersimpan di penyimpanan HP ini tanpa server pihak ketiga.'
      : 'All applications, interview schedules, notes, and PDF resumes stay on this device with no third-party servers.';
  String get aboutKanbanTitle =>
      isId ? 'Pipeline & Analitik Akurat' : 'Custom Pipeline & Analytics';
  String get aboutKanbanDesc => isId
      ? 'Tahapan Kanban dapat ditambah/diubah sesuka hati, dengan funnel dan kecepatan respon dihitung dari riwayat transisi.'
      : 'Fully customizable Kanban stages with conversion funnel and velocity computed from transition history.';
  String get aboutRegionsTitle =>
      isId ? 'Wilayah Indonesia Offline' : 'Offline Indonesia Regions';
  String get aboutRegionsDesc => isId
      ? 'Dilengkapi dataset lokal 38 provinsi, 514 kab/kota, dan 7.285 kecamatan yang bisa dicari instan tanpa internet.'
      : 'Includes a bundled offline dataset of 38 provinces, 514 cities/regencies, and 7,285 districts.';
  String get aboutResourcesTitle =>
      isId ? 'Tautan & Lisensi' : 'Links & Licenses';
  String get aboutGithubRepo =>
      isId ? 'Repositori GitHub' : 'GitHub Repository';
  String get aboutReleases =>
      isId ? 'Rilis & Catatan Perubahan' : 'Releases & Changelog';
  String get aboutOpenSourceLicenses =>
      isId ? 'Lisensi Open-Source' : 'Open-Source Licenses';
  String get aboutOpenSourceSub => isId
      ? 'Lihat daftar pustaka pihak ketiga yang digunakan'
      : 'View third-party packages and licenses used in LamarLog';
  String get aboutBuiltWith =>
      isId ? 'Dibangun dengan Flutter & Drift' : 'Built with Flutter & Drift';

  // Crash & Bug Reporting
  String get sendReportBtn => isId ? 'Laporkan' : 'Send Report';
  String get sendReportTitle =>
      isId ? 'Laporkan Bug / Crash' : 'Send Bug / Crash Report';
  String get sendReportSub => isId
      ? 'Otomatis tercatat sebagai GitHub Issue tanpa perlu akun GitHub'
      : 'Automatically creates a GitHub Issue without needing a GitHub account';
  String get reportPrivacyNote => isId
      ? 'Hanya mengirim versi app, OS, pesan error, dan stack trace ringkas. Data lamaran, gaji, kontak, dan CV PDF tidak pernah dikirim.'
      : 'Only sends app version, OS, error message, and trimmed stack trace. Applications, salaries, contacts, and PDF resumes are never included.';
  String get reportNoteLabel => isId
      ? 'Apa yang sedang kamu lakukan? (Opsional)'
      : 'What were you doing? (Optional)';
  String get reportNoteHint => isId
      ? 'Contoh: Saat menekan tombol simpan jadwal interview...'
      : 'e.g. Right after tapping save on the interview dialog...';
  String get reportPreviewToggle =>
      isId ? 'Lihat pratinjau data yang dikirim' : 'Preview diagnostic data';
  String get sendReportAutoBtn =>
      isId ? 'Kirim Laporan Otomatis' : 'Send Report Automatically';
  String get reportSending => isId ? 'Mengirim...' : 'Sending...';
  String reportSentSuccess(String issueTag) => isId
      ? 'Laporan berhasil dikirim$issueTag! Terima kasih.'
      : 'Report sent successfully$issueTag! Thank you.';
  String get reportEndpointNotConfigured => isId
      ? 'Server proxy laporan belum dipasang. Gunakan tombol GitHub atau Salin di bawah.'
      : 'Report proxy endpoint is not configured yet. Use GitHub or Copy below.';
  String get reportNetworkFailed => isId
      ? 'Gagal terhubung ke internet. Kamu bisa Salin laporan lalu kirim saat online.'
      : 'Could not reach the server. You can copy the report and send it later.';
  String get reportRateLimited => isId
      ? 'Terlalu banyak laporan dalam waktu singkat. Coba lagi beberapa menit lagi.'
      : 'Too many reports sent recently. Please try again in a few minutes.';
  String get reportServerFailed => isId
      ? 'Server gagal membuat Issue. Gunakan tombol GitHub atau Salin di bawah.'
      : 'Server failed to create the issue. Please use GitHub or Copy below.';
  String get reportCopied => isId
      ? 'Laporan error disalin ke clipboard.'
      : 'Diagnostic report copied to clipboard.';
  String get aboutReportBug =>
      isId ? 'Laporkan Bug / Masalah' : 'Report a Bug / Issue';
  String get aboutReportBugSub => isId
      ? 'Kirim laporan error otomatis ke repositori tanpa akun GitHub'
      : 'Submit an anonymous bug report directly to GitHub Issues';

  // Enum & custom stage labels
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

  String statusLabelById(String statusId) {
    final configured = stageById(statusId);
    if (configured != null) return configured.label;

    final builtIn = ApplicationStatus.values
        .where((e) => e.name == statusId)
        .firstOrNull;
    if (builtIn != null) return defaultStatusLabel(builtIn);

    final cleaned = statusId
        .replaceFirst(RegExp(r'^custom_'), '')
        .replaceAll('_', ' ')
        .trim();
    if (cleaned.isEmpty) return statusId;
    return cleaned
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String statusLabel(ApplicationStatus status) => statusLabelById(status.name);

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
