// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'WordPing';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonSave => 'Simpan';

  @override
  String get commonDelete => 'Hapus';

  @override
  String get commonAdd => 'Tambah';

  @override
  String get commonClose => 'Tutup';

  @override
  String get commonRetry => 'Coba lagi';

  @override
  String get commonNext => 'Berikutnya';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonConfirm => 'OK';

  @override
  String get commonLoading => 'Memuat';

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ko': 'Korea',
      'ja': 'Jepang',
      'zh': 'Mandarin',
      'es': 'Spanyol',
      'fr': 'Prancis',
      'de': 'Jerman',
      'pt': 'Portugis',
      'vi': 'Vietnam',
      'th': 'Thai',
      'id': 'Indonesia',
      'en': 'Inggris',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'Sen',
      'd2': 'Sel',
      'd3': 'Rab',
      'd4': 'Kam',
      'd5': 'Jum',
      'd6': 'Sab',
      'd7': 'Min',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get wordAddWord => 'Tambah kata';

  @override
  String get wordEditWord => 'Edit kata';

  @override
  String get wordExamples => 'Contoh';

  @override
  String wordExampleSource(String source) {
    return 'Sumber: $source';
  }

  @override
  String wordPartOfSpeech(String pos, String value) {
    String _temp0 = intl.Intl.selectLogic(pos, {
      'noun': 'Nomina',
      'verb': 'Verba',
      'adjective': 'Adjektiva',
      'adverb': 'Adverbia',
      'pronoun': 'Pronomina',
      'preposition': 'Preposisi',
      'conjunction': 'Konjungsi',
      'interjection': 'Interjeksi',
      'article': 'Artikel',
      'determiner': 'Determiner',
      'phrasalVerb': 'Phrasal verb',
      'idiom': 'Idiom',
      'phrase': 'Frasa',
      'other': '$value',
    });
    return '$_temp0';
  }

  @override
  String get wordEditTermRequired => 'Masukkan kata bahasa Inggris dulu.';

  @override
  String wordEditNoExamplesFound(String term) {
    return 'Tidak ada contoh untuk \'$term\'.';
  }

  @override
  String get wordEditExamplesAlreadyAdded =>
      'Semua contoh yang ditemukan sudah ditambahkan.';

  @override
  String wordEditExamplesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contoh ditambahkan.',
    );
    return '$_temp0';
  }

  @override
  String wordEditExamplesFetchFailed(String error) {
    return 'Gagal mengambil contoh: $error';
  }

  @override
  String get wordEditTermAndMeaningRequired =>
      'Masukkan kata dan minimal satu arti.';

  @override
  String get wordEditSaveFailed => 'Gagal menyimpan. Coba lagi.';

  @override
  String get wordEditSectionTerm => 'Kata';

  @override
  String get wordEditSectionMeaning => 'Arti & pelafalan';

  @override
  String get wordEditPhonetic => 'Fonetik';

  @override
  String get wordEditSearching => 'Mencari';

  @override
  String get wordEditFetchExamples => 'Ambil contoh';

  @override
  String get wordEditAddManually => 'Tambah manual';

  @override
  String get wordEditOptional => 'Opsional';

  @override
  String wordEditExampleNumber(int index) {
    return 'Contoh $index';
  }

  @override
  String get wordEditDeleteExample => 'Hapus contoh';

  @override
  String get wordEditSentence => 'Kalimat bahasa Inggris';

  @override
  String wordEditTranslationLabel(String language) {
    return 'Terjemahan ($language)';
  }

  @override
  String get wordEditTermLabel => 'Kata *';

  @override
  String get wordEditTermHint =>
      'Pilih kata yang tersimpan untuk mengisi arti dan contohnya secara otomatis.';

  @override
  String get wordEditPartOfSpeech => 'Kelas kata';

  @override
  String get wordEditPartOfSpeechNone => 'Tidak ada';

  @override
  String get wordEditManualExampleTitle => 'Tambah contoh manual';

  @override
  String get wordEditSentenceRequiredLabel => 'Kalimat bahasa Inggris *';

  @override
  String get wordEditSentenceRequired => 'Masukkan kalimat bahasa Inggris.';

  @override
  String wordEditPickerTitle(String term) {
    return 'Contoh untuk \'$term\'';
  }

  @override
  String get wordEditPickerDescription =>
      'Pilih contoh yang ingin ditambahkan. Kamu bisa mengetik terjemahan untuk kalimat yang belum punya.';

  @override
  String wordEditNoTranslation(String language) {
    return 'Tidak ada terjemahan bahasa $language';
  }

  @override
  String get wordEditPickerAttribution => 'Contoh dari Tatoeba · CC BY 2.0 FR';

  @override
  String wordEditAddSelectedExamples(int count) {
    return 'Tambah pilihan ($count)';
  }

  @override
  String get wordCreateLoadFailed => 'Gagal memuat. Coba lagi.';

  @override
  String get wordCreateSectionTitle => 'Masukkan kata';

  @override
  String get wordCreateWordbook => 'Buku kata';

  @override
  String get wordCreateNoWordbook => 'Belum ada buku kata';

  @override
  String get wordCreateReload => 'Muat ulang';

  @override
  String get wordCreateTermLabel => 'Kata';

  @override
  String get wordCreateLookingUp => 'Mencari';

  @override
  String get wordCreateAutoInputSettings => 'Pengaturan isi otomatis';

  @override
  String get wordCreateMeaningsOn => 'Arti aktif';

  @override
  String get wordCreateMeaningsOff => 'Arti nonaktif';

  @override
  String get wordCreateExamplesOn => 'Contoh aktif';

  @override
  String get wordCreateExamplesOff => 'Contoh nonaktif';

  @override
  String get wordCreateCollapse => 'Ciutkan';

  @override
  String get wordCreateExpand => 'Luaskan';

  @override
  String get wordCreateAutoMeanings => 'Isi arti otomatis';

  @override
  String get wordCreateAutoExamples => 'Isi contoh otomatis';

  @override
  String get wordDetailDictionaryMeaningsAdded =>
      'Arti kamus yang dipilih sudah ditambahkan.';

  @override
  String get wordDetailTitle => 'Detail kata';

  @override
  String get wordDetailFavorite => 'Tambah ke favorit';

  @override
  String get wordDetailUnfavorite => 'Hapus dari favorit';

  @override
  String get wordDetailAccentUs => 'Amerika';

  @override
  String get wordDetailAccentUk => 'Inggris';

  @override
  String get wordDetailMyMeanings => 'Arti saya';

  @override
  String get wordDetailListenExample => 'Dengarkan contoh';

  @override
  String get wordDetailGoogleTranslate => 'Google Terjemahan';

  @override
  String get meaningFieldsLabel => 'Arti';

  @override
  String get meaningFieldsLabelRequired => 'Arti *';

  @override
  String meaningFieldsLabelNumbered(int index) {
    return 'Arti $index';
  }

  @override
  String meaningFieldsRemove(int index) {
    return 'Hapus arti $index';
  }

  @override
  String get meaningFieldsAdd => 'Tambah arti';

  @override
  String get meaningFieldsEmptyError => 'Masukkan minimal satu arti.';

  @override
  String get meaningFieldsEditTitle => 'Edit arti';

  @override
  String get dictLookupAddFailed => 'Gagal menambahkan arti. Coba lagi.';

  @override
  String get dictLookupButton => 'Arti kamus';

  @override
  String dictLookupTitle(String term) {
    return '$term · Kamus';
  }

  @override
  String dictLookupFallbackNotice(String language) {
    return 'Entri tanpa arti bahasa $language menampilkan definisi bahasa Inggris.';
  }

  @override
  String get dictLookupLoadFailed => 'Gagal memuat arti kamus.';

  @override
  String get dictLookupNoResults =>
      'Arti kamus tidak ditemukan.\nPeriksa ejaan atau coba kamus lain.';

  @override
  String get dictLookupAlreadyAdded => 'Ditambahkan';

  @override
  String dictLookupAddSelected(int count) {
    return 'Tambah pilihan ($count)';
  }

  @override
  String get dictLookupLinkFailed => 'Gagal membuka tautan kamus.';

  @override
  String get dictLinksNaver => 'Naver (En–Ko)';

  @override
  String get dictLinksOxford => 'Oxford (En–En)';

  @override
  String get dictLinksOpenFailed => 'Gagal membuka kamus. Coba lagi.';

  @override
  String get dictLinksTitle => 'Lihat di kamus lain';

  @override
  String wordbookError(String error) {
    return 'Error: $error';
  }

  @override
  String get wordbookShareCode => 'Kode berbagi';

  @override
  String wordbookDeleteTitle(String name) {
    return 'Hapus \'$name\'';
  }

  @override
  String get wordbooksTitle => 'Buku kata saya';

  @override
  String get wordbooksNew => 'Buku kata baru';

  @override
  String get wordbooksEmpty =>
      'Belum ada buku kata.\nKetuk + untuk menambahkan.';

  @override
  String get wordbooksCreate => 'Buat';

  @override
  String get wordbooksNameLabel => 'Nama buku kata';

  @override
  String get wordbooksTagsLabel => 'Tag';

  @override
  String get wordbooksTagsHint =>
      'TOEIC, percakapan sehari-hari (pisahkan dengan koma)';

  @override
  String wordbooksWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kata',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksMenu => 'Menu buku kata';

  @override
  String get wordbooksMenuRename => 'Edit nama & tag';

  @override
  String get wordbooksShareSettings => 'Berbagi & visibilitas';

  @override
  String get wordbooksMenuDelete => 'Hapus buku kata';

  @override
  String get wordbooksEditTitle => 'Edit buku kata';

  @override
  String get wordbooksShareLoginRequired =>
      'Masuk untuk berbagi atau memublikasikan buku kata.';

  @override
  String get wordbooksVisibilityPrivate => 'Pribadi';

  @override
  String get wordbooksVisibilityShared => 'Kode berbagi';

  @override
  String get wordbooksVisibilityPublic => 'Publik';

  @override
  String get wordbooksVisibilityPrivateDesc =>
      'Hanya kamu yang bisa melihatnya.';

  @override
  String get wordbooksVisibilitySharedDesc =>
      'Siapa pun yang punya kode berbagi bisa menyalin buku kata ini.';

  @override
  String get wordbooksVisibilityPublicDesc =>
      'Tampil di tab Jelajahi, dan siapa pun bisa menyalinnya.';

  @override
  String get wordbooksCopyCode => 'Salin kode';

  @override
  String get wordbooksCodeCopied => 'Kode berbagi disalin.';

  @override
  String wordbooksDeleteWithWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count kata di buku kata ini juga akan dihapus.\nBuku kata yang dihapus tidak bisa dipulihkan.',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksDeleteEmpty =>
      'Buku kata yang dihapus tidak bisa dipulihkan.';

  @override
  String get wordbookDetailEmpty =>
      'Belum ada kata.\nKetuk tombol Tambah kata.';

  @override
  String wordbookDetailWordDeleted(String term) {
    return '\'$term\' dihapus';
  }

  @override
  String get wordbookDetailUndo => 'Urungkan';

  @override
  String get wordbookDetailEditWholeWord => 'Edit seluruh kata';

  @override
  String get wordbookDetailEditWord => 'Edit kata';

  @override
  String get wordbookDetailFavorite => 'Favorit';

  @override
  String get wordbookDetailUnfavorite => 'Hapus dari favorit';

  @override
  String get wordbookDetailEditMeaning => 'Edit arti';

  @override
  String get wordbookDetailEditAll => 'Edit semua';

  @override
  String get wordbookDetailStatusFresh => 'Baru';

  @override
  String get wordbookDetailStatusLearning => 'Dipelajari';

  @override
  String get wordbookDetailStatusCompleted => 'Dikuasai';

  @override
  String get wordbookDetailDeleteWordConfirm => 'Hapus kata ini?';

  @override
  String get wordbookDetailReleaseToDelete => 'Lepas untuk menghapus';

  @override
  String get exploreTitle => 'Jelajahi';

  @override
  String get exploreCodeNotFound =>
      'Tidak ada buku kata yang cocok dengan kode ini.';

  @override
  String get exploreImportFailed =>
      'Gagal mengimpor. Periksa koneksi internetmu.';

  @override
  String exploreCopyTitle(String title) {
    return 'Salin \'$title\'';
  }

  @override
  String exploreCopyConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Salin $count kata ke buku katamu?\nProgres belajar akan dimulai dari awal.',
    );
    return '$_temp0';
  }

  @override
  String get exploreCopy => 'Salin';

  @override
  String exploreImported(String title) {
    return '\'$title\' diimpor.';
  }

  @override
  String get exploreLoggedOutHeadline => 'Temukan\nbuku kata baru';

  @override
  String get exploreLoginRequired =>
      'Masuk untuk menjelajahi buku kata yang dibagikan.';

  @override
  String get exploreGoToLogin => 'Masuk';

  @override
  String get exploreSupabaseRequired =>
      'Tersedia setelah terhubung ke Supabase.';

  @override
  String get exploreImportByCode => 'Impor dengan kode berbagi';

  @override
  String get exploreCodeHint => 'Tempel kode yang kamu terima';

  @override
  String get exploreImport => 'Impor';

  @override
  String get exploreCodeHelp =>
      'Untuk berbagi, salin kode dari Berbagi & visibilitas di menu buku kata.';

  @override
  String get explorePublicWordbooks => 'Buku kata publik';

  @override
  String get explorePublicLoadFailed =>
      'Gagal memuat buku kata publik.\nTarik ke bawah untuk memuat ulang.';

  @override
  String get explorePublicEmpty => 'Belum ada buku kata publik.';

  @override
  String get loginMigrateTitle => 'Impor buku kata lokal';

  @override
  String loginMigrateConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Salin $count buku kata dari perangkat ini ke cloud?\nBuku kata yang sudah ada di cloud akan dilewati.',
    );
    return '$_temp0';
  }

  @override
  String get loginLater => 'Nanti';

  @override
  String get loginImport => 'Impor';

  @override
  String loginMigrated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count buku kata diimpor.',
    );
    return '$_temp0';
  }

  @override
  String get loginAlreadyInCloud => 'Semua buku kata sudah ada di cloud.';

  @override
  String get loginErrorInvalidCredentials => 'Email atau kata sandi salah.';

  @override
  String get loginErrorUserExists =>
      'Email ini sudah terdaftar. Silakan masuk.';

  @override
  String get loginErrorWeakPassword =>
      'Kata sandi terlalu pendek. Gunakan minimal 6 karakter.';

  @override
  String get loginErrorEmailNotConfirmed =>
      'Verifikasi email kamu. Cek kotak masuk.';

  @override
  String get loginErrorRateLimit =>
      'Terlalu banyak permintaan. Coba lagi nanti.';

  @override
  String loginErrorGeneric(String message) {
    return 'Gagal masuk. ($message)';
  }

  @override
  String get loginErrorNetwork =>
      'Permintaan tidak dapat diproses. Periksa koneksi internet lalu coba lagi.';

  @override
  String get loginTitle => 'Masuk';

  @override
  String get loginTagline =>
      'Belajar mudah lewat contoh, konsisten lewat pengingat';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Kata sandi';

  @override
  String get loginSignUpWithEmail => 'Daftar dengan email';

  @override
  String get loginContinueWithGoogle => 'Lanjutkan dengan Google';

  @override
  String get navHome => 'Beranda';

  @override
  String get navWordbooks => 'Buku kata';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsTranslationSection => 'Arti · Terjemahan contoh';

  @override
  String get settingsTranslationHelp =>
      'Otomatis mengikuti bahasa dan wilayah perangkatmu. Terjemahan digunakan untuk arti dan contoh dari kata yang baru dicari. Arti tanpa terjemahan menampilkan definisi bahasa Inggris, dan terjemahan contoh dibiarkan kosong. Konten yang sudah disimpan tidak berubah otomatis.';

  @override
  String get settingsAppLanguageNote =>
      'Aplikasi juga ditampilkan dalam bahasa ini. Bahasa yang belum diterjemahkan di aplikasi akan ditampilkan dalam bahasa Inggris.';

  @override
  String get settingsReviewMixSection => 'Rasio campuran ulasan';

  @override
  String get settingsReviewMixLabel => 'Campurkan kata yang sudah dikuasai';

  @override
  String settingsReviewMixHelp(int total, int mixed) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'soal',
    );
    return 'Mencampurkan kata \'dikuasai\' sebanyak rasio ini ke sesi ulasan untuk memperkuat ingatan jangka panjang. (mis. $mixed dari $total $_temp0)';
  }

  @override
  String get settingsReminderSection => 'Pengingat · Ulasan';

  @override
  String get settingsReminderToggle => 'Terima pengingat ulasan';

  @override
  String get settingsReminderOff => 'Pengingat nonaktif.';

  @override
  String get settingsReminderNoActive =>
      'Tidak ada jadwal pengingat yang aktif.';

  @override
  String settingsReminderSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pengingat',
    );
    return 'Berulang tiap minggu · $_temp0 per minggu. Kata yang sedang dipelajari muncul sesuai urutan jadwal ulasannya.';
  }

  @override
  String settingsReminderCapped(int limit) {
    return 'Sebagian pengingat terakhir tidak dijadwalkan karena melebihi batas perangkat, yaitu $limit notifikasi terjadwal.';
  }

  @override
  String get settingsTtsSection => 'Pelafalan · TTS';

  @override
  String get settingsTtsDefault => 'Aksen default';

  @override
  String get settingsTtsDefaultHelp =>
      'Pilih aksen untuk membacakan kata dan contoh.';

  @override
  String get settingsTtsUs => 'Amerika';

  @override
  String get settingsTtsUk => 'Inggris';

  @override
  String get settingsTtsQuality => 'Kualitas suara';

  @override
  String get settingsTtsQualityValue => 'TTS perangkat (gratis)';

  @override
  String get settingsTatoebaCredit =>
      'Contoh eksternal: Tatoeba · CC BY 2.0 FR';

  @override
  String get reminderEveryDay => 'Setiap hari';

  @override
  String get reminderNoWeekdays => 'Tidak ada hari';

  @override
  String get reminderWeekdays => 'Hari kerja';

  @override
  String get reminderWeekends => 'Akhir pekan';

  @override
  String reminderIntervalMinutes(int minutes) {
    return 'Tiap $minutes mnt';
  }

  @override
  String reminderIntervalHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Tiap $hours jam',
    );
    return '$_temp0';
  }

  @override
  String reminderIntervalHoursMinutes(int hours, int minutes) {
    return 'Tiap $hours jam $minutes mnt';
  }

  @override
  String get reminderAddSchedule => 'Tambah jadwal pengingat';

  @override
  String get reminderEditSchedule => 'Edit jadwal pengingat';

  @override
  String get reminderStart => 'Mulai';

  @override
  String get reminderEnd => 'Selesai';

  @override
  String get reminderCrossesMidnight =>
      'Jika waktu selesai lebih awal dari waktu mulai, pengingat berlanjut melewati tengah malam hingga waktu selesai keesokan harinya.';

  @override
  String get reminderWeekdaysTitle => 'Hari pengingat';

  @override
  String get reminderWeekdaysRequired => 'Pilih minimal satu hari.';

  @override
  String get reminderInterval => 'Interval pengingat';

  @override
  String get reminderWordsPerAlert => 'Per pengingat';

  @override
  String get reminderDecreaseWords => 'Kurangi kata';

  @override
  String get reminderIncreaseWords => 'Tambah kata';

  @override
  String reminderWordCount(int count) {
    return '$count';
  }

  @override
  String reminderWordCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kata',
    );
    return '$_temp0';
  }

  @override
  String reminderTimesPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kali sehari',
    );
    return '$_temp0';
  }

  @override
  String reminderPreview(String days, int count, String times) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kali',
    );
    return '$days, $_temp0 · $times';
  }

  @override
  String get translationLanguageLabel => 'Bahasa terjemahan';

  @override
  String translationLanguageAuto(String language) {
    return 'Otomatis · $language';
  }

  @override
  String get notificationChannelName => 'Notifikasi kata';

  @override
  String get notificationChannelDescription =>
      'Menampilkan kata dan artinya sebagai notifikasi pada hari dan jam pilihan';

  @override
  String get notificationTitleDefault => 'Kata hari ini';

  @override
  String notificationTitleWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kata hari ini',
    );
    return '$_temp0';
  }

  @override
  String get notificationBodyDefault =>
      'Tambahkan kata dan kata beserta artinya akan muncul di sini.';

  @override
  String homeError(String error) {
    return 'Error: $error';
  }

  @override
  String get homeGreeting => 'Siap belajar kata hari ini?';

  @override
  String get homeTodayStudy => 'Dipelajari hari ini';

  @override
  String homeTotalWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Total $count kata',
    );
    return '$_temp0';
  }

  @override
  String get homeAccuracy => 'Akurasi';

  @override
  String homeCompletedWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dikuasai',
    );
    return '$_temp0';
  }

  @override
  String get homeWordOfTheDay => 'Kata hari ini';

  @override
  String get homeQuickStart => 'Mulai cepat';

  @override
  String get homeQuickGuessWord => 'Isi kosong · ketik';

  @override
  String get homeQuickFillBlank => 'Isi kosong · pilih';

  @override
  String get homeQuickBrowseWordbooks => 'Lihat buku kata';

  @override
  String get homeCreateWordbookFirst => 'Buat buku kata dulu.';

  @override
  String get homeEditWord => 'Edit kata';

  @override
  String get homeListenWord => 'Dengarkan kata';

  @override
  String get homeSeeDetails => 'Lihat detail';

  @override
  String get homeReviewAllDone => 'Semua ulasan\nhari ini selesai!';

  @override
  String homeReviewWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kata\nmenunggumu',
    );
    return '$_temp0';
  }

  @override
  String homeCompletedBadge(int count) {
    return '$count\ndikuasai';
  }

  @override
  String homeReviewBreakdown(int due, int mixed) {
    return 'Baru/ulasan $due · Campuran $mixed';
  }

  @override
  String get homeStart => 'Mulai';

  @override
  String get reviewNoExample =>
      '(Tidak ada contoh — ketik kata berdasarkan artinya)';

  @override
  String get reviewTitle => 'Ulasan contoh';

  @override
  String get reviewEmpty => 'Tidak ada kartu hari ini';

  @override
  String get reviewFillBlankTitle => 'Isi bagian kosong';

  @override
  String get reviewChoiceInstruction =>
      'Pilih kata yang cocok dengan contoh dan artinya';

  @override
  String get reviewInputInstruction =>
      'Ketik kata yang cocok dengan contoh dan artinya';

  @override
  String reviewOtherExample(int current, int total) {
    return 'Contoh lain  $current/$total';
  }

  @override
  String get reviewDontKnow => 'Tidak tahu';

  @override
  String get reviewInputHint => 'Ketik kata';

  @override
  String reviewHint(String hint) {
    return 'Petunjuk: $hint';
  }

  @override
  String get reviewCheckAnswer => 'Cek jawaban';

  @override
  String get reviewCorrect => 'Benar!';

  @override
  String get reviewWrongAnswerIs => 'Belum tepat. Jawabannya';

  @override
  String reviewSource(String source) {
    return 'Sumber: $source';
  }

  @override
  String get reviewMixedNotice =>
      'Kata yang sudah dikuasai dicampurkan untuk diulas';

  @override
  String get reviewSummaryTitle => 'Ulasan selesai';

  @override
  String get reviewSummaryDone => 'Kamu sudah menyelesaikan ulasan';

  @override
  String reviewSummaryScore(int correct, int total) {
    return '$correct dari $total benar';
  }

  @override
  String get reviewGoHome => 'Kembali ke beranda';

  @override
  String get dictionaryRateLimited =>
      'Pencarian kamus dibatasi sementara. Coba lagi sebentar lagi.';

  @override
  String get dictionaryConnectionFailed =>
      'Tidak dapat terhubung ke kamus. Coba lagi sebentar lagi.';

  @override
  String get dictionaryTimeout => 'Kamus terlalu lama merespons. Coba lagi.';

  @override
  String get dictionaryLoadFailed =>
      'Gagal memuat arti kamus. Periksa koneksi internet lalu coba lagi.';

  @override
  String get draftDictionaryUnavailable =>
      'Tidak dapat terhubung ke kamus. Masukkan arti sendiri atau cari lagi.';

  @override
  String get draftMeaningNotFound =>
      'Arti tidak ditemukan. Masukkan sendiri atau cari di kamus.';

  @override
  String draftNoTranslationUsedEnglish(String language) {
    return 'Kamus tidak punya arti bahasa $language, jadi definisi bahasa Inggris digunakan. Kamu bisa mengubah bahasa terjemahan di Pengaturan.';
  }

  @override
  String draftSomeUsedEnglish(String language) {
    return 'Entri tanpa arti bahasa $language diisi dengan definisi bahasa Inggris.';
  }

  @override
  String get draftExamplesRetry =>
      'Kamu bisa memuat contoh lagi lewat ‘Ambil contoh’ di bawah.';

  @override
  String get speakListen => 'Dengarkan';

  @override
  String get speakListenExample => 'Dengarkan contoh';

  @override
  String get adPreview => 'Pratinjau iklan';

  @override
  String get addWordButton => 'Tambah kata';

  @override
  String get wordCreateExampleTranslations => 'Sertakan terjemahan';

  @override
  String get wordCreateNoExampleTranslations => 'Tanpa terjemahan';

  @override
  String get homeRemainingCards => 'Kartu tersisa';

  @override
  String homeTodayCards(int count) {
    return '$count untuk diulang hari ini';
  }

  @override
  String get homeStartButton => 'Mulai';

  @override
  String get homeNoCardsToday => 'Tidak ada kartu hari ini';

  @override
  String reviewRemaining(int count) {
    return 'Sisa $count';
  }

  @override
  String get reviewKeep => 'Simpan';

  @override
  String get reviewDiscard => 'Buang';

  @override
  String reviewDoneTitle(int count) {
    return '$count kartu selesai';
  }

  @override
  String wordbooksCardsLeft(int count) {
    return 'tersisa · total $count';
  }

  @override
  String get wordbookCardsLeftSuffix => 'tersisa';

  @override
  String get wordbookDetailAllDiscarded => 'Tidak ada kartu tersisa';

  @override
  String wordbookDetailDiscarded(String term) {
    return '\'$term\' dibuang';
  }

  @override
  String get wordbookDetailReleaseToDiscard => 'Lepas untuk membuang';

  @override
  String get wordbookAddWordShort => 'Kata';

  @override
  String get discardedTitle => 'Kartu dibuang';

  @override
  String get discardedEmpty => 'Belum ada yang dibuang';

  @override
  String get discardedRestore => 'Kembalikan';

  @override
  String get wordAddMeaningSelect => 'Pilih arti';

  @override
  String get wordAddManualInput => 'Ketik arti';

  @override
  String get wordAddMeaningLabel => 'Arti';

  @override
  String wordAddExamplesOf(String pos) {
    return 'Contoh $pos';
  }

  @override
  String wordAddSelectedCount(int count) {
    return '$count dipilih';
  }

  @override
  String get wordAddWriteExample => 'Tulis contoh';

  @override
  String get wordAddSave => 'Tambahkan';

  @override
  String get wordAddAlreadyInDeck => 'Sudah ada di dek';

  @override
  String get wordAddNoResults => 'Tidak ada di kamus';

  @override
  String get wordAddLookupFailed => 'Kamus tidak tersedia';

  @override
  String get wordAddAutoInput => 'Isi otomatis';

  @override
  String get wordAddAutoOff => 'Isi otomatis mati';

  @override
  String get wordAddExampleTranslation => 'Terjemahan';

  @override
  String get wordAddNoExamples =>
      'Tidak ada contoh. Kata tetap bisa ditambahkan tanpa contoh.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSlate => 'Batu';

  @override
  String get themeNavy => 'Biru tua';

  @override
  String get themeBrown => 'Cokelat';

  @override
  String get themePlum => 'Plum';

  @override
  String get themeCharcoal => 'Arang';

  @override
  String get themeCustom => 'Kustom';

  @override
  String get themeCustomTitle => 'Tema kustom';

  @override
  String get themeBase => 'Dasar';

  @override
  String get themePoint => 'Aksen';

  @override
  String get themeAutoText => 'Warna teks menyesuaikan';

  @override
  String get themeApply => 'Terapkan';

  @override
  String get themeReset => 'Atur ulang';

  @override
  String get settingsLanguageSection => 'Bahasa';

  @override
  String get settingsLanguageRow => 'Arti · contoh · aplikasi';

  @override
  String get settingsFollowDevice => 'Ikuti perangkat';

  @override
  String get settingsReviewSection => 'Ulangan';

  @override
  String get settingsSessionSize => 'Kartu per sesi ulang';

  @override
  String get settingsMixLabel => 'Campur kartu dibuang';

  @override
  String settingsMixExample(int total, int mixed) {
    return '$mixed dari $total';
  }

  @override
  String get settingsWordAddSection => 'Tambah kata';

  @override
  String get settingsNotificationsSection => 'Pengingat';

  @override
  String get settingsReminderMaster => 'Notifikasi kata';

  @override
  String get settingsAddSlot => 'Rentang pengingat';

  @override
  String settingsWeeklyCount(int count) {
    return '$count× seminggu';
  }

  @override
  String reminderCardCount(int count) {
    return '$count kartu';
  }

  @override
  String get settingsPronunciationSection => 'Pelafalan';

  @override
  String get settingsAccent => 'Aksen';

  @override
  String get settingsVoice => 'Suara';

  @override
  String get settingsVoiceDefault => 'Bawaan';

  @override
  String get settingsSpeed => 'Kecepatan';

  @override
  String get settingsSpeedSlow => 'Lambat';

  @override
  String get settingsSpeedNormal => 'Normal';

  @override
  String get settingsSpeedFast => 'Cepat';

  @override
  String get settingsRecorded => 'Rekaman manusia untuk kata';

  @override
  String get settingsRecordedHelp => 'Jika tidak ada, pakai suara';

  @override
  String get settingsAbout => 'Tentang · sumber';

  @override
  String get settingsPrivacy => 'Kebijakan privasi';

  @override
  String get aboutDataSources => 'Sumber data';

  @override
  String get aboutUseMeanings => 'Arti · contoh kamus';

  @override
  String get aboutUseOnline => 'Kamus daring';

  @override
  String get aboutUseExamples => 'Contoh terjemahan';

  @override
  String get aboutUseRecordings => 'Rekaman kata';

  @override
  String get aboutApp => 'Aplikasi';

  @override
  String get aboutVersion => 'Versi';

  @override
  String get aboutLicenses => 'Lisensi sumber terbuka';

  @override
  String reminderPerDayTotal(int times, int cards) {
    return '$times× sehari · $cards kartu';
  }

  @override
  String settingsPackDownloading(String size) {
    return 'Mengunduh terjemahan contoh · $size';
  }

  @override
  String settingsPackReady(String size) {
    return 'Terjemahan contoh siap · $size';
  }

  @override
  String get settingsPackFailed => 'Gagal mengunduh terjemahan contoh';

  @override
  String get settingsPackRetry => 'Coba lagi';

  @override
  String get settingsExampleDataSection => 'Data contoh';

  @override
  String get settingsExampleData => 'Unduh terjemahan contoh';

  @override
  String get settingsPackNone => 'Belum diunduh';

  @override
  String get settingsPackNotNeeded => 'Bahasa Inggris tidak perlu terjemahan';

  @override
  String settingsPackVersion(int version, String size) {
    return 'Diunduh · v$version · $size';
  }

  @override
  String get settingsPackUpdate => 'Periksa pembaruan';

  @override
  String settingsPackUpToDate(int version) {
    return 'Sudah terbaru (v$version)';
  }

  @override
  String settingsPackUpdated(int version) {
    return 'Diperbarui ke v$version';
  }

  @override
  String get examplePromptTitle => 'Unduh terjemahan contoh?';

  @override
  String examplePromptBody(String language, String size) {
    return 'Terjemahan $language untuk contoh bahasa Inggris akan diunduh ke perangkat$size. Bisa diubah kapan saja di Setelan › Data contoh.';
  }

  @override
  String get examplePromptAccept => 'Unduh';

  @override
  String get examplePromptDecline => 'Nanti saja';

  @override
  String get wordAddPosLabel => 'Jenis kata';

  @override
  String get wordAddPosUnknown => 'Tidak tahu';

  @override
  String get homeQuickGuessFromMeaning => 'Tebak kata dari artinya';

  @override
  String get wordFoundExample => 'Contoh ditemukan';

  @override
  String get wordAddFoundExample => 'Tambah contoh';

  @override
  String wordbookFoundExamples(int count) {
    return '$count contoh ditemukan';
  }

  @override
  String get wordAddScanExample => 'Ambil contoh dari foto';

  @override
  String get wordScanCamera => 'Ambil foto';

  @override
  String get wordScanGallery => 'Pilih dari galeri';

  @override
  String get wordScanFailed => 'Tidak dapat membaca teks di foto';

  @override
  String wordScanNoSentence(String term) {
    return 'Tidak ada kalimat dengan \'$term\' di foto';
  }

  @override
  String get exampleSourcePhoto => 'Foto saya';

  @override
  String wordScanAdded(int count) {
    return '$count kalimat ditambahkan dari foto';
  }

  @override
  String homeNewReviewBreakdown(int fresh, int review) {
    return 'Baru $fresh · Ulang $review';
  }

  @override
  String get settingsAnswerStyle => 'Cara menjawab';

  @override
  String get settingsAnswerInput => 'Ketik kata';

  @override
  String get settingsAnswerChoice => 'Pilih dari 4 pilihan';

  @override
  String get settingsAnswerHelp =>
      'Dipakai saat mengulang dengan Mulai di beranda.';

  @override
  String get sampleWelcomeMeaning => 'selamat datang';

  @override
  String get sampleWelcomeExample1 => 'Selamat datang di WordPing!';

  @override
  String get sampleWelcomeExample2 => 'Selamat datang kembali, semuanya.';

  @override
  String get homeAddCardHint =>
      'Ketik kata bahasa Inggris, arti dan contohnya dicarikan untuk kartu baru';
}
