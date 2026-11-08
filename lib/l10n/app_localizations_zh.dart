// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'WordPing';

  @override
  String get commonCancel => '取消';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonAdd => '添加';

  @override
  String get commonClose => '关闭';

  @override
  String get commonRetry => '重试';

  @override
  String get commonNext => '下一步';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonConfirm => '确定';

  @override
  String get commonLoading => '加载中';

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ko': '韩语',
      'ja': '日语',
      'zh': '中文',
      'es': '西班牙语',
      'fr': '法语',
      'de': '德语',
      'pt': '葡萄牙语',
      'vi': '越南语',
      'th': '泰语',
      'id': '印尼语',
      'en': '英语',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': '周一',
      'd2': '周二',
      'd3': '周三',
      'd4': '周四',
      'd5': '周五',
      'd6': '周六',
      'd7': '周日',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get wordAddWord => '添加单词';

  @override
  String get wordEditWord => '编辑单词';

  @override
  String get wordExamples => '例句';

  @override
  String wordExampleSource(String source) {
    return '来源：$source';
  }

  @override
  String wordPartOfSpeech(String pos, String value) {
    String _temp0 = intl.Intl.selectLogic(pos, {
      'noun': '名词',
      'verb': '动词',
      'adjective': '形容词',
      'adverb': '副词',
      'pronoun': '代词',
      'preposition': '介词',
      'conjunction': '连词',
      'interjection': '感叹词',
      'article': '冠词',
      'determiner': '限定词',
      'phrasalVerb': '短语动词',
      'idiom': '习语',
      'phrase': '短语',
      'other': '$value',
    });
    return '$_temp0';
  }

  @override
  String get wordEditTermRequired => '请先输入英文单词。';

  @override
  String wordEditNoExamplesFound(String term) {
    return '未找到“$term”的例句。';
  }

  @override
  String get wordEditExamplesAlreadyAdded => '获取的例句均已添加。';

  @override
  String wordEditExamplesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已添加 $count 个例句。',
    );
    return '$_temp0';
  }

  @override
  String wordEditExamplesFetchFailed(String error) {
    return '无法获取例句：$error';
  }

  @override
  String get wordEditTermAndMeaningRequired => '请输入单词和至少一个释义。';

  @override
  String get wordEditSaveFailed => '保存失败，请重试。';

  @override
  String get wordEditSectionTerm => '单词';

  @override
  String get wordEditSectionMeaning => '释义与发音';

  @override
  String get wordEditPhonetic => '音标';

  @override
  String get wordEditSearching => '搜索中';

  @override
  String get wordEditFetchExamples => '获取例句';

  @override
  String get wordEditAddManually => '手动添加';

  @override
  String get wordEditOptional => '可选';

  @override
  String wordEditExampleNumber(int index) {
    return '例句 $index';
  }

  @override
  String get wordEditDeleteExample => '删除例句';

  @override
  String get wordEditSentence => '英文句子';

  @override
  String wordEditTranslationLabel(String language) {
    return '译文（$language）';
  }

  @override
  String get wordEditTermLabel => '单词 *';

  @override
  String get wordEditTermHint => '选择已保存的单词，将自动填入释义和例句。';

  @override
  String get wordEditPartOfSpeech => '词性';

  @override
  String get wordEditPartOfSpeechNone => '无';

  @override
  String get wordEditManualExampleTitle => '手动添加例句';

  @override
  String get wordEditSentenceRequiredLabel => '英文句子 *';

  @override
  String get wordEditSentenceRequired => '请输入英文句子。';

  @override
  String wordEditPickerTitle(String term) {
    return '“$term”的例句';
  }

  @override
  String get wordEditPickerDescription => '请选择要添加的例句。没有译文的句子可以自行输入。';

  @override
  String wordEditNoTranslation(String language) {
    return '无$language译文';
  }

  @override
  String get wordEditPickerAttribution => '例句来源：Tatoeba · CC BY 2.0 FR';

  @override
  String wordEditAddSelectedExamples(int count) {
    return '添加所选（$count）';
  }

  @override
  String get wordCreateLoadFailed => '加载失败，请重试。';

  @override
  String get wordCreateSectionTitle => '输入单词';

  @override
  String get wordCreateWordbook => '单词本';

  @override
  String get wordCreateNoWordbook => '暂无单词本';

  @override
  String get wordCreateReload => '重新加载';

  @override
  String get wordCreateTermLabel => '单词';

  @override
  String get wordCreateLookingUp => '查询中';

  @override
  String get wordCreateAutoInputSettings => '自动填写设置';

  @override
  String get wordCreateMeaningsOn => '释义：开';

  @override
  String get wordCreateMeaningsOff => '释义：关';

  @override
  String get wordCreateExamplesOn => '例句：开';

  @override
  String get wordCreateExamplesOff => '例句：关';

  @override
  String get wordCreateCollapse => '收起';

  @override
  String get wordCreateExpand => '展开';

  @override
  String get wordCreateAutoMeanings => '自动填写释义';

  @override
  String get wordCreateAutoExamples => '自动填写例句';

  @override
  String get wordDetailDictionaryMeaningsAdded => '已添加所选词典释义。';

  @override
  String get wordDetailTitle => '单词详情';

  @override
  String get wordDetailFavorite => '加入收藏';

  @override
  String get wordDetailUnfavorite => '取消收藏';

  @override
  String get wordDetailAccentUs => '美式';

  @override
  String get wordDetailAccentUk => '英式';

  @override
  String get wordDetailMyMeanings => '我的释义';

  @override
  String get wordDetailListenExample => '听例句';

  @override
  String get wordDetailGoogleTranslate => 'Google 翻译';

  @override
  String get meaningFieldsLabel => '释义';

  @override
  String get meaningFieldsLabelRequired => '释义 *';

  @override
  String meaningFieldsLabelNumbered(int index) {
    return '释义 $index';
  }

  @override
  String meaningFieldsRemove(int index) {
    return '删除释义 $index';
  }

  @override
  String get meaningFieldsAdd => '添加释义';

  @override
  String get meaningFieldsEmptyError => '请至少输入一个释义。';

  @override
  String get meaningFieldsEditTitle => '编辑释义';

  @override
  String get dictLookupAddFailed => '无法添加释义，请重试。';

  @override
  String get dictLookupButton => '词典释义';

  @override
  String dictLookupTitle(String term) {
    return '$term · 词典';
  }

  @override
  String dictLookupFallbackNotice(String language) {
    return '没有$language释义的条目将显示英文释义。';
  }

  @override
  String get dictLookupLoadFailed => '无法加载词典释义。';

  @override
  String get dictLookupNoResults => '未找到词典释义。\n请检查拼写或换个词典查询。';

  @override
  String get dictLookupAlreadyAdded => '已添加';

  @override
  String dictLookupAddSelected(int count) {
    return '添加所选（$count）';
  }

  @override
  String get dictLookupLinkFailed => '无法打开词典链接。';

  @override
  String get dictLinksNaver => 'Naver（英韩）';

  @override
  String get dictLinksOxford => 'Oxford（英英）';

  @override
  String get dictLinksOpenFailed => '无法打开词典，请重试。';

  @override
  String get dictLinksTitle => '在词典中查看更多';

  @override
  String wordbookError(String error) {
    return '错误：$error';
  }

  @override
  String get wordbookShareCode => '分享码';

  @override
  String wordbookDeleteTitle(String name) {
    return '删除“$name”';
  }

  @override
  String get wordbooksTitle => '我的单词本';

  @override
  String get wordbooksNew => '新建单词本';

  @override
  String get wordbooksEmpty => '还没有单词本。\n点击 + 添加一个吧。';

  @override
  String get wordbooksCreate => '创建';

  @override
  String get wordbooksNameLabel => '单词本名称';

  @override
  String get wordbooksTagsLabel => '标签';

  @override
  String get wordbooksTagsHint => '托业, 日常会话（用逗号分隔）';

  @override
  String wordbooksWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个单词',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksMenu => '单词本菜单';

  @override
  String get wordbooksMenuRename => '编辑名称和标签';

  @override
  String get wordbooksShareSettings => '分享与公开设置';

  @override
  String get wordbooksMenuDelete => '删除单词本';

  @override
  String get wordbooksEditTitle => '编辑单词本';

  @override
  String get wordbooksShareLoginRequired => '登录后即可分享或公开单词本。';

  @override
  String get wordbooksVisibilityPrivate => '私密';

  @override
  String get wordbooksVisibilityShared => '分享码';

  @override
  String get wordbooksVisibilityPublic => '公开';

  @override
  String get wordbooksVisibilityPrivateDesc => '仅自己可见。';

  @override
  String get wordbooksVisibilitySharedDesc => '知道分享码的人可以复制此单词本。';

  @override
  String get wordbooksVisibilityPublicDesc => '将显示在“发现”页中，任何人都可以复制。';

  @override
  String get wordbooksCopyCode => '复制分享码';

  @override
  String get wordbooksCodeCopied => '已复制分享码。';

  @override
  String wordbooksDeleteWithWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '单词本中的 $count 个单词也将一并删除。\n删除后无法恢复。',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksDeleteEmpty => '单词本删除后无法恢复。';

  @override
  String get wordbookDetailEmpty => '还没有单词。\n点击“添加单词”按钮试试吧。';

  @override
  String wordbookDetailWordDeleted(String term) {
    return '已删除“$term”';
  }

  @override
  String get wordbookDetailUndo => '撤销';

  @override
  String get wordbookDetailEditWholeWord => '编辑整个单词';

  @override
  String get wordbookDetailEditWord => '编辑单词';

  @override
  String get wordbookDetailFavorite => '收藏';

  @override
  String get wordbookDetailUnfavorite => '取消收藏';

  @override
  String get wordbookDetailEditMeaning => '编辑释义';

  @override
  String get wordbookDetailEditAll => '全部编辑';

  @override
  String get wordbookDetailStatusFresh => '未学';

  @override
  String get wordbookDetailStatusLearning => '学习中';

  @override
  String get wordbookDetailStatusCompleted => '已掌握';

  @override
  String get wordbookDetailDeleteWordConfirm => '要删除这个单词吗？';

  @override
  String get wordbookDetailReleaseToDelete => '松开即删除';

  @override
  String get exploreTitle => '发现';

  @override
  String get exploreCodeNotFound => '找不到与此分享码对应的单词本。';

  @override
  String get exploreImportFailed => '导入失败，请检查网络连接。';

  @override
  String exploreCopyTitle(String title) {
    return '复制“$title”';
  }

  @override
  String exploreCopyConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '要将 $count 个单词复制到你的单词本吗？\n学习进度将从头开始。',
    );
    return '$_temp0';
  }

  @override
  String get exploreCopy => '复制';

  @override
  String exploreImported(String title) {
    return '已导入“$title”。';
  }

  @override
  String get exploreLoggedOutHeadline => '发现新的\n单词本';

  @override
  String get exploreLoginRequired => '登录后即可浏览共享单词本。';

  @override
  String get exploreGoToLogin => '去登录';

  @override
  String get exploreSupabaseRequired => '连接 Supabase 后即可使用。';

  @override
  String get exploreImportByCode => '通过分享码导入';

  @override
  String get exploreCodeHint => '粘贴收到的分享码';

  @override
  String get exploreImport => '导入';

  @override
  String get exploreCodeHelp => '在单词本菜单的“分享与公开设置”中复制分享码，即可分享给他人。';

  @override
  String get explorePublicWordbooks => '公开单词本';

  @override
  String get explorePublicLoadFailed => '无法加载公开单词本。\n下拉即可刷新。';

  @override
  String get explorePublicEmpty => '暂无公开的单词本。';

  @override
  String get loginMigrateTitle => '导入本地单词本';

  @override
  String loginMigrateConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '要将在此设备上创建的 $count 个单词本复制到云端吗？\n云端已有的单词本将被跳过。',
    );
    return '$_temp0';
  }

  @override
  String get loginLater => '稍后';

  @override
  String get loginImport => '导入';

  @override
  String loginMigrated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已导入 $count 个单词本。',
    );
    return '$_temp0';
  }

  @override
  String get loginAlreadyInCloud => '所有单词本均已在云端。';

  @override
  String get loginErrorInvalidCredentials => '邮箱或密码不正确。';

  @override
  String get loginErrorUserExists => '该邮箱已注册，请直接登录。';

  @override
  String get loginErrorWeakPassword => '密码太短，请至少输入 6 个字符。';

  @override
  String get loginErrorEmailNotConfirmed => '请先验证邮箱，请查看收件箱。';

  @override
  String get loginErrorRateLimit => '请求过于频繁，请稍后再试。';

  @override
  String loginErrorGeneric(String message) {
    return '登录失败。（$message）';
  }

  @override
  String get loginErrorNetwork => '无法处理请求。请检查网络连接后重试。';

  @override
  String get loginTitle => '登录';

  @override
  String get loginTagline => '用例句轻松记，用提醒坚持学';

  @override
  String get loginEmail => '邮箱';

  @override
  String get loginPassword => '密码';

  @override
  String get loginSignUpWithEmail => '使用邮箱注册';

  @override
  String get loginContinueWithGoogle => '使用 Google 继续';

  @override
  String get navHome => '首页';

  @override
  String get navWordbooks => '单词本';

  @override
  String get navSettings => '设置';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsTranslationSection => '释义 · 例句翻译';

  @override
  String get settingsTranslationHelp =>
      '“自动”会根据设备的语言和地区确定。翻译用于新查询单词的释义和例句。没有翻译的释义将显示英文释义，例句译文则留空。已保存的内容不会自动更改。';

  @override
  String get settingsAppLanguageNote => '应用界面也将以此语言显示。暂不支持的语言将以英文显示。';

  @override
  String get settingsReviewMixSection => '复习混入比例';

  @override
  String get settingsReviewMixLabel => '混入已掌握的单词';

  @override
  String settingsReviewMixHelp(int total, int mixed) {
    return '按此比例在复习中混入“已掌握”的单词，以巩固长期记忆。（例如：$total 题中混入 $mixed 题）';
  }

  @override
  String get settingsReminderSection => '提醒 · 复习';

  @override
  String get settingsReminderToggle => '接收复习提醒';

  @override
  String get settingsReminderOff => '提醒已关闭。';

  @override
  String get settingsReminderNoActive => '没有已开启的提醒时段。';

  @override
  String settingsReminderSummary(int count) {
    return '每周重复 · 每周提醒 $count 次。学习中的单词将按复习顺序推送。';
  }

  @override
  String settingsReminderCapped(int limit) {
    return '由于超出设备的定时通知上限（$limit 条），部分较晚的提醒将不会发送。';
  }

  @override
  String get settingsTtsSection => '发音 · TTS';

  @override
  String get settingsTtsDefault => '默认口音';

  @override
  String get settingsTtsDefaultHelp => '选择朗读单词和例句时使用的口音。';

  @override
  String get settingsTtsUs => '美式';

  @override
  String get settingsTtsUk => '英式';

  @override
  String get settingsTtsQuality => '语音质量';

  @override
  String get settingsTtsQualityValue => '设备 TTS（免费）';

  @override
  String get settingsTatoebaCredit => '外部例句：Tatoeba · CC BY 2.0 FR';

  @override
  String get reminderEveryDay => '每天';

  @override
  String get reminderNoWeekdays => '未选择';

  @override
  String get reminderWeekdays => '工作日';

  @override
  String get reminderWeekends => '周末';

  @override
  String reminderIntervalMinutes(int minutes) {
    return '每 $minutes 分钟';
  }

  @override
  String reminderIntervalHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '每 $hours 小时',
    );
    return '$_temp0';
  }

  @override
  String reminderIntervalHoursMinutes(int hours, int minutes) {
    return '每 $hours 小时 $minutes 分钟';
  }

  @override
  String get reminderAddSchedule => '添加提醒时段';

  @override
  String get reminderEditSchedule => '编辑提醒时段';

  @override
  String get reminderStart => '开始';

  @override
  String get reminderEnd => '结束';

  @override
  String get reminderCrossesMidnight => '如果结束时间早于开始时间，提醒将跨过午夜，持续到次日的结束时间。';

  @override
  String get reminderWeekdaysTitle => '提醒日期';

  @override
  String get reminderWeekdaysRequired => '请至少选择一天。';

  @override
  String get reminderInterval => '提醒间隔';

  @override
  String get reminderWordsPerAlert => '每次';

  @override
  String get reminderDecreaseWords => '减少单词';

  @override
  String get reminderIncreaseWords => '增加单词';

  @override
  String reminderWordCount(int count) {
    return '$count';
  }

  @override
  String reminderWordCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个单词',
    );
    return '$_temp0';
  }

  @override
  String reminderTimesPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每天 $count 次',
    );
    return '$_temp0';
  }

  @override
  String reminderPreview(String days, int count, String times) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次',
    );
    return '$days，$_temp0 · $times';
  }

  @override
  String get translationLanguageLabel => '翻译语言';

  @override
  String translationLanguageAuto(String language) {
    return '自动 · $language';
  }

  @override
  String get notificationChannelName => '单词通知';

  @override
  String get notificationChannelDescription => '在设定的日期和时段以通知显示单词和释义';

  @override
  String get notificationTitleDefault => '今日单词';

  @override
  String notificationTitleWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '今日单词 $count 个',
    );
    return '$_temp0';
  }

  @override
  String get notificationBodyDefault => '添加单词后，这里会显示单词和释义。';

  @override
  String homeError(String error) {
    return '错误：$error';
  }

  @override
  String get homeGreeting => '今天也来背单词吧？';

  @override
  String get homeTodayStudy => '今日学习';

  @override
  String homeTotalWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '共 $count 个单词',
    );
    return '$_temp0';
  }

  @override
  String get homeAccuracy => '正确率';

  @override
  String homeCompletedWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已掌握 $count 个',
    );
    return '$_temp0';
  }

  @override
  String get homeWordOfTheDay => '每日一词';

  @override
  String get homeQuickStart => '快速开始';

  @override
  String get homeQuickGuessWord => '填空 · 输入';

  @override
  String get homeQuickFillBlank => '填空 · 选择';

  @override
  String get homeQuickBrowseWordbooks => '浏览单词本';

  @override
  String get homeCreateWordbookFirst => '请先创建单词本。';

  @override
  String get homeEditWord => '编辑单词';

  @override
  String get homeListenWord => '听单词发音';

  @override
  String get homeSeeDetails => '查看详情';

  @override
  String get homeReviewAllDone => '今天的复习\n全部完成！';

  @override
  String homeReviewWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 个单词\n在等你',
    );
    return '$_temp0';
  }

  @override
  String homeCompletedBadge(int count) {
    return '$count\n已掌握';
  }

  @override
  String homeReviewBreakdown(int due, int mixed) {
    return '新词/复习 $due · 混入 $mixed';
  }

  @override
  String get homeStart => '开始';

  @override
  String get reviewNoExample => '（无例句 — 请根据释义输入单词）';

  @override
  String get reviewTitle => '例句复习';

  @override
  String get reviewEmpty => '今天没有卡片';

  @override
  String get reviewFillBlankTitle => '填空';

  @override
  String get reviewChoiceInstruction => '根据例句和释义选出正确的单词';

  @override
  String get reviewInputInstruction => '根据例句和释义输入单词';

  @override
  String reviewOtherExample(int current, int total) {
    return '换个例句  $current/$total';
  }

  @override
  String get reviewDontKnow => '不知道';

  @override
  String get reviewInputHint => '输入单词';

  @override
  String reviewHint(String hint) {
    return '提示：$hint';
  }

  @override
  String get reviewCheckAnswer => '核对答案';

  @override
  String get reviewCorrect => '回答正确！';

  @override
  String get reviewWrongAnswerIs => '差一点。正确答案是';

  @override
  String reviewSource(String source) {
    return '来源：$source';
  }

  @override
  String get reviewMixedNotice => '这是混入复习的已掌握单词';

  @override
  String get reviewSummaryTitle => '复习完成';

  @override
  String get reviewSummaryDone => '你已完成本次复习';

  @override
  String reviewSummaryScore(int correct, int total) {
    return '$total 题中答对 $correct 题';
  }

  @override
  String get reviewGoHome => '返回首页';

  @override
  String get dictionaryRateLimited => '词典查询暂时受限，请稍后再试。';

  @override
  String get dictionaryConnectionFailed => '无法连接词典，请稍后再试。';

  @override
  String get dictionaryTimeout => '词典响应超时，请重试。';

  @override
  String get dictionaryLoadFailed => '无法加载词典释义。请检查网络连接后重试。';

  @override
  String get draftDictionaryUnavailable => '无法连接词典。请手动输入释义或重新查询。';

  @override
  String get draftMeaningNotFound => '未找到释义。请手动输入或在词典中查找。';

  @override
  String draftNoTranslationUsedEnglish(String language) {
    return '词典中没有$language释义，已使用英文释义填写。可在设置中更改翻译语言。';
  }

  @override
  String draftSomeUsedEnglish(String language) {
    return '没有$language释义的条目已使用英文释义填写。';
  }

  @override
  String get draftExamplesRetry => '可通过下方的“获取例句”重新加载例句。';

  @override
  String get speakListen => '听发音';

  @override
  String get speakListenExample => '听例句';

  @override
  String get adPreview => '广告预览';

  @override
  String get addWordButton => '添加单词';

  @override
  String get wordCreateExampleTranslations => '包含例句翻译';

  @override
  String get wordCreateNoExampleTranslations => '无翻译';

  @override
  String get homeRemainingCards => '剩余卡片';

  @override
  String homeTodayCards(int count) {
    return '今天复习 $count张';
  }

  @override
  String get homeStartButton => '开始';

  @override
  String get homeNoCardsToday => '今天没有卡片';

  @override
  String reviewRemaining(int count) {
    return '剩余 $count';
  }

  @override
  String get reviewKeep => '保留';

  @override
  String get reviewDiscard => '丢弃';

  @override
  String reviewDoneTitle(int count) {
    return '今天的$count张 完成';
  }

  @override
  String wordbooksCardsLeft(int count) {
    return '张剩余 · 共$count';
  }

  @override
  String get wordbookCardsLeftSuffix => '张剩余';

  @override
  String get wordbookDetailAllDiscarded => '没有剩余卡片';

  @override
  String wordbookDetailDiscarded(String term) {
    return '已丢弃 \'$term\'';
  }

  @override
  String get wordbookDetailReleaseToDiscard => '松开即丢弃';

  @override
  String get wordbookAddWordShort => '单词';

  @override
  String get discardedTitle => '已丢弃的卡片';

  @override
  String get discardedEmpty => '没有丢弃的卡片';

  @override
  String get discardedRestore => '放回';

  @override
  String get wordAddMeaningSelect => '选择词义';

  @override
  String get wordAddManualInput => '手动输入释义';

  @override
  String get wordAddMeaningLabel => '词义';

  @override
  String wordAddExamplesOf(String pos) {
    return '$pos 例句';
  }

  @override
  String wordAddSelectedCount(int count) {
    return '已选$count个';
  }

  @override
  String get wordAddWriteExample => '自己写例句';

  @override
  String get wordAddSave => '添加';

  @override
  String get wordAddAlreadyInDeck => '已在卡组中';

  @override
  String get wordAddNoResults => '词典中没有';

  @override
  String get wordAddLookupFailed => '无法连接词典';

  @override
  String get wordAddAutoInput => '自动填写';

  @override
  String get wordAddAutoOff => '自动填写已关闭';

  @override
  String get wordAddExampleTranslation => '例句翻译';

  @override
  String get wordAddNoExamples => '没有候选例句。可以不加例句直接添加。';

  @override
  String get settingsTheme => '主题';

  @override
  String get themeSlate => '石板';

  @override
  String get themeNavy => '藏青';

  @override
  String get themeBrown => '棕色';

  @override
  String get themePlum => '李紫';

  @override
  String get themeCharcoal => '炭灰';

  @override
  String get themeCustom => '自定义';

  @override
  String get themeCustomTitle => '自定义主题';

  @override
  String get themeBase => '底色';

  @override
  String get themePoint => '强调色';

  @override
  String get themeAutoText => '文字颜色自动调整';

  @override
  String get themeApply => '应用';

  @override
  String get themeReset => '重置';

  @override
  String get settingsLanguageSection => '语言';

  @override
  String get settingsLanguageRow => '词义 · 例句 · 应用';

  @override
  String get settingsFollowDevice => '跟随设备';

  @override
  String get settingsReviewSection => '复习';

  @override
  String get settingsSessionSize => '每次复习的卡片数';

  @override
  String get settingsMixLabel => '混入已丢弃的卡片';

  @override
  String settingsMixExample(int total, int mixed) {
    return '$total张中$mixed张';
  }

  @override
  String get settingsWordAddSection => '添加单词';

  @override
  String get settingsNotificationsSection => '提醒';

  @override
  String get settingsReminderMaster => '单词通知';

  @override
  String get settingsAddSlot => '提醒时段';

  @override
  String settingsWeeklyCount(int count) {
    return '每周$count次';
  }

  @override
  String reminderCardCount(int count) {
    return '$count张';
  }

  @override
  String get settingsPronunciationSection => '发音';

  @override
  String get settingsAccent => '口音';

  @override
  String get settingsVoice => '声音';

  @override
  String get settingsVoiceDefault => '默认';

  @override
  String get settingsSpeed => '速度';

  @override
  String get settingsSpeedSlow => '慢';

  @override
  String get settingsSpeedNormal => '正常';

  @override
  String get settingsSpeedFast => '快';

  @override
  String get settingsRecorded => '单词用真人录音';

  @override
  String get settingsRecordedHelp => '没有录音时用语音朗读';

  @override
  String get settingsAbout => '信息 · 来源';

  @override
  String get settingsPrivacy => '隐私政策';

  @override
  String get aboutDataSources => '数据来源';

  @override
  String get aboutUseMeanings => '词义 · 词典例句';

  @override
  String get aboutUseOnline => '在线词典';

  @override
  String get aboutUseExamples => '带翻译的例句';

  @override
  String get aboutUseRecordings => '单词发音录音';

  @override
  String get aboutApp => '应用';

  @override
  String get aboutVersion => '版本';

  @override
  String get aboutLicenses => '开源许可';

  @override
  String reminderPerDayTotal(int times, int cards) {
    return '每天$times次 · $cards张';
  }

  @override
  String settingsPackDownloading(String size) {
    return '正在下载例句翻译 · $size';
  }

  @override
  String settingsPackReady(String size) {
    return '例句翻译已下载 · $size';
  }

  @override
  String get settingsPackFailed => '无法下载例句翻译';

  @override
  String get settingsPackRetry => '重试';

  @override
  String get settingsExampleDataSection => '例句数据';

  @override
  String get settingsExampleData => '下载例句翻译';

  @override
  String get settingsPackNone => '未下载';

  @override
  String get settingsPackNotNeeded => '英语不需要翻译';

  @override
  String settingsPackVersion(int version, String size) {
    return '已下载 · v$version · $size';
  }

  @override
  String get settingsPackUpdate => '检查更新';

  @override
  String settingsPackUpToDate(int version) {
    return '已是最新版本 (v$version)';
  }

  @override
  String settingsPackUpdated(int version) {
    return '已更新到 v$version';
  }

  @override
  String get examplePromptTitle => '要下载例句翻译吗？';

  @override
  String examplePromptBody(String language, String size) {
    return '将英语例句的$language翻译下载到本设备$size。可随时在设置的“例句数据”中更改。';
  }

  @override
  String get examplePromptAccept => '下载';

  @override
  String get examplePromptDecline => '暂不下载';

  @override
  String get wordAddPosLabel => '词性';

  @override
  String get wordAddPosUnknown => '不确定';

  @override
  String get homeQuickGuessFromMeaning => '看释义猜单词';

  @override
  String get wordFoundExample => '找到的例句';

  @override
  String get wordAddFoundExample => '添加例句';

  @override
  String wordbookFoundExamples(int count) {
    return '找到 $count 个例句';
  }

  @override
  String get wordAddScanExample => '从照片获取例句';

  @override
  String get wordScanCamera => '拍照';

  @override
  String get wordScanGallery => '从相册选择';

  @override
  String get wordScanFailed => '无法识别照片中的文字';

  @override
  String wordScanNoSentence(String term) {
    return '照片中没有找到包含“$term”的句子';
  }

  @override
  String get exampleSourcePhoto => '我的照片';

  @override
  String wordScanAdded(int count) {
    return '已从照片添加 $count 个句子';
  }

  @override
  String homeNewReviewBreakdown(int fresh, int review) {
    return '新 $fresh · 复习 $review';
  }

  @override
  String get settingsAnswerStyle => '答题方式';

  @override
  String get settingsAnswerInput => '填写单词';

  @override
  String get settingsAnswerChoice => '四选一';

  @override
  String get settingsAnswerHelp => '在首页点“开始”复习时使用此方式。';

  @override
  String get sampleWelcomeMeaning => '欢迎';

  @override
  String get sampleWelcomeExample1 => '欢迎来到 WordPing！';

  @override
  String get sampleWelcomeExample2 => '欢迎大家回来。';

  @override
  String get homeAddCardHint => '输入英语单词，自动查找释义和例句做成卡片';
}
