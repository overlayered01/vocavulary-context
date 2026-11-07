// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Vocab with Examples';

  @override
  String get commonCancel => 'ยกเลิก';

  @override
  String get commonSave => 'บันทึก';

  @override
  String get commonDelete => 'ลบ';

  @override
  String get commonAdd => 'เพิ่ม';

  @override
  String get commonClose => 'ปิด';

  @override
  String get commonRetry => 'ลองอีกครั้ง';

  @override
  String get commonNext => 'ถัดไป';

  @override
  String get commonEdit => 'แก้ไข';

  @override
  String get commonConfirm => 'ตกลง';

  @override
  String get commonLoading => 'กำลังโหลด';

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ko': 'เกาหลี',
      'ja': 'ญี่ปุ่น',
      'zh': 'จีน',
      'es': 'สเปน',
      'fr': 'ฝรั่งเศส',
      'de': 'เยอรมัน',
      'pt': 'โปรตุเกส',
      'vi': 'เวียดนาม',
      'th': 'ไทย',
      'id': 'อินโดนีเซีย',
      'en': 'อังกฤษ',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'จ.',
      'd2': 'อ.',
      'd3': 'พ.',
      'd4': 'พฤ.',
      'd5': 'ศ.',
      'd6': 'ส.',
      'd7': 'อา.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get wordAddWord => 'เพิ่มคำศัพท์';

  @override
  String get wordEditWord => 'แก้ไขคำศัพท์';

  @override
  String get wordExamples => 'ตัวอย่างประโยค';

  @override
  String wordExampleSource(String source) {
    return 'ที่มา: $source';
  }

  @override
  String wordPartOfSpeech(String pos, String value) {
    String _temp0 = intl.Intl.selectLogic(pos, {
      'noun': 'คำนาม',
      'verb': 'คำกริยา',
      'adjective': 'คำคุณศัพท์',
      'adverb': 'คำกริยาวิเศษณ์',
      'pronoun': 'คำสรรพนาม',
      'preposition': 'คำบุพบท',
      'conjunction': 'คำสันธาน',
      'interjection': 'คำอุทาน',
      'article': 'คำนำหน้านาม',
      'determiner': 'ตัวกำหนด',
      'phrasalVerb': 'กริยาวลี',
      'idiom': 'สำนวน',
      'phrase': 'วลี',
      'other': '$value',
    });
    return '$_temp0';
  }

  @override
  String get wordEditTermRequired => 'กรุณาใส่คำศัพท์ภาษาอังกฤษก่อน';

  @override
  String wordEditNoExamplesFound(String term) {
    return 'ไม่พบตัวอย่างประโยคของ \'$term\'';
  }

  @override
  String get wordEditExamplesAlreadyAdded => 'เพิ่มตัวอย่างที่ค้นพบทั้งหมดแล้ว';

  @override
  String wordEditExamplesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'เพิ่มตัวอย่าง $count ประโยคแล้ว',
    );
    return '$_temp0';
  }

  @override
  String wordEditExamplesFetchFailed(String error) {
    return 'ดึงตัวอย่างประโยคไม่สำเร็จ: $error';
  }

  @override
  String get wordEditTermAndMeaningRequired =>
      'กรุณาใส่คำศัพท์และความหมายอย่างน้อยหนึ่งความหมาย';

  @override
  String get wordEditSaveFailed => 'บันทึกไม่สำเร็จ กรุณาลองอีกครั้ง';

  @override
  String get wordEditSectionTerm => 'คำศัพท์';

  @override
  String get wordEditSectionMeaning => 'ความหมายและการออกเสียง';

  @override
  String get wordEditPhonetic => 'คำอ่าน';

  @override
  String get wordEditSearching => 'กำลังค้นหา';

  @override
  String get wordEditFetchExamples => 'ดึงตัวอย่าง';

  @override
  String get wordEditAddManually => 'เพิ่มเอง';

  @override
  String get wordEditOptional => 'ไม่บังคับ';

  @override
  String wordEditExampleNumber(int index) {
    return 'ตัวอย่าง $index';
  }

  @override
  String get wordEditDeleteExample => 'ลบตัวอย่าง';

  @override
  String get wordEditSentence => 'ประโยคภาษาอังกฤษ';

  @override
  String wordEditTranslationLabel(String language) {
    return 'คำแปล ($language)';
  }

  @override
  String get wordEditTermLabel => 'คำศัพท์ *';

  @override
  String get wordEditTermHint =>
      'เลือกคำที่บันทึกไว้เพื่อเติมความหมายและตัวอย่างโดยอัตโนมัติ';

  @override
  String get wordEditPartOfSpeech => 'ชนิดของคำ';

  @override
  String get wordEditPartOfSpeechNone => 'ไม่ระบุ';

  @override
  String get wordEditManualExampleTitle => 'เพิ่มตัวอย่างเอง';

  @override
  String get wordEditSentenceRequiredLabel => 'ประโยคภาษาอังกฤษ *';

  @override
  String get wordEditSentenceRequired => 'กรุณาใส่ประโยคภาษาอังกฤษ';

  @override
  String wordEditPickerTitle(String term) {
    return 'ตัวอย่างของ \'$term\'';
  }

  @override
  String get wordEditPickerDescription =>
      'เลือกตัวอย่างที่ต้องการเพิ่ม ประโยคที่ยังไม่มีคำแปลสามารถพิมพ์คำแปลเองได้';

  @override
  String wordEditNoTranslation(String language) {
    return 'ไม่มีคำแปลภาษา$language';
  }

  @override
  String get wordEditPickerAttribution => 'ตัวอย่างจาก Tatoeba · CC BY 2.0 FR';

  @override
  String wordEditAddSelectedExamples(int count) {
    return 'เพิ่มที่เลือก ($count)';
  }

  @override
  String get wordCreateLoadFailed => 'โหลดไม่สำเร็จ กรุณาลองอีกครั้ง';

  @override
  String get wordCreateSectionTitle => 'ใส่คำศัพท์';

  @override
  String get wordCreateWordbook => 'สมุดคำศัพท์';

  @override
  String get wordCreateNoWordbook => 'ไม่มีสมุดคำศัพท์';

  @override
  String get wordCreateReload => 'โหลดใหม่';

  @override
  String get wordCreateTermLabel => 'คำศัพท์';

  @override
  String get wordCreateLookingUp => 'กำลังค้นหา';

  @override
  String get wordCreateAutoInputSettings => 'ตั้งค่าเติมอัตโนมัติ';

  @override
  String get wordCreateMeaningsOn => 'ความหมาย เปิด';

  @override
  String get wordCreateMeaningsOff => 'ความหมาย ปิด';

  @override
  String get wordCreateExamplesOn => 'ตัวอย่าง เปิด';

  @override
  String get wordCreateExamplesOff => 'ตัวอย่าง ปิด';

  @override
  String get wordCreateCollapse => 'ย่อ';

  @override
  String get wordCreateExpand => 'ขยาย';

  @override
  String get wordCreateAutoMeanings => 'เติมความหมายอัตโนมัติ';

  @override
  String get wordCreateAutoExamples => 'เติมตัวอย่างอัตโนมัติ';

  @override
  String get wordDetailDictionaryMeaningsAdded =>
      'เพิ่มความหมายจากพจนานุกรมที่เลือกแล้ว';

  @override
  String get wordDetailTitle => 'รายละเอียดคำศัพท์';

  @override
  String get wordDetailFavorite => 'เพิ่มในรายการโปรด';

  @override
  String get wordDetailUnfavorite => 'นำออกจากรายการโปรด';

  @override
  String get wordDetailAccentUs => 'อเมริกัน';

  @override
  String get wordDetailAccentUk => 'บริติช';

  @override
  String get wordDetailMyMeanings => 'ความหมายของฉัน';

  @override
  String get wordDetailListenExample => 'ฟังตัวอย่าง';

  @override
  String get wordDetailGoogleTranslate => 'Google แปลภาษา';

  @override
  String get meaningFieldsLabel => 'ความหมาย';

  @override
  String get meaningFieldsLabelRequired => 'ความหมาย *';

  @override
  String meaningFieldsLabelNumbered(int index) {
    return 'ความหมาย $index';
  }

  @override
  String meaningFieldsRemove(int index) {
    return 'ลบความหมาย $index';
  }

  @override
  String get meaningFieldsAdd => 'เพิ่มความหมาย';

  @override
  String get meaningFieldsEmptyError =>
      'กรุณาใส่ความหมายอย่างน้อยหนึ่งความหมาย';

  @override
  String get meaningFieldsEditTitle => 'แก้ไขความหมาย';

  @override
  String get dictLookupAddFailed => 'เพิ่มความหมายไม่สำเร็จ กรุณาลองอีกครั้ง';

  @override
  String get dictLookupButton => 'ความหมายจากพจนานุกรม';

  @override
  String dictLookupTitle(String term) {
    return '$term · พจนานุกรม';
  }

  @override
  String dictLookupFallbackNotice(String language) {
    return 'รายการที่ไม่มีความหมายภาษา$language จะแสดงคำนิยามภาษาอังกฤษ';
  }

  @override
  String get dictLookupLoadFailed => 'โหลดความหมายจากพจนานุกรมไม่สำเร็จ';

  @override
  String get dictLookupNoResults =>
      'ไม่พบความหมายในพจนานุกรม\nตรวจสอบตัวสะกดหรือลองพจนานุกรมอื่น';

  @override
  String get dictLookupAlreadyAdded => 'เพิ่มแล้ว';

  @override
  String dictLookupAddSelected(int count) {
    return 'เพิ่มที่เลือก ($count)';
  }

  @override
  String get dictLookupLinkFailed => 'เปิดลิงก์พจนานุกรมไม่สำเร็จ';

  @override
  String get dictLinksNaver => 'Naver (En–Ko)';

  @override
  String get dictLinksOxford => 'Oxford (En–En)';

  @override
  String get dictLinksOpenFailed => 'เปิดพจนานุกรมไม่สำเร็จ กรุณาลองอีกครั้ง';

  @override
  String get dictLinksTitle => 'ดูเพิ่มในพจนานุกรม';

  @override
  String wordbookError(String error) {
    return 'ข้อผิดพลาด: $error';
  }

  @override
  String get wordbookShareCode => 'รหัสแชร์';

  @override
  String wordbookDeleteTitle(String name) {
    return 'ลบ \'$name\'';
  }

  @override
  String get wordbooksTitle => 'สมุดคำศัพท์ของฉัน';

  @override
  String get wordbooksNew => 'สมุดคำศัพท์ใหม่';

  @override
  String get wordbooksEmpty => 'ยังไม่มีสมุดคำศัพท์\nแตะ + เพื่อสร้าง';

  @override
  String get wordbooksCreate => 'สร้าง';

  @override
  String get wordbooksNameLabel => 'ชื่อสมุดคำศัพท์';

  @override
  String get wordbooksTagsLabel => 'แท็ก';

  @override
  String get wordbooksTagsHint => 'TOEIC, บทสนทนาประจำวัน (คั่นด้วยจุลภาค)';

  @override
  String wordbooksWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count คำ',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksMenu => 'เมนูสมุดคำศัพท์';

  @override
  String get wordbooksMenuRename => 'แก้ไขชื่อและแท็ก';

  @override
  String get wordbooksShareSettings => 'การแชร์และการมองเห็น';

  @override
  String get wordbooksMenuDelete => 'ลบสมุดคำศัพท์';

  @override
  String get wordbooksEditTitle => 'แก้ไขสมุดคำศัพท์';

  @override
  String get wordbooksShareLoginRequired =>
      'เข้าสู่ระบบเพื่อแชร์หรือเผยแพร่สมุดคำศัพท์';

  @override
  String get wordbooksVisibilityPrivate => 'ส่วนตัว';

  @override
  String get wordbooksVisibilityShared => 'รหัสแชร์';

  @override
  String get wordbooksVisibilityPublic => 'สาธารณะ';

  @override
  String get wordbooksVisibilityPrivateDesc => 'เฉพาะคุณที่เห็นได้';

  @override
  String get wordbooksVisibilitySharedDesc =>
      'ทุกคนที่มีรหัสแชร์สามารถคัดลอกสมุดคำศัพท์นี้ได้';

  @override
  String get wordbooksVisibilityPublicDesc =>
      'แสดงในแท็บสำรวจ ซึ่งทุกคนคัดลอกได้';

  @override
  String get wordbooksCopyCode => 'คัดลอกรหัส';

  @override
  String get wordbooksCodeCopied => 'คัดลอกรหัสแชร์แล้ว';

  @override
  String wordbooksDeleteWithWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'คำศัพท์ $count คำในสมุดนี้จะถูกลบไปด้วย\nสมุดคำศัพท์ที่ลบแล้วจะกู้คืนไม่ได้',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksDeleteEmpty => 'สมุดคำศัพท์ที่ลบแล้วจะกู้คืนไม่ได้';

  @override
  String get wordbookDetailEmpty => 'ยังไม่มีคำศัพท์\nแตะปุ่มเพิ่มคำศัพท์';

  @override
  String wordbookDetailWordDeleted(String term) {
    return 'ลบ \'$term\' แล้ว';
  }

  @override
  String get wordbookDetailUndo => 'เลิกทำ';

  @override
  String get wordbookDetailEditWholeWord => 'แก้ไขทั้งคำ';

  @override
  String get wordbookDetailEditWord => 'แก้ไขคำศัพท์';

  @override
  String get wordbookDetailFavorite => 'รายการโปรด';

  @override
  String get wordbookDetailUnfavorite => 'นำออกจากรายการโปรด';

  @override
  String get wordbookDetailEditMeaning => 'แก้ไขความหมาย';

  @override
  String get wordbookDetailEditAll => 'แก้ไขทั้งหมด';

  @override
  String get wordbookDetailStatusFresh => 'ใหม่';

  @override
  String get wordbookDetailStatusLearning => 'กำลังเรียน';

  @override
  String get wordbookDetailStatusCompleted => 'จำได้แล้ว';

  @override
  String get wordbookDetailDeleteWordConfirm => 'ลบคำศัพท์นี้ไหม';

  @override
  String get wordbookDetailReleaseToDelete => 'ปล่อยเพื่อลบ';

  @override
  String get exploreTitle => 'สำรวจ';

  @override
  String get exploreCodeNotFound => 'ไม่พบสมุดคำศัพท์ที่ตรงกับรหัสนี้';

  @override
  String get exploreImportFailed =>
      'นำเข้าไม่สำเร็จ กรุณาตรวจสอบการเชื่อมต่อเครือข่าย';

  @override
  String exploreCopyTitle(String title) {
    return 'คัดลอก \'$title\'';
  }

  @override
  String exploreCopyConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'คัดลอกคำศัพท์ $count คำไปยังสมุดคำศัพท์ของคุณไหม\nความคืบหน้าการเรียนจะเริ่มใหม่',
    );
    return '$_temp0';
  }

  @override
  String get exploreCopy => 'คัดลอก';

  @override
  String exploreImported(String title) {
    return 'นำเข้า \'$title\' แล้ว';
  }

  @override
  String get exploreLoggedOutHeadline => 'ค้นพบ\nสมุดคำศัพท์ใหม่';

  @override
  String get exploreLoginRequired => 'เข้าสู่ระบบเพื่อสำรวจสมุดคำศัพท์ที่แชร์';

  @override
  String get exploreGoToLogin => 'เข้าสู่ระบบ';

  @override
  String get exploreSupabaseRequired => 'ใช้งานได้หลังเชื่อมต่อ Supabase';

  @override
  String get exploreImportByCode => 'นำเข้าด้วยรหัสแชร์';

  @override
  String get exploreCodeHint => 'วางรหัสที่ได้รับ';

  @override
  String get exploreImport => 'นำเข้า';

  @override
  String get exploreCodeHelp =>
      'หากต้องการแชร์ ให้คัดลอกรหัสจาก การแชร์และการมองเห็น ในเมนูสมุดคำศัพท์';

  @override
  String get explorePublicWordbooks => 'สมุดคำศัพท์สาธารณะ';

  @override
  String get explorePublicLoadFailed =>
      'โหลดสมุดคำศัพท์สาธารณะไม่สำเร็จ\nดึงลงเพื่อรีเฟรช';

  @override
  String get explorePublicEmpty => 'ยังไม่มีสมุดคำศัพท์สาธารณะ';

  @override
  String get loginMigrateTitle => 'นำเข้าสมุดคำศัพท์ในเครื่อง';

  @override
  String loginMigrateConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'คัดลอกสมุดคำศัพท์ $count เล่มที่สร้างในอุปกรณ์นี้ไปยังคลาวด์ไหม\nสมุดที่มีอยู่ในคลาวด์แล้วจะถูกข้าม',
    );
    return '$_temp0';
  }

  @override
  String get loginLater => 'ไว้ทีหลัง';

  @override
  String get loginImport => 'นำเข้า';

  @override
  String loginMigrated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'นำเข้าสมุดคำศัพท์ $count เล่มแล้ว',
    );
    return '$_temp0';
  }

  @override
  String get loginAlreadyInCloud => 'สมุดคำศัพท์ทั้งหมดอยู่ในคลาวด์แล้ว';

  @override
  String get loginErrorInvalidCredentials => 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';

  @override
  String get loginErrorUserExists => 'อีเมลนี้ลงทะเบียนแล้ว กรุณาเข้าสู่ระบบ';

  @override
  String get loginErrorWeakPassword =>
      'รหัสผ่านสั้นเกินไป ใช้อย่างน้อย 6 ตัวอักษร';

  @override
  String get loginErrorEmailNotConfirmed =>
      'กรุณายืนยันอีเมล ตรวจสอบกล่องจดหมายของคุณ';

  @override
  String get loginErrorRateLimit => 'มีคำขอมากเกินไป กรุณาลองใหม่ภายหลัง';

  @override
  String loginErrorGeneric(String message) {
    return 'เข้าสู่ระบบไม่สำเร็จ ($message)';
  }

  @override
  String get loginErrorNetwork =>
      'ดำเนินการคำขอไม่สำเร็จ ตรวจสอบการเชื่อมต่อเครือข่ายแล้วลองอีกครั้ง';

  @override
  String get loginTitle => 'เข้าสู่ระบบ';

  @override
  String get loginTagline => 'เรียนง่ายด้วยตัวอย่าง ต่อเนื่องด้วยการแจ้งเตือน';

  @override
  String get loginEmail => 'อีเมล';

  @override
  String get loginPassword => 'รหัสผ่าน';

  @override
  String get loginSignUpWithEmail => 'สมัครด้วยอีเมล';

  @override
  String get loginContinueWithGoogle => 'ดำเนินการต่อด้วย Google';

  @override
  String get navHome => 'หน้าแรก';

  @override
  String get navWordbooks => 'สมุดคำศัพท์';

  @override
  String get navSettings => 'ตั้งค่า';

  @override
  String get settingsTitle => 'ตั้งค่า';

  @override
  String get settingsTranslationSection => 'ความหมาย · คำแปลตัวอย่าง';

  @override
  String get settingsTranslationHelp =>
      'อัตโนมัติจะใช้ภาษาและภูมิภาคของอุปกรณ์ ภาษาที่เลือกจะใช้กับความหมายและตัวอย่างของคำที่ค้นหาใหม่ ความหมายที่ไม่มีคำแปลจะแสดงคำนิยามภาษาอังกฤษ และคำแปลตัวอย่างจะเว้นว่างไว้ เนื้อหาที่บันทึกไว้แล้วจะไม่เปลี่ยนโดยอัตโนมัติ';

  @override
  String get settingsAppLanguageNote =>
      'แอปจะแสดงเป็นภาษานี้ด้วย ภาษาที่แอปยังไม่รองรับจะแสดงเป็นภาษาอังกฤษ';

  @override
  String get settingsReviewMixSection => 'สัดส่วนการผสมในการทบทวน';

  @override
  String get settingsReviewMixLabel => 'ผสมคำที่จำได้แล้ว';

  @override
  String settingsReviewMixHelp(int total, int mixed) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'ข้อ',
    );
    return 'ผสมคำที่ \'จำได้แล้ว\' ในสัดส่วนนี้เข้าไปในชุดทบทวนเพื่อช่วยความจำระยะยาว (เช่น $mixed จาก $total $_temp0)';
  }

  @override
  String get settingsReminderSection => 'การแจ้งเตือน · ทบทวน';

  @override
  String get settingsReminderToggle => 'รับการแจ้งเตือนทบทวน';

  @override
  String get settingsReminderOff => 'ปิดการแจ้งเตือนอยู่';

  @override
  String get settingsReminderNoActive => 'ไม่มีช่วงเวลาแจ้งเตือนที่เปิดอยู่';

  @override
  String settingsReminderSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ครั้ง',
    );
    return 'ทำซ้ำทุกสัปดาห์ · สัปดาห์ละ $_temp0 คำที่กำลังเรียนจะมาตามลำดับที่ถึงกำหนดทบทวน';
  }

  @override
  String settingsReminderCapped(int limit) {
    return 'การแจ้งเตือนช่วงท้ายบางส่วนถูกตัดออก เพราะเกินขีดจำกัดของอุปกรณ์ที่ $limit รายการ';
  }

  @override
  String get settingsTtsSection => 'การออกเสียง · TTS';

  @override
  String get settingsTtsDefault => 'สำเนียงเริ่มต้น';

  @override
  String get settingsTtsDefaultHelp =>
      'เลือกสำเนียงที่ใช้อ่านคำศัพท์และตัวอย่าง';

  @override
  String get settingsTtsUs => 'อเมริกัน';

  @override
  String get settingsTtsUk => 'บริติช';

  @override
  String get settingsTtsQuality => 'คุณภาพเสียง';

  @override
  String get settingsTtsQualityValue => 'TTS ของอุปกรณ์ (ฟรี)';

  @override
  String get settingsTatoebaCredit => 'ตัวอย่างภายนอก: Tatoeba · CC BY 2.0 FR';

  @override
  String get reminderEveryDay => 'ทุกวัน';

  @override
  String get reminderNoWeekdays => 'ไม่มีวัน';

  @override
  String get reminderWeekdays => 'วันธรรมดา';

  @override
  String get reminderWeekends => 'วันหยุดสุดสัปดาห์';

  @override
  String reminderIntervalMinutes(int minutes) {
    return 'ทุก $minutes นาที';
  }

  @override
  String reminderIntervalHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'ทุก $hours ชั่วโมง',
    );
    return '$_temp0';
  }

  @override
  String reminderIntervalHoursMinutes(int hours, int minutes) {
    return 'ทุก $hours ชม. $minutes นาที';
  }

  @override
  String get reminderAddSchedule => 'เพิ่มช่วงเวลาแจ้งเตือน';

  @override
  String get reminderEditSchedule => 'แก้ไขช่วงเวลาแจ้งเตือน';

  @override
  String get reminderStart => 'เริ่ม';

  @override
  String get reminderEnd => 'สิ้นสุด';

  @override
  String get reminderCrossesMidnight =>
      'หากเวลาสิ้นสุดเร็วกว่าเวลาเริ่ม การแจ้งเตือนจะต่อเนื่องข้ามเที่ยงคืนไปจนถึงเวลาสิ้นสุดของวันถัดไป';

  @override
  String get reminderWeekdaysTitle => 'วันที่แจ้งเตือน';

  @override
  String get reminderWeekdaysRequired => 'เลือกอย่างน้อยหนึ่งวัน';

  @override
  String get reminderInterval => 'ความถี่การแจ้งเตือน';

  @override
  String get reminderWordsPerAlert => 'ต่อครั้ง';

  @override
  String get reminderDecreaseWords => 'ลดจำนวนคำ';

  @override
  String get reminderIncreaseWords => 'เพิ่มจำนวนคำ';

  @override
  String reminderWordCount(int count) {
    return '$count';
  }

  @override
  String reminderWordCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count คำ',
    );
    return '$_temp0';
  }

  @override
  String reminderTimesPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'วันละ $count ครั้ง',
    );
    return '$_temp0';
  }

  @override
  String reminderPreview(String days, int count, String times) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ครั้ง',
    );
    return '$days, $_temp0 · $times';
  }

  @override
  String get translationLanguageLabel => 'ภาษาคำแปล';

  @override
  String translationLanguageAuto(String language) {
    return 'อัตโนมัติ · $language';
  }

  @override
  String get notificationChannelName => 'แจ้งเตือนคำศัพท์';

  @override
  String get notificationChannelDescription =>
      'แสดงคำศัพท์และความหมายเป็นการแจ้งเตือนตามวันและเวลาที่ตั้งไว้';

  @override
  String get notificationTitleDefault => 'คำศัพท์วันนี้';

  @override
  String notificationTitleWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'คำศัพท์วันนี้ $count คำ',
    );
    return '$_temp0';
  }

  @override
  String get notificationBodyDefault =>
      'เพิ่มคำศัพท์แล้วคำและความหมายจะแสดงที่นี่';

  @override
  String homeError(String error) {
    return 'ข้อผิดพลาด: $error';
  }

  @override
  String get homeGreeting => 'พร้อมเรียนคำศัพท์หรือยัง';

  @override
  String get homeTodayStudy => 'เรียนวันนี้';

  @override
  String homeTotalWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ทั้งหมด $count คำ',
    );
    return '$_temp0';
  }

  @override
  String get homeAccuracy => 'ความแม่นยำ';

  @override
  String homeCompletedWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'จำได้แล้ว $count คำ',
    );
    return '$_temp0';
  }

  @override
  String get homeWordOfTheDay => 'คำศัพท์ประจำวัน';

  @override
  String get homeQuickStart => 'เริ่มด่วน';

  @override
  String get homeQuickGuessWord => 'เติมคำ · พิมพ์';

  @override
  String get homeQuickFillBlank => 'เติมคำ · เลือก';

  @override
  String get homeQuickBrowseWordbooks => 'ดูสมุดคำศัพท์';

  @override
  String get homeCreateWordbookFirst => 'สร้างสมุดคำศัพท์ก่อน';

  @override
  String get homeEditWord => 'แก้ไขคำศัพท์';

  @override
  String get homeListenWord => 'ฟังคำศัพท์';

  @override
  String get homeSeeDetails => 'ดูรายละเอียด';

  @override
  String get homeReviewAllDone => 'ทบทวนวันนี้\nครบแล้ว!';

  @override
  String homeReviewWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'มี $count คำ\nรอคุณอยู่',
    );
    return '$_temp0';
  }

  @override
  String homeCompletedBadge(int count) {
    return '$count\nจำได้';
  }

  @override
  String homeReviewBreakdown(int due, int mixed) {
    return 'ใหม่/ทบทวน $due · ผสม $mixed';
  }

  @override
  String get homeStart => 'เริ่ม';

  @override
  String get reviewNoExample => '(ไม่มีตัวอย่าง — พิมพ์คำจากความหมาย)';

  @override
  String get reviewTitle => 'ทบทวนจากตัวอย่าง';

  @override
  String get reviewEmpty => 'วันนี้ไม่มีการ์ด';

  @override
  String get reviewFillBlankTitle => 'เติมคำในช่องว่าง';

  @override
  String get reviewChoiceInstruction => 'เลือกคำที่ตรงกับตัวอย่างและความหมาย';

  @override
  String get reviewInputInstruction => 'พิมพ์คำที่ตรงกับตัวอย่างและความหมาย';

  @override
  String reviewOtherExample(int current, int total) {
    return 'ตัวอย่างอื่น  $current/$total';
  }

  @override
  String get reviewDontKnow => 'ไม่รู้';

  @override
  String get reviewInputHint => 'พิมพ์คำศัพท์';

  @override
  String reviewHint(String hint) {
    return 'คำใบ้: $hint';
  }

  @override
  String get reviewCheckAnswer => 'ตรวจคำตอบ';

  @override
  String get reviewCorrect => 'ถูกต้อง!';

  @override
  String get reviewWrongAnswerIs => 'ยังไม่ถูก คำตอบคือ';

  @override
  String reviewSource(String source) {
    return 'ที่มา: $source';
  }

  @override
  String get reviewMixedNotice => 'คำที่จำได้แล้วถูกผสมมาให้ทบทวน';

  @override
  String get reviewSummaryTitle => 'ทบทวนเสร็จแล้ว';

  @override
  String get reviewSummaryDone => 'คุณทบทวนครบแล้ว';

  @override
  String reviewSummaryScore(int correct, int total) {
    return 'ถูก $correct จาก $total ข้อ';
  }

  @override
  String get reviewGoHome => 'กลับหน้าแรก';

  @override
  String get dictionaryRateLimited =>
      'การค้นพจนานุกรมถูกจำกัดชั่วคราว กรุณาลองใหม่ในอีกสักครู่';

  @override
  String get dictionaryConnectionFailed =>
      'เชื่อมต่อพจนานุกรมไม่ได้ กรุณาลองใหม่ในอีกสักครู่';

  @override
  String get dictionaryTimeout => 'พจนานุกรมตอบสนองช้าเกินไป กรุณาลองอีกครั้ง';

  @override
  String get dictionaryLoadFailed =>
      'โหลดความหมายจากพจนานุกรมไม่สำเร็จ ตรวจสอบการเชื่อมต่ออินเทอร์เน็ตแล้วลองอีกครั้ง';

  @override
  String get draftDictionaryUnavailable =>
      'เชื่อมต่อพจนานุกรมไม่ได้ ใส่ความหมายเองหรือค้นหาอีกครั้ง';

  @override
  String get draftMeaningNotFound => 'ไม่พบความหมาย ใส่เองหรือค้นหาในพจนานุกรม';

  @override
  String draftNoTranslationUsedEnglish(String language) {
    return 'พจนานุกรมไม่มีความหมายภาษา$language จึงใช้คำนิยามภาษาอังกฤษแทน เปลี่ยนภาษาคำแปลได้ในการตั้งค่า';
  }

  @override
  String draftSomeUsedEnglish(String language) {
    return 'รายการที่ไม่มีความหมายภาษา$language ถูกเติมด้วยคำนิยามภาษาอังกฤษ';
  }

  @override
  String get draftExamplesRetry =>
      'โหลดตัวอย่างอีกครั้งได้ด้วยปุ่ม ‘ดึงตัวอย่าง’ ด้านล่าง';

  @override
  String get speakListen => 'ฟัง';

  @override
  String get speakListenExample => 'ฟังตัวอย่าง';

  @override
  String get adPreview => 'ตัวอย่างโฆษณา';

  @override
  String get addWordButton => 'เพิ่มคำศัพท์';

  @override
  String get wordCreateExampleTranslations => 'รวมคำแปลประโยค';

  @override
  String get wordCreateNoExampleTranslations => 'ไม่มีคำแปล';

  @override
  String get homeRemainingCards => 'การ์ดที่เหลือ';

  @override
  String homeTodayCards(int count) {
    return 'ทบทวนวันนี้ $count ใบ';
  }

  @override
  String get homeStartButton => 'เริ่ม';

  @override
  String get homeNoCardsToday => 'วันนี้ไม่มีการ์ด';

  @override
  String reviewRemaining(int count) {
    return 'เหลือ $count';
  }

  @override
  String get reviewKeep => 'เก็บไว้';

  @override
  String get reviewDiscard => 'ทิ้ง';

  @override
  String reviewDoneTitle(int count) {
    return 'เสร็จ $count ใบ';
  }

  @override
  String wordbooksCardsLeft(int count) {
    return 'ใบที่เหลือ · ทั้งหมด $count';
  }

  @override
  String get wordbookCardsLeftSuffix => 'ใบที่เหลือ';

  @override
  String get wordbookDetailAllDiscarded => 'ไม่มีการ์ดเหลือ';

  @override
  String wordbookDetailDiscarded(String term) {
    return 'ทิ้ง \'$term\' แล้ว';
  }

  @override
  String get wordbookDetailReleaseToDiscard => 'ปล่อยเพื่อทิ้ง';

  @override
  String get wordbookAddWordShort => 'คำ';

  @override
  String get discardedTitle => 'การ์ดที่ทิ้ง';

  @override
  String get discardedEmpty => 'ยังไม่มีการ์ดที่ทิ้ง';

  @override
  String get discardedRestore => 'ใส่คืน';

  @override
  String get wordAddMeaningSelect => 'เลือกความหมาย';

  @override
  String get wordAddManualInput => 'พิมพ์ความหมายเอง';

  @override
  String get wordAddMeaningLabel => 'ความหมาย';

  @override
  String wordAddExamplesOf(String pos) {
    return 'ตัวอย่าง $pos';
  }

  @override
  String wordAddSelectedCount(int count) {
    return 'เลือก $count';
  }

  @override
  String get wordAddWriteExample => 'เขียนตัวอย่างเอง';

  @override
  String get wordAddSave => 'เพิ่มคำ';

  @override
  String get wordAddAlreadyInDeck => 'มีในสำรับแล้ว';

  @override
  String get wordAddNoResults => 'ไม่มีในพจนานุกรม';

  @override
  String get wordAddLookupFailed => 'เชื่อมต่อพจนานุกรมไม่ได้';

  @override
  String get wordAddAutoInput => 'กรอกอัตโนมัติ';

  @override
  String get wordAddAutoOff => 'ปิดการกรอกอัตโนมัติ';

  @override
  String get wordAddExampleTranslation => 'คำแปล';

  @override
  String get wordAddNoExamples =>
      'ไม่มีตัวอย่างให้เลือก เพิ่มคำโดยไม่มีตัวอย่างได้';

  @override
  String get settingsTheme => 'ธีม';

  @override
  String get themeSlate => 'สเลท';

  @override
  String get themeNavy => 'กรมท่า';

  @override
  String get themeBrown => 'น้ำตาล';

  @override
  String get themePlum => 'พลัม';

  @override
  String get themeCharcoal => 'ถ่าน';

  @override
  String get themeCustom => 'กำหนดเอง';

  @override
  String get themeCustomTitle => 'ธีมกำหนดเอง';

  @override
  String get themeBase => 'พื้น';

  @override
  String get themePoint => 'สีเน้น';

  @override
  String get themeAutoText => 'สีตัวอักษรปรับอัตโนมัติ';

  @override
  String get themeApply => 'ใช้';

  @override
  String get themeReset => 'รีเซ็ต';

  @override
  String get settingsLanguageSection => 'ภาษา';

  @override
  String get settingsLanguageRow => 'ความหมาย · ตัวอย่าง · แอป';

  @override
  String get settingsFollowDevice => 'ตามอุปกรณ์';

  @override
  String get settingsReviewSection => 'ทบทวน';

  @override
  String get settingsSessionSize => 'จำนวนการ์ดต่อการทบทวน';

  @override
  String get settingsMixLabel => 'ผสมการ์ดที่ทิ้งกลับมา';

  @override
  String settingsMixExample(int total, int mixed) {
    return '$mixed จาก $total';
  }

  @override
  String get settingsWordAddSection => 'การเพิ่มคำ';

  @override
  String get settingsNotificationsSection => 'การแจ้งเตือน';

  @override
  String get settingsReminderMaster => 'แจ้งเตือนคำศัพท์';

  @override
  String get settingsAddSlot => 'ช่วงเวลาแจ้งเตือน';

  @override
  String settingsWeeklyCount(int count) {
    return 'สัปดาห์ละ $count ครั้ง';
  }

  @override
  String reminderCardCount(int count) {
    return '$count ใบ';
  }

  @override
  String get settingsPronunciationSection => 'การออกเสียง';

  @override
  String get settingsAccent => 'สำเนียง';

  @override
  String get settingsVoice => 'เสียง';

  @override
  String get settingsVoiceDefault => 'ค่าเริ่มต้น';

  @override
  String get settingsSpeed => 'ความเร็ว';

  @override
  String get settingsSpeedSlow => 'ช้า';

  @override
  String get settingsSpeedNormal => 'ปกติ';

  @override
  String get settingsSpeedFast => 'เร็ว';

  @override
  String get settingsRecorded => 'ใช้เสียงคนจริงสำหรับคำ';

  @override
  String get settingsRecordedHelp => 'ถ้าไม่มีจะใช้เสียงอ่าน';

  @override
  String get settingsAbout => 'ข้อมูล · แหล่งที่มา';

  @override
  String get settingsPrivacy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get aboutDataSources => 'แหล่งข้อมูล';

  @override
  String get aboutUseMeanings => 'ความหมาย · ตัวอย่างจากพจนานุกรม';

  @override
  String get aboutUseOnline => 'พจนานุกรมออนไลน์';

  @override
  String get aboutUseExamples => 'ตัวอย่างพร้อมคำแปล';

  @override
  String get aboutUseRecordings => 'เสียงอ่านคำ';

  @override
  String get aboutApp => 'แอป';

  @override
  String get aboutVersion => 'เวอร์ชัน';

  @override
  String get aboutLicenses => 'สัญญาอนุญาตโอเพนซอร์ส';

  @override
  String reminderPerDayTotal(int times, int cards) {
    return 'วันละ $times ครั้ง · $cards ใบ';
  }

  @override
  String settingsPackDownloading(String size) {
    return 'กำลังดาวน์โหลดคำแปลตัวอย่าง · $size';
  }

  @override
  String settingsPackReady(String size) {
    return 'ดาวน์โหลดคำแปลตัวอย่างแล้ว · $size';
  }

  @override
  String get settingsPackFailed => 'ดาวน์โหลดคำแปลตัวอย่างไม่สำเร็จ';

  @override
  String get settingsPackRetry => 'ลองอีกครั้ง';

  @override
  String get settingsExampleDataSection => 'ข้อมูลตัวอย่างประโยค';

  @override
  String get settingsExampleData => 'ดาวน์โหลดคำแปลตัวอย่าง';

  @override
  String get settingsPackNone => 'ยังไม่ได้ดาวน์โหลด';

  @override
  String get settingsPackNotNeeded => 'ภาษาอังกฤษไม่ต้องมีคำแปล';

  @override
  String settingsPackVersion(int version, String size) {
    return 'ดาวน์โหลดแล้ว · v$version · $size';
  }

  @override
  String get settingsPackUpdate => 'ตรวจสอบอัปเดต';

  @override
  String settingsPackUpToDate(int version) {
    return 'เป็นเวอร์ชันล่าสุด (v$version)';
  }

  @override
  String settingsPackUpdated(int version) {
    return 'อัปเดตเป็น v$version แล้ว';
  }

  @override
  String get examplePromptTitle => 'ดาวน์โหลดคำแปลตัวอย่างไหม?';

  @override
  String examplePromptBody(String language, String size) {
    return 'ดาวน์โหลดคำแปลภาษา$languageของตัวอย่างภาษาอังกฤษไว้ในเครื่อง$size เปลี่ยนได้ทุกเมื่อในการตั้งค่า › ข้อมูลตัวอย่างประโยค';
  }

  @override
  String get examplePromptAccept => 'ดาวน์โหลด';

  @override
  String get examplePromptDecline => 'ไม่ใช่ตอนนี้';

  @override
  String get wordAddPosLabel => 'ชนิดของคำ';

  @override
  String get wordAddPosUnknown => 'ไม่ทราบ';

  @override
  String get homeQuickGuessFromMeaning => 'ทายคำจากความหมาย';

  @override
  String get wordFoundExample => 'ตัวอย่างที่พบ';

  @override
  String get wordAddFoundExample => 'เพิ่มตัวอย่าง';

  @override
  String wordbookFoundExamples(int count) {
    return 'พบตัวอย่าง $count ประโยค';
  }

  @override
  String get wordAddScanExample => 'ดึงตัวอย่างจากรูปภาพ';

  @override
  String get wordScanCamera => 'ถ่ายรูป';

  @override
  String get wordScanGallery => 'เลือกจากอัลบั้ม';

  @override
  String get wordScanFailed => 'อ่านข้อความในรูปไม่ได้';

  @override
  String wordScanNoSentence(String term) {
    return 'ไม่พบประโยคที่มี \'$term\' ในรูป';
  }

  @override
  String get exampleSourcePhoto => 'รูปของฉัน';

  @override
  String wordScanAdded(int count) {
    return 'เพิ่ม $count ประโยคจากรูปแล้ว';
  }

  @override
  String homeNewReviewBreakdown(int fresh, int review) {
    return 'ใหม่ $fresh · ทบทวน $review';
  }

  @override
  String get settingsAnswerStyle => 'รูปแบบคำตอบ';

  @override
  String get settingsAnswerInput => 'พิมพ์คำเอง';

  @override
  String get settingsAnswerChoice => 'เลือกจาก 4 ตัวเลือก';

  @override
  String get settingsAnswerHelp => 'ใช้เมื่อทบทวนด้วยปุ่มเริ่มที่หน้าหลัก';

  @override
  String get sampleWelcomeMeaning => 'ยินดีต้อนรับ';

  @override
  String get sampleWelcomeExample1 => 'ยินดีต้อนรับสู่ Vocab with Examples!';

  @override
  String get sampleWelcomeExample2 => 'ยินดีต้อนรับกลับมาทุกคน';

  @override
  String get homeAddCardHint =>
      'พิมพ์คำภาษาอังกฤษ แล้วเราจะหาความหมายและตัวอย่างมาทำเป็นการ์ด';
}
