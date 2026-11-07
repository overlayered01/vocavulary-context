// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Vocab with Examples';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonDelete => 'Xóa';

  @override
  String get commonAdd => 'Thêm';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonNext => 'Tiếp';

  @override
  String get commonEdit => 'Sửa';

  @override
  String get commonConfirm => 'OK';

  @override
  String get commonLoading => 'Đang tải';

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ko': 'Tiếng Hàn',
      'ja': 'Tiếng Nhật',
      'zh': 'Tiếng Trung',
      'es': 'Tiếng Tây Ban Nha',
      'fr': 'Tiếng Pháp',
      'de': 'Tiếng Đức',
      'pt': 'Tiếng Bồ Đào Nha',
      'vi': 'Tiếng Việt',
      'th': 'Tiếng Thái',
      'id': 'Tiếng Indonesia',
      'en': 'Tiếng Anh',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'T2',
      'd2': 'T3',
      'd3': 'T4',
      'd4': 'T5',
      'd5': 'T6',
      'd6': 'T7',
      'd7': 'CN',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get wordAddWord => 'Thêm từ';

  @override
  String get wordEditWord => 'Sửa từ';

  @override
  String get wordExamples => 'Ví dụ';

  @override
  String wordExampleSource(String source) {
    return 'Nguồn: $source';
  }

  @override
  String wordPartOfSpeech(String pos, String value) {
    String _temp0 = intl.Intl.selectLogic(pos, {
      'noun': 'Danh từ',
      'verb': 'Động từ',
      'adjective': 'Tính từ',
      'adverb': 'Trạng từ',
      'pronoun': 'Đại từ',
      'preposition': 'Giới từ',
      'conjunction': 'Liên từ',
      'interjection': 'Thán từ',
      'article': 'Mạo từ',
      'determiner': 'Từ hạn định',
      'phrasalVerb': 'Cụm động từ',
      'idiom': 'Thành ngữ',
      'phrase': 'Cụm từ',
      'other': '$value',
    });
    return '$_temp0';
  }

  @override
  String get wordEditTermRequired => 'Vui lòng nhập từ tiếng Anh trước.';

  @override
  String wordEditNoExamplesFound(String term) {
    return 'Không tìm thấy ví dụ nào cho \'$term\'.';
  }

  @override
  String get wordEditExamplesAlreadyAdded =>
      'Tất cả ví dụ đã lấy đều đã được thêm.';

  @override
  String wordEditExamplesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã thêm $count ví dụ.',
    );
    return '$_temp0';
  }

  @override
  String wordEditExamplesFetchFailed(String error) {
    return 'Không lấy được ví dụ: $error';
  }

  @override
  String get wordEditTermAndMeaningRequired =>
      'Vui lòng nhập từ và ít nhất một nghĩa.';

  @override
  String get wordEditSaveFailed => 'Không lưu được. Vui lòng thử lại.';

  @override
  String get wordEditSectionTerm => 'Từ';

  @override
  String get wordEditSectionMeaning => 'Nghĩa & phát âm';

  @override
  String get wordEditPhonetic => 'Phiên âm';

  @override
  String get wordEditSearching => 'Đang tìm';

  @override
  String get wordEditFetchExamples => 'Lấy ví dụ';

  @override
  String get wordEditAddManually => 'Tự thêm';

  @override
  String get wordEditOptional => 'Tùy chọn';

  @override
  String wordEditExampleNumber(int index) {
    return 'Ví dụ $index';
  }

  @override
  String get wordEditDeleteExample => 'Xóa ví dụ';

  @override
  String get wordEditSentence => 'Câu tiếng Anh';

  @override
  String wordEditTranslationLabel(String language) {
    return 'Bản dịch ($language)';
  }

  @override
  String get wordEditTermLabel => 'Từ *';

  @override
  String get wordEditTermHint =>
      'Chọn một từ đã lưu để tự động điền nghĩa và ví dụ.';

  @override
  String get wordEditPartOfSpeech => 'Từ loại';

  @override
  String get wordEditPartOfSpeechNone => 'Không chọn';

  @override
  String get wordEditManualExampleTitle => 'Tự thêm ví dụ';

  @override
  String get wordEditSentenceRequiredLabel => 'Câu tiếng Anh *';

  @override
  String get wordEditSentenceRequired => 'Vui lòng nhập câu tiếng Anh.';

  @override
  String wordEditPickerTitle(String term) {
    return 'Ví dụ cho \'$term\'';
  }

  @override
  String get wordEditPickerDescription =>
      'Chọn ví dụ muốn thêm. Bạn có thể tự nhập bản dịch cho câu chưa có bản dịch.';

  @override
  String wordEditNoTranslation(String language) {
    return 'Chưa có bản dịch $language';
  }

  @override
  String get wordEditPickerAttribution => 'Ví dụ từ Tatoeba · CC BY 2.0 FR';

  @override
  String wordEditAddSelectedExamples(int count) {
    return 'Thêm mục đã chọn ($count)';
  }

  @override
  String get wordCreateLoadFailed => 'Không tải được. Vui lòng thử lại.';

  @override
  String get wordCreateSectionTitle => 'Nhập từ';

  @override
  String get wordCreateWordbook => 'Sổ từ';

  @override
  String get wordCreateNoWordbook => 'Chưa có sổ từ';

  @override
  String get wordCreateReload => 'Tải lại';

  @override
  String get wordCreateTermLabel => 'Từ';

  @override
  String get wordCreateLookingUp => 'Đang tra';

  @override
  String get wordCreateAutoInputSettings => 'Cài đặt tự động điền';

  @override
  String get wordCreateMeaningsOn => 'Nghĩa: bật';

  @override
  String get wordCreateMeaningsOff => 'Nghĩa: tắt';

  @override
  String get wordCreateExamplesOn => 'Ví dụ: bật';

  @override
  String get wordCreateExamplesOff => 'Ví dụ: tắt';

  @override
  String get wordCreateCollapse => 'Thu gọn';

  @override
  String get wordCreateExpand => 'Mở rộng';

  @override
  String get wordCreateAutoMeanings => 'Tự động điền nghĩa';

  @override
  String get wordCreateAutoExamples => 'Tự động điền ví dụ';

  @override
  String get wordDetailDictionaryMeaningsAdded =>
      'Đã thêm các nghĩa từ điển đã chọn.';

  @override
  String get wordDetailTitle => 'Chi tiết từ';

  @override
  String get wordDetailFavorite => 'Thêm vào yêu thích';

  @override
  String get wordDetailUnfavorite => 'Bỏ yêu thích';

  @override
  String get wordDetailAccentUs => 'Anh-Mỹ';

  @override
  String get wordDetailAccentUk => 'Anh-Anh';

  @override
  String get wordDetailMyMeanings => 'Nghĩa của tôi';

  @override
  String get wordDetailListenExample => 'Nghe ví dụ';

  @override
  String get wordDetailGoogleTranslate => 'Google Dịch';

  @override
  String get meaningFieldsLabel => 'Nghĩa';

  @override
  String get meaningFieldsLabelRequired => 'Nghĩa *';

  @override
  String meaningFieldsLabelNumbered(int index) {
    return 'Nghĩa $index';
  }

  @override
  String meaningFieldsRemove(int index) {
    return 'Xóa nghĩa $index';
  }

  @override
  String get meaningFieldsAdd => 'Thêm nghĩa';

  @override
  String get meaningFieldsEmptyError => 'Vui lòng nhập ít nhất một nghĩa.';

  @override
  String get meaningFieldsEditTitle => 'Sửa nghĩa';

  @override
  String get dictLookupAddFailed => 'Không thêm được nghĩa. Vui lòng thử lại.';

  @override
  String get dictLookupButton => 'Nghĩa từ điển';

  @override
  String dictLookupTitle(String term) {
    return '$term · Từ điển';
  }

  @override
  String dictLookupFallbackNotice(String language) {
    return 'Mục không có nghĩa $language sẽ hiển thị định nghĩa tiếng Anh.';
  }

  @override
  String get dictLookupLoadFailed => 'Không tải được nghĩa từ điển.';

  @override
  String get dictLookupNoResults =>
      'Không tìm thấy nghĩa trong từ điển.\nHãy kiểm tra chính tả hoặc thử từ điển khác.';

  @override
  String get dictLookupAlreadyAdded => 'Đã thêm';

  @override
  String dictLookupAddSelected(int count) {
    return 'Thêm mục đã chọn ($count)';
  }

  @override
  String get dictLookupLinkFailed => 'Không mở được liên kết từ điển.';

  @override
  String get dictLinksNaver => 'Naver (Anh–Hàn)';

  @override
  String get dictLinksOxford => 'Oxford (Anh–Anh)';

  @override
  String get dictLinksOpenFailed => 'Không mở được từ điển. Vui lòng thử lại.';

  @override
  String get dictLinksTitle => 'Xem thêm trong từ điển';

  @override
  String wordbookError(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get wordbookShareCode => 'Mã chia sẻ';

  @override
  String wordbookDeleteTitle(String name) {
    return 'Xóa \'$name\'';
  }

  @override
  String get wordbooksTitle => 'Sổ từ của tôi';

  @override
  String get wordbooksNew => 'Sổ từ mới';

  @override
  String get wordbooksEmpty => 'Chưa có sổ từ nào.\nNhấn + để thêm.';

  @override
  String get wordbooksCreate => 'Tạo';

  @override
  String get wordbooksNameLabel => 'Tên sổ từ';

  @override
  String get wordbooksTagsLabel => 'Thẻ';

  @override
  String get wordbooksTagsHint =>
      'TOEIC, giao tiếp hằng ngày (phân tách bằng dấu phẩy)';

  @override
  String wordbooksWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count từ',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksMenu => 'Menu sổ từ';

  @override
  String get wordbooksMenuRename => 'Sửa tên & thẻ';

  @override
  String get wordbooksShareSettings => 'Chia sẻ & công khai';

  @override
  String get wordbooksMenuDelete => 'Xóa sổ từ';

  @override
  String get wordbooksEditTitle => 'Sửa sổ từ';

  @override
  String get wordbooksShareLoginRequired =>
      'Đăng nhập để chia sẻ hoặc công khai sổ từ.';

  @override
  String get wordbooksVisibilityPrivate => 'Riêng tư';

  @override
  String get wordbooksVisibilityShared => 'Mã chia sẻ';

  @override
  String get wordbooksVisibilityPublic => 'Công khai';

  @override
  String get wordbooksVisibilityPrivateDesc => 'Chỉ mình bạn xem được.';

  @override
  String get wordbooksVisibilitySharedDesc =>
      'Ai có mã chia sẻ đều có thể sao chép sổ từ này.';

  @override
  String get wordbooksVisibilityPublicDesc =>
      'Hiển thị trong tab Khám phá để ai cũng có thể sao chép.';

  @override
  String get wordbooksCopyCode => 'Sao chép mã';

  @override
  String get wordbooksCodeCopied => 'Đã sao chép mã chia sẻ.';

  @override
  String wordbooksDeleteWithWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count từ trong sổ từ này cũng sẽ bị xóa.\nSổ từ đã xóa không thể khôi phục.',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksDeleteEmpty => 'Sổ từ đã xóa không thể khôi phục.';

  @override
  String get wordbookDetailEmpty => 'Chưa có từ nào.\nNhấn nút Thêm từ.';

  @override
  String wordbookDetailWordDeleted(String term) {
    return 'Đã xóa \'$term\'';
  }

  @override
  String get wordbookDetailUndo => 'Hoàn tác';

  @override
  String get wordbookDetailEditWholeWord => 'Sửa toàn bộ từ';

  @override
  String get wordbookDetailEditWord => 'Sửa từ';

  @override
  String get wordbookDetailFavorite => 'Yêu thích';

  @override
  String get wordbookDetailUnfavorite => 'Bỏ yêu thích';

  @override
  String get wordbookDetailEditMeaning => 'Sửa nghĩa';

  @override
  String get wordbookDetailEditAll => 'Sửa tất cả';

  @override
  String get wordbookDetailStatusFresh => 'Mới';

  @override
  String get wordbookDetailStatusLearning => 'Đang học';

  @override
  String get wordbookDetailStatusCompleted => 'Đã thuộc';

  @override
  String get wordbookDetailDeleteWordConfirm => 'Xóa từ này?';

  @override
  String get wordbookDetailReleaseToDelete => 'Thả ra để xóa';

  @override
  String get exploreTitle => 'Khám phá';

  @override
  String get exploreCodeNotFound =>
      'Không có sổ từ chia sẻ nào khớp với mã này.';

  @override
  String get exploreImportFailed =>
      'Không nhập được. Vui lòng kiểm tra kết nối mạng.';

  @override
  String exploreCopyTitle(String title) {
    return 'Sao chép \'$title\'';
  }

  @override
  String exploreCopyConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Sao chép $count từ vào sổ từ của bạn?\nTiến độ học sẽ bắt đầu lại từ đầu.',
    );
    return '$_temp0';
  }

  @override
  String get exploreCopy => 'Sao chép';

  @override
  String exploreImported(String title) {
    return 'Đã nhập \'$title\'.';
  }

  @override
  String get exploreLoggedOutHeadline => 'Khám phá\nsổ từ mới';

  @override
  String get exploreLoginRequired =>
      'Đăng nhập để khám phá các sổ từ được chia sẻ.';

  @override
  String get exploreGoToLogin => 'Đăng nhập';

  @override
  String get exploreSupabaseRequired => 'Có thể dùng sau khi kết nối Supabase.';

  @override
  String get exploreImportByCode => 'Nhập bằng mã chia sẻ';

  @override
  String get exploreCodeHint => 'Dán mã bạn nhận được';

  @override
  String get exploreImport => 'Nhập';

  @override
  String get exploreCodeHelp =>
      'Sao chép mã trong mục Chia sẻ & công khai ở menu sổ từ để chia sẻ.';

  @override
  String get explorePublicWordbooks => 'Sổ từ công khai';

  @override
  String get explorePublicLoadFailed =>
      'Không tải được sổ từ công khai.\nKéo xuống để làm mới.';

  @override
  String get explorePublicEmpty => 'Chưa có sổ từ công khai nào.';

  @override
  String get loginMigrateTitle => 'Nhập sổ từ trên máy';

  @override
  String loginMigrateConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Sao chép $count sổ từ tạo trên thiết bị này lên đám mây?\nSổ từ đã có trên đám mây sẽ được bỏ qua.',
    );
    return '$_temp0';
  }

  @override
  String get loginLater => 'Để sau';

  @override
  String get loginImport => 'Nhập';

  @override
  String loginMigrated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã nhập $count sổ từ.',
    );
    return '$_temp0';
  }

  @override
  String get loginAlreadyInCloud => 'Tất cả sổ từ đã có trên đám mây.';

  @override
  String get loginErrorInvalidCredentials => 'Email hoặc mật khẩu không đúng.';

  @override
  String get loginErrorUserExists =>
      'Email này đã được đăng ký. Vui lòng đăng nhập.';

  @override
  String get loginErrorWeakPassword =>
      'Mật khẩu quá ngắn. Hãy dùng ít nhất 6 ký tự.';

  @override
  String get loginErrorEmailNotConfirmed =>
      'Vui lòng xác minh email. Hãy kiểm tra hộp thư đến.';

  @override
  String get loginErrorRateLimit => 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';

  @override
  String loginErrorGeneric(String message) {
    return 'Đăng nhập thất bại. ($message)';
  }

  @override
  String get loginErrorNetwork =>
      'Không xử lý được yêu cầu. Hãy kiểm tra kết nối mạng và thử lại.';

  @override
  String get loginTitle => 'Đăng nhập';

  @override
  String get loginTagline => 'Học dễ với ví dụ, học đều với nhắc nhở';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Mật khẩu';

  @override
  String get loginSignUpWithEmail => 'Đăng ký bằng email';

  @override
  String get loginContinueWithGoogle => 'Tiếp tục với Google';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navWordbooks => 'Sổ từ';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsTranslationSection => 'Nghĩa · Bản dịch ví dụ';

  @override
  String get settingsTranslationHelp =>
      'Chế độ Tự động sẽ theo ngôn ngữ và khu vực của thiết bị. Bản dịch được dùng cho nghĩa và ví dụ của các từ tra mới. Nghĩa không có bản dịch sẽ hiển thị định nghĩa tiếng Anh, còn bản dịch ví dụ sẽ để trống. Nội dung đã lưu sẽ không tự động thay đổi.';

  @override
  String get settingsAppLanguageNote =>
      'Giao diện ứng dụng cũng hiển thị bằng ngôn ngữ này. Ngôn ngữ chưa được hỗ trợ sẽ hiển thị bằng tiếng Anh.';

  @override
  String get settingsReviewMixSection => 'Tỷ lệ trộn khi ôn';

  @override
  String get settingsReviewMixLabel => 'Trộn lại từ đã thuộc';

  @override
  String settingsReviewMixHelp(int total, int mixed) {
    return 'Trộn từ \'đã thuộc\' vào bài ôn theo tỷ lệ này để củng cố trí nhớ dài hạn. (VD: $mixed trên $total câu)';
  }

  @override
  String get settingsReminderSection => 'Nhắc nhở · Ôn tập';

  @override
  String get settingsReminderToggle => 'Nhận nhắc nhở ôn tập';

  @override
  String get settingsReminderOff => 'Nhắc nhở đang tắt.';

  @override
  String get settingsReminderNoActive => 'Chưa bật khung giờ nhắc nào.';

  @override
  String settingsReminderSummary(int count) {
    return 'Lặp lại hằng tuần · $count lần nhắc mỗi tuần. Các từ đang học được gửi theo thứ tự đến hạn ôn.';
  }

  @override
  String settingsReminderCapped(int limit) {
    return 'Một số nhắc nhở muộn sẽ bị bỏ qua vì vượt quá giới hạn $limit thông báo đã lên lịch của thiết bị.';
  }

  @override
  String get settingsTtsSection => 'Phát âm · TTS';

  @override
  String get settingsTtsDefault => 'Giọng mặc định';

  @override
  String get settingsTtsDefaultHelp => 'Chọn giọng dùng để đọc từ và ví dụ.';

  @override
  String get settingsTtsUs => 'Anh-Mỹ';

  @override
  String get settingsTtsUk => 'Anh-Anh';

  @override
  String get settingsTtsQuality => 'Chất lượng giọng đọc';

  @override
  String get settingsTtsQualityValue => 'TTS của thiết bị (miễn phí)';

  @override
  String get settingsTatoebaCredit => 'Ví dụ bên ngoài: Tatoeba · CC BY 2.0 FR';

  @override
  String get reminderEveryDay => 'Hằng ngày';

  @override
  String get reminderNoWeekdays => 'Chưa chọn ngày';

  @override
  String get reminderWeekdays => 'Ngày thường';

  @override
  String get reminderWeekends => 'Cuối tuần';

  @override
  String reminderIntervalMinutes(int minutes) {
    return 'Mỗi $minutes phút';
  }

  @override
  String reminderIntervalHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Mỗi $hours giờ',
    );
    return '$_temp0';
  }

  @override
  String reminderIntervalHoursMinutes(int hours, int minutes) {
    return 'Mỗi $hours giờ $minutes phút';
  }

  @override
  String get reminderAddSchedule => 'Thêm khung giờ nhắc';

  @override
  String get reminderEditSchedule => 'Sửa khung giờ nhắc';

  @override
  String get reminderStart => 'Bắt đầu';

  @override
  String get reminderEnd => 'Kết thúc';

  @override
  String get reminderCrossesMidnight =>
      'Nếu giờ kết thúc sớm hơn giờ bắt đầu, nhắc nhở sẽ tiếp tục qua nửa đêm đến giờ kết thúc của ngày hôm sau.';

  @override
  String get reminderWeekdaysTitle => 'Ngày nhắc';

  @override
  String get reminderWeekdaysRequired => 'Vui lòng chọn ít nhất một ngày.';

  @override
  String get reminderInterval => 'Khoảng cách nhắc';

  @override
  String get reminderWordsPerAlert => 'Mỗi lần';

  @override
  String get reminderDecreaseWords => 'Giảm số từ';

  @override
  String get reminderIncreaseWords => 'Tăng số từ';

  @override
  String reminderWordCount(int count) {
    return '$count';
  }

  @override
  String reminderWordCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count từ',
    );
    return '$_temp0';
  }

  @override
  String reminderTimesPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lần/ngày',
    );
    return '$_temp0';
  }

  @override
  String reminderPreview(String days, int count, String times) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lần',
    );
    return '$days, $_temp0 · $times';
  }

  @override
  String get translationLanguageLabel => 'Ngôn ngữ dịch';

  @override
  String translationLanguageAuto(String language) {
    return 'Tự động · $language';
  }

  @override
  String get notificationChannelName => 'Thông báo từ vựng';

  @override
  String get notificationChannelDescription =>
      'Hiển thị từ và nghĩa dưới dạng thông báo vào ngày giờ đã chọn';

  @override
  String get notificationTitleDefault => 'Từ vựng hôm nay';

  @override
  String notificationTitleWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count từ của hôm nay',
    );
    return '$_temp0';
  }

  @override
  String get notificationBodyDefault => 'Thêm từ để từ và nghĩa hiện ở đây.';

  @override
  String homeError(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get homeGreeting => 'Sẵn sàng học từ mới chưa?';

  @override
  String get homeTodayStudy => 'Đã học hôm nay';

  @override
  String homeTotalWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tổng $count từ',
    );
    return '$_temp0';
  }

  @override
  String get homeAccuracy => 'Tỷ lệ đúng';

  @override
  String homeCompletedWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã thuộc $count',
    );
    return '$_temp0';
  }

  @override
  String get homeWordOfTheDay => 'Từ của ngày';

  @override
  String get homeQuickStart => 'Bắt đầu nhanh';

  @override
  String get homeQuickGuessWord => 'Điền chỗ trống · gõ';

  @override
  String get homeQuickFillBlank => 'Điền chỗ trống · chọn';

  @override
  String get homeQuickBrowseWordbooks => 'Xem sổ từ';

  @override
  String get homeCreateWordbookFirst => 'Vui lòng tạo sổ từ trước.';

  @override
  String get homeEditWord => 'Sửa từ';

  @override
  String get homeListenWord => 'Nghe phát âm';

  @override
  String get homeSeeDetails => 'Xem chi tiết';

  @override
  String get homeReviewAllDone => 'Đã ôn xong\ntất cả hôm nay!';

  @override
  String homeReviewWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count từ đang\nchờ bạn',
    );
    return '$_temp0';
  }

  @override
  String homeCompletedBadge(int count) {
    return '$count\nđã thuộc';
  }

  @override
  String homeReviewBreakdown(int due, int mixed) {
    return 'Mới/ôn $due · Trộn $mixed';
  }

  @override
  String get homeStart => 'Bắt đầu';

  @override
  String get reviewNoExample => '(Không có ví dụ — hãy nhập từ dựa vào nghĩa)';

  @override
  String get reviewTitle => 'Ôn qua ví dụ';

  @override
  String get reviewEmpty => 'Hôm nay không có thẻ';

  @override
  String get reviewFillBlankTitle => 'Điền vào chỗ trống';

  @override
  String get reviewChoiceInstruction => 'Chọn từ phù hợp với ví dụ và nghĩa';

  @override
  String get reviewInputInstruction => 'Nhập từ phù hợp với ví dụ và nghĩa';

  @override
  String reviewOtherExample(int current, int total) {
    return 'Ví dụ khác  $current/$total';
  }

  @override
  String get reviewDontKnow => 'Không biết';

  @override
  String get reviewInputHint => 'Nhập từ';

  @override
  String reviewHint(String hint) {
    return 'Gợi ý: $hint';
  }

  @override
  String get reviewCheckAnswer => 'Kiểm tra';

  @override
  String get reviewCorrect => 'Chính xác!';

  @override
  String get reviewWrongAnswerIs => 'Chưa đúng. Đáp án là';

  @override
  String reviewSource(String source) {
    return 'Nguồn: $source';
  }

  @override
  String get reviewMixedNotice => 'Từ đã thuộc được trộn lại để ôn';

  @override
  String get reviewSummaryTitle => 'Hoàn thành ôn tập';

  @override
  String get reviewSummaryDone => 'Bạn đã ôn xong';

  @override
  String reviewSummaryScore(int correct, int total) {
    return 'Đúng $correct/$total câu';
  }

  @override
  String get reviewGoHome => 'Về trang chủ';

  @override
  String get dictionaryRateLimited =>
      'Tra từ điển tạm thời bị giới hạn. Vui lòng thử lại sau ít phút.';

  @override
  String get dictionaryConnectionFailed =>
      'Không kết nối được từ điển. Vui lòng thử lại sau ít phút.';

  @override
  String get dictionaryTimeout => 'Từ điển phản hồi quá lâu. Vui lòng thử lại.';

  @override
  String get dictionaryLoadFailed =>
      'Không tải được nghĩa từ điển. Hãy kiểm tra kết nối Internet và thử lại.';

  @override
  String get draftDictionaryUnavailable =>
      'Không kết nối được từ điển. Hãy tự nhập nghĩa hoặc tra lại.';

  @override
  String get draftMeaningNotFound =>
      'Không tìm thấy nghĩa. Hãy tự nhập hoặc tra từ điển.';

  @override
  String draftNoTranslationUsedEnglish(String language) {
    return 'Từ điển không có nghĩa $language nên đã dùng định nghĩa tiếng Anh. Bạn có thể đổi ngôn ngữ dịch trong Cài đặt.';
  }

  @override
  String draftSomeUsedEnglish(String language) {
    return 'Các mục không có nghĩa $language đã được điền bằng định nghĩa tiếng Anh.';
  }

  @override
  String get draftExamplesRetry =>
      'Bạn có thể tải lại ví dụ bằng nút ‘Lấy ví dụ’ bên dưới.';

  @override
  String get speakListen => 'Nghe';

  @override
  String get speakListenExample => 'Nghe ví dụ';

  @override
  String get adPreview => 'Xem trước quảng cáo';

  @override
  String get addWordButton => 'Thêm từ';

  @override
  String get wordCreateExampleTranslations => 'Kèm bản dịch';

  @override
  String get wordCreateNoExampleTranslations => 'Không dịch';

  @override
  String get homeRemainingCards => 'Thẻ còn lại';

  @override
  String homeTodayCards(int count) {
    return 'Hôm nay ôn $count thẻ';
  }

  @override
  String get homeStartButton => 'Bắt đầu';

  @override
  String get homeNoCardsToday => 'Hôm nay không có thẻ';

  @override
  String reviewRemaining(int count) {
    return 'Còn $count';
  }

  @override
  String get reviewKeep => 'Giữ lại';

  @override
  String get reviewDiscard => 'Bỏ đi';

  @override
  String reviewDoneTitle(int count) {
    return 'Xong $count thẻ';
  }

  @override
  String wordbooksCardsLeft(int count) {
    return 'còn lại · tổng $count';
  }

  @override
  String get wordbookCardsLeftSuffix => 'còn lại';

  @override
  String get wordbookDetailAllDiscarded => 'Không còn thẻ';

  @override
  String wordbookDetailDiscarded(String term) {
    return 'Đã bỏ \'$term\'';
  }

  @override
  String get wordbookDetailReleaseToDiscard => 'Thả để bỏ';

  @override
  String get wordbookAddWordShort => 'Từ';

  @override
  String get discardedTitle => 'Thẻ đã bỏ';

  @override
  String get discardedEmpty => 'Chưa bỏ thẻ nào';

  @override
  String get discardedRestore => 'Đưa lại';

  @override
  String get wordAddMeaningSelect => 'Chọn nghĩa';

  @override
  String get wordAddManualInput => 'Tự nhập nghĩa';

  @override
  String get wordAddMeaningLabel => 'Nghĩa';

  @override
  String wordAddExamplesOf(String pos) {
    return 'Ví dụ $pos';
  }

  @override
  String wordAddSelectedCount(int count) {
    return 'Đã chọn $count';
  }

  @override
  String get wordAddWriteExample => 'Tự viết ví dụ';

  @override
  String get wordAddSave => 'Thêm từ';

  @override
  String get wordAddAlreadyInDeck => 'Đã có trong bộ';

  @override
  String get wordAddNoResults => 'Không có trong từ điển';

  @override
  String get wordAddLookupFailed => 'Không kết nối được từ điển';

  @override
  String get wordAddAutoInput => 'Tự điền';

  @override
  String get wordAddAutoOff => 'Tắt tự điền';

  @override
  String get wordAddExampleTranslation => 'Bản dịch';

  @override
  String get wordAddNoExamples =>
      'Không có ví dụ gợi ý. Bạn vẫn có thể thêm từ mà không cần ví dụ.';

  @override
  String get settingsTheme => 'Giao diện';

  @override
  String get themeSlate => 'Đá phiến';

  @override
  String get themeNavy => 'Xanh navy';

  @override
  String get themeBrown => 'Nâu';

  @override
  String get themePlum => 'Mận';

  @override
  String get themeCharcoal => 'Than';

  @override
  String get themeCustom => 'Tùy chỉnh';

  @override
  String get themeCustomTitle => 'Tự chọn giao diện';

  @override
  String get themeBase => 'Nền';

  @override
  String get themePoint => 'Điểm nhấn';

  @override
  String get themeAutoText => 'Màu chữ tự điều chỉnh';

  @override
  String get themeApply => 'Áp dụng';

  @override
  String get themeReset => 'Đặt lại';

  @override
  String get settingsLanguageSection => 'Ngôn ngữ';

  @override
  String get settingsLanguageRow => 'Nghĩa · ví dụ · ứng dụng';

  @override
  String get settingsFollowDevice => 'Theo thiết bị';

  @override
  String get settingsReviewSection => 'Ôn tập';

  @override
  String get settingsSessionSize => 'Số thẻ mỗi lần ôn';

  @override
  String get settingsMixLabel => 'Trộn lại thẻ đã bỏ';

  @override
  String settingsMixExample(int total, int mixed) {
    return '$mixed trên $total';
  }

  @override
  String get settingsWordAddSection => 'Thêm từ';

  @override
  String get settingsNotificationsSection => 'Nhắc nhở';

  @override
  String get settingsReminderMaster => 'Thông báo từ vựng';

  @override
  String get settingsAddSlot => 'Khung giờ nhắc';

  @override
  String settingsWeeklyCount(int count) {
    return '$count lần mỗi tuần';
  }

  @override
  String reminderCardCount(int count) {
    return '$count thẻ';
  }

  @override
  String get settingsPronunciationSection => 'Phát âm';

  @override
  String get settingsAccent => 'Giọng';

  @override
  String get settingsVoice => 'Giọng đọc';

  @override
  String get settingsVoiceDefault => 'Mặc định';

  @override
  String get settingsSpeed => 'Tốc độ';

  @override
  String get settingsSpeedSlow => 'Chậm';

  @override
  String get settingsSpeedNormal => 'Vừa';

  @override
  String get settingsSpeedFast => 'Nhanh';

  @override
  String get settingsRecorded => 'Dùng giọng người thật cho từ';

  @override
  String get settingsRecordedHelp => 'Không có thì dùng giọng đọc';

  @override
  String get settingsAbout => 'Thông tin · nguồn';

  @override
  String get settingsPrivacy => 'Chính sách quyền riêng tư';

  @override
  String get aboutDataSources => 'Nguồn dữ liệu';

  @override
  String get aboutUseMeanings => 'Nghĩa · ví dụ từ điển';

  @override
  String get aboutUseOnline => 'Từ điển trực tuyến';

  @override
  String get aboutUseExamples => 'Ví dụ có bản dịch';

  @override
  String get aboutUseRecordings => 'Bản ghi phát âm từ';

  @override
  String get aboutApp => 'Ứng dụng';

  @override
  String get aboutVersion => 'Phiên bản';

  @override
  String get aboutLicenses => 'Giấy phép mã nguồn mở';

  @override
  String reminderPerDayTotal(int times, int cards) {
    return '$times lần/ngày · $cards thẻ';
  }

  @override
  String settingsPackDownloading(String size) {
    return 'Đang tải bản dịch ví dụ · $size';
  }

  @override
  String settingsPackReady(String size) {
    return 'Đã tải bản dịch ví dụ · $size';
  }

  @override
  String get settingsPackFailed => 'Không tải được bản dịch ví dụ';

  @override
  String get settingsPackRetry => 'Thử lại';

  @override
  String get settingsExampleDataSection => 'Dữ liệu ví dụ';

  @override
  String get settingsExampleData => 'Tải bản dịch ví dụ';

  @override
  String get settingsPackNone => 'Chưa tải';

  @override
  String get settingsPackNotNeeded => 'Tiếng Anh không cần bản dịch';

  @override
  String settingsPackVersion(int version, String size) {
    return 'Đã tải · v$version · $size';
  }

  @override
  String get settingsPackUpdate => 'Kiểm tra cập nhật';

  @override
  String settingsPackUpToDate(int version) {
    return 'Đã là bản mới nhất (v$version)';
  }

  @override
  String settingsPackUpdated(int version) {
    return 'Đã cập nhật lên v$version';
  }

  @override
  String get examplePromptTitle => 'Tải bản dịch ví dụ?';

  @override
  String examplePromptBody(String language, String size) {
    return 'Tải bản dịch $language của các ví dụ tiếng Anh về máy$size. Có thể thay đổi bất cứ lúc nào trong Cài đặt › Dữ liệu ví dụ.';
  }

  @override
  String get examplePromptAccept => 'Tải';

  @override
  String get examplePromptDecline => 'Để sau';

  @override
  String get wordAddPosLabel => 'Từ loại';

  @override
  String get wordAddPosUnknown => 'Không rõ';

  @override
  String get homeQuickGuessFromMeaning => 'Đoán từ qua nghĩa';

  @override
  String get wordFoundExample => 'Ví dụ tìm được';

  @override
  String get wordAddFoundExample => 'Thêm ví dụ';

  @override
  String wordbookFoundExamples(int count) {
    return 'Tìm thấy $count ví dụ';
  }

  @override
  String get wordAddScanExample => 'Lấy ví dụ từ ảnh';

  @override
  String get wordScanCamera => 'Chụp ảnh';

  @override
  String get wordScanGallery => 'Chọn từ thư viện';

  @override
  String get wordScanFailed => 'Không đọc được chữ trong ảnh';

  @override
  String wordScanNoSentence(String term) {
    return 'Không tìm thấy câu có \'$term\' trong ảnh';
  }

  @override
  String get exampleSourcePhoto => 'Ảnh của tôi';

  @override
  String wordScanAdded(int count) {
    return 'Đã thêm $count câu từ ảnh';
  }

  @override
  String homeNewReviewBreakdown(int fresh, int review) {
    return 'Mới $fresh · Ôn $review';
  }

  @override
  String get settingsAnswerStyle => 'Cách trả lời';

  @override
  String get settingsAnswerInput => 'Tự gõ từ';

  @override
  String get settingsAnswerChoice => 'Chọn 1 trong 4';

  @override
  String get settingsAnswerHelp =>
      'Dùng khi ôn bằng nút Bắt đầu ở màn hình chính.';

  @override
  String get sampleWelcomeMeaning => 'chào mừng';

  @override
  String get sampleWelcomeExample1 =>
      'Chào mừng bạn đến với Vocab with Examples!';

  @override
  String get sampleWelcomeExample2 => 'Chào mừng mọi người trở lại.';

  @override
  String get homeAddCardHint =>
      'Nhập từ tiếng Anh để tìm nghĩa và ví dụ, tạo thành thẻ';
}
