// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Vocab with Examples';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '削除';

  @override
  String get commonAdd => '追加';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonRetry => '再試行';

  @override
  String get commonNext => '次へ';

  @override
  String get commonEdit => '編集';

  @override
  String get commonConfirm => 'OK';

  @override
  String get commonLoading => '読み込み中';

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ko': '韓国語',
      'ja': '日本語',
      'zh': '中国語',
      'es': 'スペイン語',
      'fr': 'フランス語',
      'de': 'ドイツ語',
      'pt': 'ポルトガル語',
      'vi': 'ベトナム語',
      'th': 'タイ語',
      'id': 'インドネシア語',
      'en': '英語',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': '月',
      'd2': '火',
      'd3': '水',
      'd4': '木',
      'd5': '金',
      'd6': '土',
      'd7': '日',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get wordAddWord => '単語を追加';

  @override
  String get wordEditWord => '単語を編集';

  @override
  String get wordExamples => '例文';

  @override
  String wordExampleSource(String source) {
    return '出典: $source';
  }

  @override
  String wordPartOfSpeech(String pos, String value) {
    String _temp0 = intl.Intl.selectLogic(pos, {
      'noun': '名詞',
      'verb': '動詞',
      'adjective': '形容詞',
      'adverb': '副詞',
      'pronoun': '代名詞',
      'preposition': '前置詞',
      'conjunction': '接続詞',
      'interjection': '間投詞',
      'article': '冠詞',
      'determiner': '限定詞',
      'phrasalVerb': '句動詞',
      'idiom': '熟語',
      'phrase': '句',
      'other': '$value',
    });
    return '$_temp0';
  }

  @override
  String get wordEditTermRequired => '先に英単語を入力してください。';

  @override
  String wordEditNoExamplesFound(String term) {
    return '\'$term\' の例文が見つかりませんでした。';
  }

  @override
  String get wordEditExamplesAlreadyAdded => '取得した例文はすべて追加済みです。';

  @override
  String wordEditExamplesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '例文を$count件追加しました。',
    );
    return '$_temp0';
  }

  @override
  String wordEditExamplesFetchFailed(String error) {
    return '例文を取得できませんでした: $error';
  }

  @override
  String get wordEditTermAndMeaningRequired => '単語と意味を1つ以上入力してください。';

  @override
  String get wordEditSaveFailed => '保存できませんでした。もう一度お試しください。';

  @override
  String get wordEditSectionTerm => '単語';

  @override
  String get wordEditSectionMeaning => '意味と発音';

  @override
  String get wordEditPhonetic => '発音記号';

  @override
  String get wordEditSearching => '検索中';

  @override
  String get wordEditFetchExamples => '例文を取得';

  @override
  String get wordEditAddManually => '手動で追加';

  @override
  String get wordEditOptional => '任意';

  @override
  String wordEditExampleNumber(int index) {
    return '例文 $index';
  }

  @override
  String get wordEditDeleteExample => '例文を削除';

  @override
  String get wordEditSentence => '英文';

  @override
  String wordEditTranslationLabel(String language) {
    return '訳 ($language)';
  }

  @override
  String get wordEditTermLabel => '単語 *';

  @override
  String get wordEditTermHint => '保存済みの単語を選ぶと、意味と例文が自動で入力されます。';

  @override
  String get wordEditPartOfSpeech => '品詞';

  @override
  String get wordEditPartOfSpeechNone => '指定なし';

  @override
  String get wordEditManualExampleTitle => '例文を手動で追加';

  @override
  String get wordEditSentenceRequiredLabel => '英文 *';

  @override
  String get wordEditSentenceRequired => '英文を入力してください。';

  @override
  String wordEditPickerTitle(String term) {
    return '\'$term\' の例文';
  }

  @override
  String get wordEditPickerDescription => '追加する例文を選んでください。訳がない文は自分で入力できます。';

  @override
  String wordEditNoTranslation(String language) {
    return '$language訳なし';
  }

  @override
  String get wordEditPickerAttribution => '例文の出典: Tatoeba · CC BY 2.0 FR';

  @override
  String wordEditAddSelectedExamples(int count) {
    return '選択した例文を追加 ($count)';
  }

  @override
  String get wordCreateLoadFailed => '読み込めませんでした。もう一度お試しください。';

  @override
  String get wordCreateSectionTitle => '単語を入力';

  @override
  String get wordCreateWordbook => '単語帳';

  @override
  String get wordCreateNoWordbook => '単語帳がありません';

  @override
  String get wordCreateReload => '再読み込み';

  @override
  String get wordCreateTermLabel => '単語';

  @override
  String get wordCreateLookingUp => '検索中';

  @override
  String get wordCreateAutoInputSettings => '自動入力の設定';

  @override
  String get wordCreateMeaningsOn => '意味 オン';

  @override
  String get wordCreateMeaningsOff => '意味 オフ';

  @override
  String get wordCreateExamplesOn => '例文 オン';

  @override
  String get wordCreateExamplesOff => '例文 オフ';

  @override
  String get wordCreateCollapse => '折りたたむ';

  @override
  String get wordCreateExpand => '展開';

  @override
  String get wordCreateAutoMeanings => '意味を自動入力';

  @override
  String get wordCreateAutoExamples => '例文を自動入力';

  @override
  String get wordDetailDictionaryMeaningsAdded => '選択した辞書の意味を追加しました。';

  @override
  String get wordDetailTitle => '単語の詳細';

  @override
  String get wordDetailFavorite => 'お気に入りに追加';

  @override
  String get wordDetailUnfavorite => 'お気に入りから削除';

  @override
  String get wordDetailAccentUs => 'アメリカ英語';

  @override
  String get wordDetailAccentUk => 'イギリス英語';

  @override
  String get wordDetailMyMeanings => '保存した意味';

  @override
  String get wordDetailListenExample => '例文を聞く';

  @override
  String get wordDetailGoogleTranslate => 'Google 翻訳';

  @override
  String get meaningFieldsLabel => '意味';

  @override
  String get meaningFieldsLabelRequired => '意味 *';

  @override
  String meaningFieldsLabelNumbered(int index) {
    return '意味 $index';
  }

  @override
  String meaningFieldsRemove(int index) {
    return '意味 $index を削除';
  }

  @override
  String get meaningFieldsAdd => '意味を追加';

  @override
  String get meaningFieldsEmptyError => '意味を1つ以上入力してください。';

  @override
  String get meaningFieldsEditTitle => '意味を編集';

  @override
  String get dictLookupAddFailed => '意味を追加できませんでした。もう一度お試しください。';

  @override
  String get dictLookupButton => '辞書の意味';

  @override
  String dictLookupTitle(String term) {
    return '$term · 辞書';
  }

  @override
  String dictLookupFallbackNotice(String language) {
    return '$languageの意味がない項目は英語の定義を表示します。';
  }

  @override
  String get dictLookupLoadFailed => '辞書の意味を読み込めませんでした。';

  @override
  String get dictLookupNoResults =>
      '辞書に意味が見つかりませんでした。\nつづりを確認するか、別の辞書で調べてください。';

  @override
  String get dictLookupAlreadyAdded => '追加済み';

  @override
  String dictLookupAddSelected(int count) {
    return '選択した意味を追加 ($count)';
  }

  @override
  String get dictLookupLinkFailed => '辞書のリンクを開けませんでした。';

  @override
  String get dictLinksNaver => 'Naver(英韓)';

  @override
  String get dictLinksOxford => 'Oxford(英英)';

  @override
  String get dictLinksOpenFailed => '辞書を開けませんでした。もう一度お試しください。';

  @override
  String get dictLinksTitle => '辞書でもっと見る';

  @override
  String wordbookError(String error) {
    return 'エラー: $error';
  }

  @override
  String get wordbookShareCode => '共有コード';

  @override
  String wordbookDeleteTitle(String name) {
    return '\'$name\' を削除';
  }

  @override
  String get wordbooksTitle => 'マイ単語帳';

  @override
  String get wordbooksNew => '新しい単語帳';

  @override
  String get wordbooksEmpty => '単語帳がありません。\n+ をタップして追加しましょう。';

  @override
  String get wordbooksCreate => '作成';

  @override
  String get wordbooksNameLabel => '単語帳の名前';

  @override
  String get wordbooksTagsLabel => 'タグ';

  @override
  String get wordbooksTagsHint => 'TOEIC, 日常会話 (カンマ区切り)';

  @override
  String wordbooksWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count語',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksMenu => '単語帳メニュー';

  @override
  String get wordbooksMenuRename => '名前・タグを編集';

  @override
  String get wordbooksShareSettings => '共有・公開設定';

  @override
  String get wordbooksMenuDelete => '単語帳を削除';

  @override
  String get wordbooksEditTitle => '単語帳を編集';

  @override
  String get wordbooksShareLoginRequired => '共有・公開するにはログインしてください。';

  @override
  String get wordbooksVisibilityPrivate => '非公開';

  @override
  String get wordbooksVisibilityShared => 'コードで共有';

  @override
  String get wordbooksVisibilityPublic => '公開';

  @override
  String get wordbooksVisibilityPrivateDesc => '自分だけが見られます。';

  @override
  String get wordbooksVisibilitySharedDesc => '共有コードを知っている人はこの単語帳をコピーできます。';

  @override
  String get wordbooksVisibilityPublicDesc => '「探す」タブに掲載され、誰でもコピーできます。';

  @override
  String get wordbooksCopyCode => 'コードをコピー';

  @override
  String get wordbooksCodeCopied => '共有コードをコピーしました。';

  @override
  String wordbooksDeleteWithWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'この単語帳の$count語も一緒に削除されます。\n削除した単語帳は元に戻せません。',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksDeleteEmpty => '削除した単語帳は元に戻せません。';

  @override
  String get wordbookDetailEmpty => '単語がありません。\n「単語を追加」ボタンをタップしてください。';

  @override
  String wordbookDetailWordDeleted(String term) {
    return '\'$term\' を削除しました';
  }

  @override
  String get wordbookDetailUndo => '元に戻す';

  @override
  String get wordbookDetailEditWholeWord => '単語全体を編集';

  @override
  String get wordbookDetailEditWord => '単語を編集';

  @override
  String get wordbookDetailFavorite => 'お気に入り';

  @override
  String get wordbookDetailUnfavorite => 'お気に入りから削除';

  @override
  String get wordbookDetailEditMeaning => '意味を編集';

  @override
  String get wordbookDetailEditAll => 'すべて編集';

  @override
  String get wordbookDetailStatusFresh => '未学習';

  @override
  String get wordbookDetailStatusLearning => '学習中';

  @override
  String get wordbookDetailStatusCompleted => '完了';

  @override
  String get wordbookDetailDeleteWordConfirm => 'この単語を削除しますか？';

  @override
  String get wordbookDetailReleaseToDelete => '離すと削除';

  @override
  String get exploreTitle => '探す';

  @override
  String get exploreCodeNotFound => 'このコードに一致する共有単語帳はありません。';

  @override
  String get exploreImportFailed => '取り込めませんでした。ネットワーク接続を確認してください。';

  @override
  String exploreCopyTitle(String title) {
    return '\'$title\' をコピー';
  }

  @override
  String exploreCopyConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count語をマイ単語帳にコピーしますか？\n学習状況は最初からになります。',
    );
    return '$_temp0';
  }

  @override
  String get exploreCopy => 'コピー';

  @override
  String exploreImported(String title) {
    return '\'$title\' を取り込みました。';
  }

  @override
  String get exploreLoggedOutHeadline => '新しい単語帳を\n見つけよう';

  @override
  String get exploreLoginRequired => '共有単語帳を探すにはログインしてください。';

  @override
  String get exploreGoToLogin => 'ログイン';

  @override
  String get exploreSupabaseRequired => 'Supabase に接続すると利用できます。';

  @override
  String get exploreImportByCode => '共有コードで取り込む';

  @override
  String get exploreCodeHint => '受け取ったコードを貼り付け';

  @override
  String get exploreImport => '取り込む';

  @override
  String get exploreCodeHelp => '単語帳メニューの「共有・公開設定」でコードをコピーして共有できます。';

  @override
  String get explorePublicWordbooks => '公開単語帳';

  @override
  String get explorePublicLoadFailed => '公開単語帳を読み込めませんでした。\n下に引いて更新してください。';

  @override
  String get explorePublicEmpty => '公開されている単語帳はまだありません。';

  @override
  String get loginMigrateTitle => '端末の単語帳を取り込む';

  @override
  String loginMigrateConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'この端末で作成した単語帳$count件をクラウドにコピーしますか？\nクラウドにすでにある単語帳はスキップされます。',
    );
    return '$_temp0';
  }

  @override
  String get loginLater => '後で';

  @override
  String get loginImport => '取り込む';

  @override
  String loginMigrated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '単語帳を$count件取り込みました。',
    );
    return '$_temp0';
  }

  @override
  String get loginAlreadyInCloud => 'すべての単語帳はすでにクラウドにあります。';

  @override
  String get loginErrorInvalidCredentials => 'メールアドレスまたはパスワードが正しくありません。';

  @override
  String get loginErrorUserExists => 'このメールアドレスは登録済みです。ログインしてください。';

  @override
  String get loginErrorWeakPassword => 'パスワードが短すぎます。6文字以上で入力してください。';

  @override
  String get loginErrorEmailNotConfirmed => 'メールアドレスの確認が必要です。受信トレイをご確認ください。';

  @override
  String get loginErrorRateLimit => 'リクエストが多すぎます。しばらくしてからもう一度お試しください。';

  @override
  String loginErrorGeneric(String message) {
    return 'ログインに失敗しました。($message)';
  }

  @override
  String get loginErrorNetwork => 'リクエストを処理できませんでした。ネットワーク接続を確認して、もう一度お試しください。';

  @override
  String get loginTitle => 'ログイン';

  @override
  String get loginTagline => '例文でかんたんに、リマインダーでコツコツと';

  @override
  String get loginEmail => 'メールアドレス';

  @override
  String get loginPassword => 'パスワード';

  @override
  String get loginSignUpWithEmail => 'メールで新規登録';

  @override
  String get loginContinueWithGoogle => 'Google で続ける';

  @override
  String get navHome => 'ホーム';

  @override
  String get navWordbooks => '単語帳';

  @override
  String get navSettings => '設定';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsTranslationSection => '意味・例文の翻訳';

  @override
  String get settingsTranslationHelp =>
      '「自動」では端末の言語と地域に合わせて設定されます。翻訳は新しく調べた単語の意味と例文に使われます。翻訳がない意味は英語の定義で表示し、例文の訳は空欄になります。保存済みの内容は自動では変わりません。';

  @override
  String get settingsAppLanguageNote =>
      'アプリの表示もこの言語になります。アプリが未対応の言語は英語で表示されます。';

  @override
  String get settingsReviewMixSection => '復習のミックス率';

  @override
  String get settingsReviewMixLabel => '覚えた単語も混ぜる';

  @override
  String settingsReviewMixHelp(int total, int mixed) {
    return '「完了」の単語をこの割合で復習セットに混ぜ、長期記憶を強化します。(例: $total問中$mixed問)';
  }

  @override
  String get settingsReminderSection => 'リマインダー・復習';

  @override
  String get settingsReminderToggle => '復習リマインダーを受け取る';

  @override
  String get settingsReminderOff => 'リマインダーはオフです。';

  @override
  String get settingsReminderNoActive => 'オンになっている通知時間帯がありません。';

  @override
  String settingsReminderSummary(int count) {
    return '毎週繰り返し · 週$count回通知します。学習中の単語を復習の順番に沿ってお届けします。';
  }

  @override
  String settingsReminderCapped(int limit) {
    return '端末の予約通知の上限($limit件)を超えるため、遅い時刻の通知は一部省かれます。';
  }

  @override
  String get settingsTtsSection => '発音・TTS';

  @override
  String get settingsTtsDefault => '標準の発音';

  @override
  String get settingsTtsDefaultHelp => '単語と例文の読み上げに使うアクセントを選んでください。';

  @override
  String get settingsTtsUs => 'アメリカ英語';

  @override
  String get settingsTtsUk => 'イギリス英語';

  @override
  String get settingsTtsQuality => '音声の品質';

  @override
  String get settingsTtsQualityValue => '端末のTTS(無料)';

  @override
  String get settingsTatoebaCredit => '外部の例文: Tatoeba · CC BY 2.0 FR';

  @override
  String get reminderEveryDay => '毎日';

  @override
  String get reminderNoWeekdays => '曜日なし';

  @override
  String get reminderWeekdays => '平日';

  @override
  String get reminderWeekends => '週末';

  @override
  String reminderIntervalMinutes(int minutes) {
    return '$minutes分ごと';
  }

  @override
  String reminderIntervalHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours時間ごと',
    );
    return '$_temp0';
  }

  @override
  String reminderIntervalHoursMinutes(int hours, int minutes) {
    return '$hours時間$minutes分ごと';
  }

  @override
  String get reminderAddSchedule => '通知時間帯を追加';

  @override
  String get reminderEditSchedule => '通知時間帯を編集';

  @override
  String get reminderStart => '開始';

  @override
  String get reminderEnd => '終了';

  @override
  String get reminderCrossesMidnight => '終了時刻が開始より早い場合は、日付をまたいで翌日の終了時刻まで通知します。';

  @override
  String get reminderWeekdaysTitle => '通知する曜日';

  @override
  String get reminderWeekdaysRequired => '曜日を1つ以上選んでください。';

  @override
  String get reminderInterval => '通知の間隔';

  @override
  String get reminderWordsPerAlert => '1回に';

  @override
  String get reminderDecreaseWords => '単語数を減らす';

  @override
  String get reminderIncreaseWords => '単語数を増やす';

  @override
  String reminderWordCount(int count) {
    return '$count語';
  }

  @override
  String reminderWordCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count語',
    );
    return '$_temp0';
  }

  @override
  String reminderTimesPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '1日$count回',
    );
    return '$_temp0';
  }

  @override
  String reminderPreview(String days, int count, String times) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count回',
    );
    return '$days $_temp0 · $times';
  }

  @override
  String get translationLanguageLabel => '翻訳言語';

  @override
  String translationLanguageAuto(String language) {
    return '自動 · $language';
  }

  @override
  String get notificationChannelName => '単語の通知';

  @override
  String get notificationChannelDescription => '設定した曜日・時間帯に単語と意味を通知で表示します';

  @override
  String get notificationTitleDefault => '今日の単語';

  @override
  String notificationTitleWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '今日の単語 $count語',
    );
    return '$_temp0';
  }

  @override
  String get notificationBodyDefault => '単語を追加すると、ここに単語と意味が表示されます。';

  @override
  String homeError(String error) {
    return 'エラー: $error';
  }

  @override
  String get homeGreeting => '今日も単語を覚えましょう！';

  @override
  String get homeTodayStudy => '今日の学習';

  @override
  String homeTotalWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '全$count語',
    );
    return '$_temp0';
  }

  @override
  String get homeAccuracy => '正答率';

  @override
  String homeCompletedWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count語 習得',
    );
    return '$_temp0';
  }

  @override
  String get homeWordOfTheDay => '今日の単語';

  @override
  String get homeQuickStart => 'クイックスタート';

  @override
  String get homeQuickGuessWord => '空欄補充・入力';

  @override
  String get homeQuickFillBlank => '空欄補充・選択';

  @override
  String get homeQuickBrowseWordbooks => '単語帳を見る';

  @override
  String get homeCreateWordbookFirst => '先に単語帳を作成してください。';

  @override
  String get homeEditWord => '単語を編集';

  @override
  String get homeListenWord => '発音を聞く';

  @override
  String get homeSeeDetails => '詳しく見る';

  @override
  String get homeReviewAllDone => '今日の復習は\nすべて完了！';

  @override
  String homeReviewWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個の単語が\n待っています',
    );
    return '$_temp0';
  }

  @override
  String homeCompletedBadge(int count) {
    return '$count\n完了';
  }

  @override
  String homeReviewBreakdown(int due, int mixed) {
    return '新規/復習 $due · ミックス $mixed';
  }

  @override
  String get homeStart => 'スタート';

  @override
  String get reviewNoExample => '(例文なし — 意味を見て単語を入力してください)';

  @override
  String get reviewTitle => '例文で復習';

  @override
  String get reviewEmpty => '今日のカードなし';

  @override
  String get reviewFillBlankTitle => '穴埋め';

  @override
  String get reviewChoiceInstruction => '例文と意味に合う単語を選んでください';

  @override
  String get reviewInputInstruction => '例文と意味に合う単語を入力してください';

  @override
  String reviewOtherExample(int current, int total) {
    return '別の例文  $current/$total';
  }

  @override
  String get reviewDontKnow => 'わからない';

  @override
  String get reviewInputHint => '単語を入力';

  @override
  String reviewHint(String hint) {
    return 'ヒント: $hint';
  }

  @override
  String get reviewCheckAnswer => '答え合わせ';

  @override
  String get reviewCorrect => '正解！';

  @override
  String get reviewWrongAnswerIs => '惜しい！正解は';

  @override
  String reviewSource(String source) {
    return '出典: $source';
  }

  @override
  String get reviewMixedNotice => '習得済みの単語を復習に混ぜています';

  @override
  String get reviewSummaryTitle => '復習完了';

  @override
  String get reviewSummaryDone => '復習が終わりました';

  @override
  String reviewSummaryScore(int correct, int total) {
    return '$total問中$correct問正解';
  }

  @override
  String get reviewGoHome => 'ホームに戻る';

  @override
  String get dictionaryRateLimited => '辞書の検索が一時的に制限されています。しばらくしてからもう一度お試しください。';

  @override
  String get dictionaryConnectionFailed => '辞書に接続できませんでした。しばらくしてからもう一度お試しください。';

  @override
  String get dictionaryTimeout => '辞書の応答に時間がかかっています。もう一度お試しください。';

  @override
  String get dictionaryLoadFailed =>
      '辞書の意味を読み込めませんでした。インターネット接続を確認して、もう一度お試しください。';

  @override
  String get draftDictionaryUnavailable =>
      '辞書に接続できませんでした。意味を自分で入力するか、もう一度検索してください。';

  @override
  String get draftMeaningNotFound => '意味が見つかりませんでした。自分で入力するか、辞書で調べてください。';

  @override
  String draftNoTranslationUsedEnglish(String language) {
    return '辞書に$languageの意味がないため、英語の定義を入力しました。翻訳言語は設定で変更できます。';
  }

  @override
  String draftSomeUsedEnglish(String language) {
    return '$languageの意味がない項目は英語の定義で入力しました。';
  }

  @override
  String get draftExamplesRetry => '例文は下の「例文を取得」で再度読み込めます。';

  @override
  String get speakListen => '発音を聞く';

  @override
  String get speakListenExample => '例文を聞く';

  @override
  String get adPreview => '広告プレビュー';

  @override
  String get addWordButton => '単語を追加';

  @override
  String get wordCreateExampleTranslations => '例文の訳を含める';

  @override
  String get wordCreateNoExampleTranslations => '訳なし';

  @override
  String get homeRemainingCards => '残りのカード';

  @override
  String homeTodayCards(int count) {
    return '今日の復習 $count枚';
  }

  @override
  String get homeStartButton => 'スタート';

  @override
  String get homeNoCardsToday => '今日のカードなし';

  @override
  String reviewRemaining(int count) {
    return '残り $count';
  }

  @override
  String get reviewKeep => '残す';

  @override
  String get reviewDiscard => '捨てる';

  @override
  String reviewDoneTitle(int count) {
    return '今日の$count枚 完了';
  }

  @override
  String wordbooksCardsLeft(int count) {
    return '枚残り · 全$count';
  }

  @override
  String get wordbookCardsLeftSuffix => '枚残り';

  @override
  String get wordbookDetailAllDiscarded => '残りのカードなし';

  @override
  String wordbookDetailDiscarded(String term) {
    return '\'$term\' を捨てました';
  }

  @override
  String get wordbookDetailReleaseToDiscard => '離すと捨てる';

  @override
  String get wordbookAddWordShort => '単語';

  @override
  String get discardedTitle => '捨てたカード';

  @override
  String get discardedEmpty => '捨てたカードなし';

  @override
  String get discardedRestore => '戻す';

  @override
  String get wordAddMeaningSelect => '意味を選ぶ';

  @override
  String get wordAddManualInput => '意味を入力';

  @override
  String get wordAddMeaningLabel => '意味';

  @override
  String wordAddExamplesOf(String pos) {
    return '$pos の例文';
  }

  @override
  String wordAddSelectedCount(int count) {
    return '$count件選択';
  }

  @override
  String get wordAddWriteExample => '例文を書く';

  @override
  String get wordAddSave => '登録';

  @override
  String get wordAddAlreadyInDeck => 'デッキにあります';

  @override
  String get wordAddNoResults => '辞書になし';

  @override
  String get wordAddLookupFailed => '辞書に接続できません';

  @override
  String get wordAddAutoInput => '自動入力';

  @override
  String get wordAddAutoOff => '自動入力オフ';

  @override
  String get wordAddExampleTranslation => '例文の訳';

  @override
  String get wordAddNoExamples => '例文の候補がありません。例文なしで登録できます。';

  @override
  String get settingsTheme => 'テーマ';

  @override
  String get themeSlate => 'スレート';

  @override
  String get themeNavy => 'ネイビー';

  @override
  String get themeBrown => 'ブラウン';

  @override
  String get themePlum => 'プラム';

  @override
  String get themeCharcoal => 'チャコール';

  @override
  String get themeCustom => 'カスタム';

  @override
  String get themeCustomTitle => 'テーマを自分で設定';

  @override
  String get themeBase => 'ベース';

  @override
  String get themePoint => 'アクセント';

  @override
  String get themeAutoText => '文字色は自動で調整';

  @override
  String get themeApply => '適用';

  @override
  String get themeReset => 'リセット';

  @override
  String get settingsLanguageSection => '言語';

  @override
  String get settingsLanguageRow => '意味 · 例文 · アプリ';

  @override
  String get settingsFollowDevice => '端末の設定に従う';

  @override
  String get settingsReviewSection => '復習';

  @override
  String get settingsSessionSize => '1回に復習するカード数';

  @override
  String get settingsMixLabel => '捨てたカードを混ぜる';

  @override
  String settingsMixExample(int total, int mixed) {
    return '$total枚中 $mixed枚';
  }

  @override
  String get settingsWordAddSection => '単語の追加';

  @override
  String get settingsNotificationsSection => '通知';

  @override
  String get settingsReminderMaster => '単語の通知';

  @override
  String get settingsAddSlot => '通知の時間帯';

  @override
  String settingsWeeklyCount(int count) {
    return '週$count回';
  }

  @override
  String reminderCardCount(int count) {
    return '$count枚';
  }

  @override
  String get settingsPronunciationSection => '発音';

  @override
  String get settingsAccent => 'アクセント';

  @override
  String get settingsVoice => '声';

  @override
  String get settingsVoiceDefault => '標準';

  @override
  String get settingsSpeed => '速さ';

  @override
  String get settingsSpeedSlow => 'ゆっくり';

  @override
  String get settingsSpeedNormal => 'ふつう';

  @override
  String get settingsSpeedFast => '速く';

  @override
  String get settingsRecorded => '単語は人の録音で';

  @override
  String get settingsRecordedHelp => '録音がなければ声で読む';

  @override
  String get settingsAbout => '情報 · 出典';

  @override
  String get settingsPrivacy => 'プライバシーポリシー';

  @override
  String get aboutDataSources => 'データの出典';

  @override
  String get aboutUseMeanings => '意味 · 辞書の例文';

  @override
  String get aboutUseOnline => 'オンライン辞書';

  @override
  String get aboutUseExamples => '訳付きの例文';

  @override
  String get aboutUseRecordings => '単語の発音録音';

  @override
  String get aboutApp => 'アプリ';

  @override
  String get aboutVersion => 'バージョン';

  @override
  String get aboutLicenses => 'オープンソースライセンス';

  @override
  String reminderPerDayTotal(int times, int cards) {
    return '1日$times回 · $cards枚';
  }

  @override
  String settingsPackDownloading(String size) {
    return '例文の訳をダウンロード中 · $size';
  }

  @override
  String settingsPackReady(String size) {
    return '例文の訳 ダウンロード済み · $size';
  }

  @override
  String get settingsPackFailed => '例文の訳をダウンロードできませんでした';

  @override
  String get settingsPackRetry => '再試行';

  @override
  String get settingsExampleDataSection => '例文データ';

  @override
  String get settingsExampleData => '例文の訳をダウンロード';

  @override
  String get settingsPackNone => '未ダウンロード';

  @override
  String get settingsPackNotNeeded => '英語は訳が不要です';

  @override
  String settingsPackVersion(int version, String size) {
    return 'ダウンロード済み · v$version · $size';
  }

  @override
  String get settingsPackUpdate => 'アップデートを確認';

  @override
  String settingsPackUpToDate(int version) {
    return '最新版です (v$version)';
  }

  @override
  String settingsPackUpdated(int version) {
    return 'v$versionに更新しました';
  }

  @override
  String get examplePromptTitle => '例文の訳をダウンロードしますか？';

  @override
  String examplePromptBody(String language, String size) {
    return '英語例文の$language訳をダウンロードして端末に保存します$size。設定の「例文データ」からいつでも変更できます。';
  }

  @override
  String get examplePromptAccept => 'ダウンロード';

  @override
  String get examplePromptDecline => '今はしない';

  @override
  String get wordAddPosLabel => '品詞';

  @override
  String get wordAddPosUnknown => '不明';

  @override
  String get homeQuickGuessFromMeaning => '意味から単語を当てる';

  @override
  String get wordFoundExample => '見つかった例文';

  @override
  String get wordAddFoundExample => '例文に追加';

  @override
  String wordbookFoundExamples(int count) {
    return '例文 $count件 見つかりました';
  }

  @override
  String get wordAddScanExample => '写真から例文を取り込む';

  @override
  String get wordScanCamera => 'カメラで撮る';

  @override
  String get wordScanGallery => 'アルバムから選ぶ';

  @override
  String get wordScanFailed => '写真の文字を読み取れませんでした';

  @override
  String wordScanNoSentence(String term) {
    return '写真に「$term」を含む文が見つかりませんでした';
  }

  @override
  String get exampleSourcePhoto => '自分の写真';

  @override
  String wordScanAdded(int count) {
    return '写真から$count文を取り込みました';
  }

  @override
  String homeNewReviewBreakdown(int fresh, int review) {
    return '新規 $fresh · 復習 $review';
  }

  @override
  String get settingsAnswerStyle => '出題方式';

  @override
  String get settingsAnswerInput => '空欄に入力';

  @override
  String get settingsAnswerChoice => '4択から選ぶ';

  @override
  String get settingsAnswerHelp => 'ホームの「スタート」で復習するときの出題方式です。';

  @override
  String get sampleWelcomeMeaning => 'ようこそ、いらっしゃい';

  @override
  String get sampleWelcomeExample1 => 'Vocab with Examplesへようこそ！';

  @override
  String get sampleWelcomeExample2 => 'みんな、おかえりなさい。';

  @override
  String get homeAddCardHint => '英単語を入力すると、意味と例文を探してカードにします';
}
