// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Vocab with Examples';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonConfirm => 'OK';

  @override
  String get commonLoading => 'Chargement';

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ko': 'Coréen',
      'ja': 'Japonais',
      'zh': 'Chinois',
      'es': 'Espagnol',
      'fr': 'Français',
      'de': 'Allemand',
      'pt': 'Portugais',
      'vi': 'Vietnamien',
      'th': 'Thaï',
      'id': 'Indonésien',
      'en': 'Anglais',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'lun.',
      'd2': 'mar.',
      'd3': 'mer.',
      'd4': 'jeu.',
      'd5': 'ven.',
      'd6': 'sam.',
      'd7': 'dim.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get wordAddWord => 'Ajouter un mot';

  @override
  String get wordEditWord => 'Modifier le mot';

  @override
  String get wordExamples => 'Exemples';

  @override
  String wordExampleSource(String source) {
    return 'Source : $source';
  }

  @override
  String wordPartOfSpeech(String pos, String value) {
    String _temp0 = intl.Intl.selectLogic(pos, {
      'noun': 'Nom',
      'verb': 'Verbe',
      'adjective': 'Adjectif',
      'adverb': 'Adverbe',
      'pronoun': 'Pronom',
      'preposition': 'Préposition',
      'conjunction': 'Conjonction',
      'interjection': 'Interjection',
      'article': 'Article',
      'determiner': 'Déterminant',
      'phrasalVerb': 'Verbe à particule',
      'idiom': 'Expression',
      'phrase': 'Locution',
      'other': '$value',
    });
    return '$_temp0';
  }

  @override
  String get wordEditTermRequired => 'Saisissez d’abord un mot anglais.';

  @override
  String wordEditNoExamplesFound(String term) {
    return 'Aucun exemple trouvé pour « $term ».';
  }

  @override
  String get wordEditExamplesAlreadyAdded =>
      'Tous les exemples trouvés ont déjà été ajoutés.';

  @override
  String wordEditExamplesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exemples ajoutés.',
      one: '$count exemple ajouté.',
    );
    return '$_temp0';
  }

  @override
  String wordEditExamplesFetchFailed(String error) {
    return 'Impossible de récupérer les exemples : $error';
  }

  @override
  String get wordEditTermAndMeaningRequired =>
      'Saisissez un mot et au moins un sens.';

  @override
  String get wordEditSaveFailed =>
      'Échec de l’enregistrement. Veuillez réessayer.';

  @override
  String get wordEditSectionTerm => 'Mot';

  @override
  String get wordEditSectionMeaning => 'Sens et prononciation';

  @override
  String get wordEditPhonetic => 'Phonétique';

  @override
  String get wordEditSearching => 'Recherche';

  @override
  String get wordEditFetchExamples => 'Trouver des exemples';

  @override
  String get wordEditAddManually => 'Ajouter manuellement';

  @override
  String get wordEditOptional => 'Facultatif';

  @override
  String wordEditExampleNumber(int index) {
    return 'Exemple $index';
  }

  @override
  String get wordEditDeleteExample => 'Supprimer l’exemple';

  @override
  String get wordEditSentence => 'Phrase en anglais';

  @override
  String wordEditTranslationLabel(String language) {
    return 'Traduction ($language)';
  }

  @override
  String get wordEditTermLabel => 'Mot *';

  @override
  String get wordEditTermHint =>
      'Choisissez un mot enregistré pour remplir automatiquement ses sens et ses exemples.';

  @override
  String get wordEditPartOfSpeech => 'Classe grammaticale';

  @override
  String get wordEditPartOfSpeechNone => 'Aucune';

  @override
  String get wordEditManualExampleTitle => 'Ajouter un exemple manuellement';

  @override
  String get wordEditSentenceRequiredLabel => 'Phrase en anglais *';

  @override
  String get wordEditSentenceRequired => 'Saisissez une phrase en anglais.';

  @override
  String wordEditPickerTitle(String term) {
    return 'Exemples pour « $term »';
  }

  @override
  String get wordEditPickerDescription =>
      'Choisissez les exemples à ajouter. Vous pouvez saisir la traduction des phrases qui n’en ont pas.';

  @override
  String wordEditNoTranslation(String language) {
    return 'Pas de traduction ($language)';
  }

  @override
  String get wordEditPickerAttribution => 'Exemples de Tatoeba · CC BY 2.0 FR';

  @override
  String wordEditAddSelectedExamples(int count) {
    return 'Ajouter la sélection ($count)';
  }

  @override
  String get wordCreateLoadFailed => 'Échec du chargement. Veuillez réessayer.';

  @override
  String get wordCreateSectionTitle => 'Saisir un mot';

  @override
  String get wordCreateWordbook => 'Carnet';

  @override
  String get wordCreateNoWordbook => 'Aucun carnet';

  @override
  String get wordCreateReload => 'Recharger';

  @override
  String get wordCreateTermLabel => 'Mot';

  @override
  String get wordCreateLookingUp => 'Recherche';

  @override
  String get wordCreateAutoInputSettings => 'Saisie automatique';

  @override
  String get wordCreateMeaningsOn => 'Sens : oui';

  @override
  String get wordCreateMeaningsOff => 'Sens : non';

  @override
  String get wordCreateExamplesOn => 'Exemples : oui';

  @override
  String get wordCreateExamplesOff => 'Exemples : non';

  @override
  String get wordCreateCollapse => 'Réduire';

  @override
  String get wordCreateExpand => 'Développer';

  @override
  String get wordCreateAutoMeanings => 'Sens automatiques';

  @override
  String get wordCreateAutoExamples => 'Exemples automatiques';

  @override
  String get wordDetailDictionaryMeaningsAdded =>
      'Les sens sélectionnés ont été ajoutés.';

  @override
  String get wordDetailTitle => 'Détails du mot';

  @override
  String get wordDetailFavorite => 'Ajouter aux favoris';

  @override
  String get wordDetailUnfavorite => 'Retirer des favoris';

  @override
  String get wordDetailAccentUs => 'Américain';

  @override
  String get wordDetailAccentUk => 'Britannique';

  @override
  String get wordDetailMyMeanings => 'Mes sens enregistrés';

  @override
  String get wordDetailListenExample => 'Écouter l’exemple';

  @override
  String get wordDetailGoogleTranslate => 'Google Traduction';

  @override
  String get meaningFieldsLabel => 'Sens';

  @override
  String get meaningFieldsLabelRequired => 'Sens *';

  @override
  String meaningFieldsLabelNumbered(int index) {
    return 'Sens $index';
  }

  @override
  String meaningFieldsRemove(int index) {
    return 'Retirer le sens $index';
  }

  @override
  String get meaningFieldsAdd => 'Ajouter un sens';

  @override
  String get meaningFieldsEmptyError => 'Saisissez au moins un sens.';

  @override
  String get meaningFieldsEditTitle => 'Modifier les sens';

  @override
  String get dictLookupAddFailed =>
      'Impossible d’ajouter les sens. Veuillez réessayer.';

  @override
  String get dictLookupButton => 'Sens du dictionnaire';

  @override
  String dictLookupTitle(String term) {
    return '$term · Dictionnaire';
  }

  @override
  String dictLookupFallbackNotice(String language) {
    return 'Les entrées sans traduction ($language) affichent la définition anglaise.';
  }

  @override
  String get dictLookupLoadFailed =>
      'Impossible de charger les sens du dictionnaire.';

  @override
  String get dictLookupNoResults =>
      'Aucun sens trouvé dans le dictionnaire.\nVérifiez l’orthographe ou essayez un autre dictionnaire.';

  @override
  String get dictLookupAlreadyAdded => 'Ajouté';

  @override
  String dictLookupAddSelected(int count) {
    return 'Ajouter la sélection ($count)';
  }

  @override
  String get dictLookupLinkFailed =>
      'Impossible d’ouvrir le lien du dictionnaire.';

  @override
  String get dictLinksNaver => 'Naver (anglais–coréen)';

  @override
  String get dictLinksOxford => 'Oxford (anglais–anglais)';

  @override
  String get dictLinksOpenFailed =>
      'Impossible d’ouvrir le dictionnaire. Veuillez réessayer.';

  @override
  String get dictLinksTitle => 'Voir dans les dictionnaires';

  @override
  String wordbookError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get wordbookShareCode => 'Code de partage';

  @override
  String wordbookDeleteTitle(String name) {
    return 'Supprimer « $name »';
  }

  @override
  String get wordbooksTitle => 'Mes carnets';

  @override
  String get wordbooksNew => 'Nouveau carnet';

  @override
  String get wordbooksEmpty =>
      'Aucun carnet pour l’instant.\nTouchez + pour en créer un.';

  @override
  String get wordbooksCreate => 'Créer';

  @override
  String get wordbooksNameLabel => 'Nom du carnet';

  @override
  String get wordbooksTagsLabel => 'Étiquettes';

  @override
  String get wordbooksTagsHint =>
      'TOEIC, conversation courante (séparées par des virgules)';

  @override
  String wordbooksWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mots',
      one: '$count mot',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksMenu => 'Menu du carnet';

  @override
  String get wordbooksMenuRename => 'Modifier le nom et les étiquettes';

  @override
  String get wordbooksShareSettings => 'Partage et visibilité';

  @override
  String get wordbooksMenuDelete => 'Supprimer le carnet';

  @override
  String get wordbooksEditTitle => 'Modifier le carnet';

  @override
  String get wordbooksShareLoginRequired =>
      'Connectez-vous pour partager ou publier vos carnets.';

  @override
  String get wordbooksVisibilityPrivate => 'Privé';

  @override
  String get wordbooksVisibilityShared => 'Par code';

  @override
  String get wordbooksVisibilityPublic => 'Public';

  @override
  String get wordbooksVisibilityPrivateDesc => 'Visible par vous uniquement.';

  @override
  String get wordbooksVisibilitySharedDesc =>
      'Toute personne ayant le code peut copier ce carnet.';

  @override
  String get wordbooksVisibilityPublicDesc =>
      'Affiché dans l’onglet Explorer, où tout le monde peut le copier.';

  @override
  String get wordbooksCopyCode => 'Copier le code';

  @override
  String get wordbooksCodeCopied => 'Code de partage copié.';

  @override
  String wordbooksDeleteWithWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Les $count mots de ce carnet seront aussi supprimés.\nUn carnet supprimé ne peut pas être restauré.',
      one:
          '$count mot de ce carnet sera aussi supprimé.\nUn carnet supprimé ne peut pas être restauré.',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksDeleteEmpty =>
      'Un carnet supprimé ne peut pas être restauré.';

  @override
  String get wordbookDetailEmpty =>
      'Aucun mot pour l’instant.\nTouchez le bouton Ajouter un mot.';

  @override
  String wordbookDetailWordDeleted(String term) {
    return '« $term » supprimé';
  }

  @override
  String get wordbookDetailUndo => 'Annuler';

  @override
  String get wordbookDetailEditWholeWord => 'Modifier tout le mot';

  @override
  String get wordbookDetailEditWord => 'Modifier le mot';

  @override
  String get wordbookDetailFavorite => 'Favori';

  @override
  String get wordbookDetailUnfavorite => 'Retirer des favoris';

  @override
  String get wordbookDetailEditMeaning => 'Modifier le sens';

  @override
  String get wordbookDetailEditAll => 'Tout modifier';

  @override
  String get wordbookDetailStatusFresh => 'Nouveau';

  @override
  String get wordbookDetailStatusLearning => 'En cours';

  @override
  String get wordbookDetailStatusCompleted => 'Maîtrisé';

  @override
  String get wordbookDetailDeleteWordConfirm => 'Supprimer ce mot ?';

  @override
  String get wordbookDetailReleaseToDelete => 'Relâchez pour supprimer';

  @override
  String get exploreTitle => 'Explorer';

  @override
  String get exploreCodeNotFound =>
      'Aucun carnet partagé ne correspond à ce code.';

  @override
  String get exploreImportFailed =>
      'Échec de l’importation. Vérifiez votre connexion réseau.';

  @override
  String exploreCopyTitle(String title) {
    return 'Copier « $title »';
  }

  @override
  String exploreCopyConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Copier $count mots dans vos carnets ?\nLa progression repartira de zéro.',
      one:
          'Copier $count mot dans vos carnets ?\nLa progression repartira de zéro.',
    );
    return '$_temp0';
  }

  @override
  String get exploreCopy => 'Copier';

  @override
  String exploreImported(String title) {
    return '« $title » importé.';
  }

  @override
  String get exploreLoggedOutHeadline => 'Découvrez de\nnouveaux carnets';

  @override
  String get exploreLoginRequired =>
      'Connectez-vous pour explorer les carnets partagés.';

  @override
  String get exploreGoToLogin => 'Se connecter';

  @override
  String get exploreSupabaseRequired =>
      'Disponible après la connexion à Supabase.';

  @override
  String get exploreImportByCode => 'Importer avec un code';

  @override
  String get exploreCodeHint => 'Collez le code reçu';

  @override
  String get exploreImport => 'Importer';

  @override
  String get exploreCodeHelp =>
      'Pour partager un carnet, copiez son code dans Partage et visibilité, depuis le menu du carnet.';

  @override
  String get explorePublicWordbooks => 'Carnets publics';

  @override
  String get explorePublicLoadFailed =>
      'Impossible de charger les carnets publics.\nTirez vers le bas pour actualiser.';

  @override
  String get explorePublicEmpty => 'Aucun carnet public pour l’instant.';

  @override
  String get loginMigrateTitle => 'Importer les carnets locaux';

  @override
  String loginMigrateConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Copier dans le cloud $count carnets créés sur cet appareil ?\nLes carnets déjà présents dans le cloud seront ignorés.',
      one:
          'Copier dans le cloud $count carnet créé sur cet appareil ?\nLes carnets déjà présents dans le cloud seront ignorés.',
    );
    return '$_temp0';
  }

  @override
  String get loginLater => 'Plus tard';

  @override
  String get loginImport => 'Importer';

  @override
  String loginMigrated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count carnets importés.',
      one: '$count carnet importé.',
    );
    return '$_temp0';
  }

  @override
  String get loginAlreadyInCloud => 'Tous les carnets sont déjà dans le cloud.';

  @override
  String get loginErrorInvalidCredentials =>
      'E-mail ou mot de passe incorrect.';

  @override
  String get loginErrorUserExists =>
      'Cet e-mail est déjà inscrit. Veuillez vous connecter.';

  @override
  String get loginErrorWeakPassword =>
      'Mot de passe trop court. Utilisez au moins 6 caractères.';

  @override
  String get loginErrorEmailNotConfirmed =>
      'Veuillez confirmer votre e-mail. Consultez votre boîte de réception.';

  @override
  String get loginErrorRateLimit =>
      'Trop de tentatives. Veuillez réessayer plus tard.';

  @override
  String loginErrorGeneric(String message) {
    return 'Échec de la connexion. ($message)';
  }

  @override
  String get loginErrorNetwork =>
      'Impossible de traiter la demande. Vérifiez votre connexion réseau et réessayez.';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginTagline =>
      'Apprenez facilement avec des exemples, régulièrement avec des rappels';

  @override
  String get loginEmail => 'E-mail';

  @override
  String get loginPassword => 'Mot de passe';

  @override
  String get loginSignUpWithEmail => 'S’inscrire avec un e-mail';

  @override
  String get loginContinueWithGoogle => 'Continuer avec Google';

  @override
  String get navHome => 'Accueil';

  @override
  String get navWordbooks => 'Carnets';

  @override
  String get navSettings => 'Réglages';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsTranslationSection => 'Traduction des sens et exemples';

  @override
  String get settingsTranslationHelp =>
      'Le mode Auto suit la langue et la région de votre appareil. La traduction s’applique aux sens et aux exemples des mots que vous recherchez désormais. Les sens sans traduction affichent la définition anglaise, et les traductions des exemples restent vides. Le contenu déjà enregistré ne change pas automatiquement.';

  @override
  String get settingsAppLanguageNote =>
      'L’application s’affiche aussi dans cette langue. Les langues pour lesquelles l’application n’est pas traduite s’affichent en anglais.';

  @override
  String get settingsReviewMixSection => 'Mélange des révisions';

  @override
  String get settingsReviewMixLabel => 'Réintégrer des mots déjà appris';

  @override
  String settingsReviewMixHelp(int total, int mixed) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'questions',
      one: 'question',
    );
    return 'Ajoute cette proportion de mots maîtrisés aux séries de révision pour renforcer la mémoire à long terme. (ex. : $mixed sur $total $_temp0)';
  }

  @override
  String get settingsReminderSection => 'Rappels · Révision';

  @override
  String get settingsReminderToggle => 'Recevoir des rappels de révision';

  @override
  String get settingsReminderOff => 'Les rappels sont désactivés.';

  @override
  String get settingsReminderNoActive => 'Aucune plage de rappel activée.';

  @override
  String settingsReminderSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rappels',
      one: '$count rappel',
    );
    return 'Chaque semaine · $_temp0 par semaine. Les mots en cours d’apprentissage sont inclus dans l’ordre de leur prochaine révision.';
  }

  @override
  String settingsReminderCapped(int limit) {
    return 'Certains rappels tardifs sont ignorés, car ils dépassent la limite de $limit notifications programmées de l’appareil.';
  }

  @override
  String get settingsTtsSection => 'Prononciation · TTS';

  @override
  String get settingsTtsDefault => 'Accent par défaut';

  @override
  String get settingsTtsDefaultHelp =>
      'Choisissez l’accent utilisé pour lire les mots et les exemples.';

  @override
  String get settingsTtsUs => 'Américain';

  @override
  String get settingsTtsUk => 'Britannique';

  @override
  String get settingsTtsQuality => 'Qualité de la voix';

  @override
  String get settingsTtsQualityValue => 'TTS de l’appareil (gratuit)';

  @override
  String get settingsTatoebaCredit =>
      'Exemples externes : Tatoeba · CC BY 2.0 FR';

  @override
  String get reminderEveryDay => 'Tous les jours';

  @override
  String get reminderNoWeekdays => 'Aucun jour';

  @override
  String get reminderWeekdays => 'En semaine';

  @override
  String get reminderWeekends => 'Le week-end';

  @override
  String reminderIntervalMinutes(int minutes) {
    return 'Toutes les $minutes min';
  }

  @override
  String reminderIntervalHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Toutes les $hours heures',
      one: 'Toutes les heures',
    );
    return '$_temp0';
  }

  @override
  String reminderIntervalHoursMinutes(int hours, int minutes) {
    return 'Toutes les $hours h $minutes min';
  }

  @override
  String get reminderAddSchedule => 'Ajouter une plage de rappel';

  @override
  String get reminderEditSchedule => 'Modifier la plage de rappel';

  @override
  String get reminderStart => 'Début';

  @override
  String get reminderEnd => 'Fin';

  @override
  String get reminderCrossesMidnight =>
      'Si l’heure de fin précède l’heure de début, les rappels continuent après minuit jusqu’à l’heure de fin le lendemain.';

  @override
  String get reminderWeekdaysTitle => 'Jours de rappel';

  @override
  String get reminderWeekdaysRequired => 'Sélectionnez au moins un jour.';

  @override
  String get reminderInterval => 'Fréquence des rappels';

  @override
  String get reminderWordsPerAlert => 'Par rappel';

  @override
  String get reminderDecreaseWords => 'Moins de mots';

  @override
  String get reminderIncreaseWords => 'Plus de mots';

  @override
  String reminderWordCount(int count) {
    return '$count';
  }

  @override
  String reminderWordCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mots',
      one: '$count mot',
    );
    return '$_temp0';
  }

  @override
  String reminderTimesPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois par jour',
      one: '$count fois par jour',
    );
    return '$_temp0';
  }

  @override
  String reminderPreview(String days, int count, String times) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois',
      one: '$count fois',
    );
    return '$days, $_temp0 · $times';
  }

  @override
  String get translationLanguageLabel => 'Langue de traduction';

  @override
  String translationLanguageAuto(String language) {
    return 'Auto · $language';
  }

  @override
  String get notificationChannelName => 'Notifications de mots';

  @override
  String get notificationChannelDescription =>
      'Affiche des mots et leur sens en notification aux jours et heures choisis';

  @override
  String get notificationTitleDefault => 'Mot du moment';

  @override
  String notificationTitleWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vos $count mots du jour',
      one: 'Votre mot du jour',
    );
    return '$_temp0';
  }

  @override
  String get notificationBodyDefault =>
      'Ajoutez des mots : ils s\'afficheront ici avec leur sens.';

  @override
  String homeError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get homeGreeting => 'On apprend quelques mots ?';

  @override
  String get homeTodayStudy => 'Aujourd’hui';

  @override
  String homeTotalWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mots au total',
      one: '$count mot au total',
    );
    return '$_temp0';
  }

  @override
  String get homeAccuracy => 'Réussite';

  @override
  String homeCompletedWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maîtrisés',
      one: '$count maîtrisé',
    );
    return '$_temp0';
  }

  @override
  String get homeWordOfTheDay => 'Mot du jour';

  @override
  String get homeQuickStart => 'Démarrage rapide';

  @override
  String get homeQuickGuessWord => 'Texte à trous · écrire';

  @override
  String get homeQuickFillBlank => 'Texte à trous · choisir';

  @override
  String get homeQuickBrowseWordbooks => 'Parcourir les carnets';

  @override
  String get homeCreateWordbookFirst => 'Créez d’abord un carnet.';

  @override
  String get homeEditWord => 'Modifier le mot';

  @override
  String get homeListenWord => 'Écouter le mot';

  @override
  String get homeSeeDetails => 'Voir les détails';

  @override
  String get homeReviewAllDone => 'Révisions du jour\nterminées !';

  @override
  String homeReviewWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mots\nvous attendent',
      one: '$count mot\nvous attend',
    );
    return '$_temp0';
  }

  @override
  String homeCompletedBadge(int count) {
    return '$count\nmaîtrisés';
  }

  @override
  String homeReviewBreakdown(int due, int mixed) {
    return 'Nouveaux/révision $due · Mélange $mixed';
  }

  @override
  String get homeStart => 'Commencer';

  @override
  String get reviewNoExample =>
      '(Pas d’exemple — saisissez le mot d’après son sens)';

  @override
  String get reviewTitle => 'Révision par l’exemple';

  @override
  String get reviewEmpty => 'Aucune carte aujourd\'hui';

  @override
  String get reviewFillBlankTitle => 'Phrase à trou';

  @override
  String get reviewChoiceInstruction =>
      'Choisissez le mot qui correspond à l’exemple et au sens';

  @override
  String get reviewInputInstruction =>
      'Saisissez le mot qui correspond à l’exemple et au sens';

  @override
  String reviewOtherExample(int current, int total) {
    return 'Autre exemple  $current/$total';
  }

  @override
  String get reviewDontKnow => 'Je ne sais pas';

  @override
  String get reviewInputHint => 'Saisissez le mot';

  @override
  String reviewHint(String hint) {
    return 'Indice : $hint';
  }

  @override
  String get reviewCheckAnswer => 'Vérifier';

  @override
  String get reviewCorrect => 'Bonne réponse !';

  @override
  String get reviewWrongAnswerIs => 'Pas tout à fait. La réponse est';

  @override
  String reviewSource(String source) {
    return 'Source : $source';
  }

  @override
  String get reviewMixedNotice => 'Un mot maîtrisé revient pour une révision';

  @override
  String get reviewSummaryTitle => 'Révision terminée';

  @override
  String get reviewSummaryDone => 'Vous avez terminé la révision';

  @override
  String reviewSummaryScore(int correct, int total) {
    return '$correct bonnes réponses sur $total';
  }

  @override
  String get reviewGoHome => 'Retour à l’accueil';

  @override
  String get dictionaryRateLimited =>
      'Les recherches dans le dictionnaire sont temporairement limitées. Réessayez dans un instant.';

  @override
  String get dictionaryConnectionFailed =>
      'Impossible de joindre le dictionnaire. Réessayez dans un instant.';

  @override
  String get dictionaryTimeout =>
      'Le dictionnaire met trop de temps à répondre. Veuillez réessayer.';

  @override
  String get dictionaryLoadFailed =>
      'Impossible de charger les sens du dictionnaire. Vérifiez votre connexion Internet et réessayez.';

  @override
  String get draftDictionaryUnavailable =>
      'Impossible de joindre le dictionnaire. Saisissez le sens vous-même ou relancez la recherche.';

  @override
  String get draftMeaningNotFound =>
      'Aucun sens trouvé. Saisissez-le vous-même ou cherchez dans le dictionnaire.';

  @override
  String draftNoTranslationUsedEnglish(String language) {
    return 'Le dictionnaire n’a pas de traduction ($language), des définitions anglaises ont donc été utilisées. Vous pouvez changer la langue de traduction dans Réglages.';
  }

  @override
  String draftSomeUsedEnglish(String language) {
    return 'Les entrées sans traduction ($language) ont été complétées par des définitions anglaises.';
  }

  @override
  String get draftExamplesRetry =>
      'Vous pouvez recharger des exemples avec « Trouver des exemples » ci-dessous.';

  @override
  String get speakListen => 'Écouter';

  @override
  String get speakListenExample => 'Écouter l’exemple';

  @override
  String get adPreview => 'Aperçu de l’annonce';

  @override
  String get addWordButton => 'Ajouter un mot';

  @override
  String get wordCreateExampleTranslations => 'Inclure les traductions';

  @override
  String get wordCreateNoExampleTranslations => 'Sans traduction';

  @override
  String get homeRemainingCards => 'Cartes restantes';

  @override
  String homeTodayCards(int count) {
    return '$count à réviser aujourd\'hui';
  }

  @override
  String get homeStartButton => 'Commencer';

  @override
  String get homeNoCardsToday => 'Aucune carte aujourd\'hui';

  @override
  String reviewRemaining(int count) {
    return 'Reste $count';
  }

  @override
  String get reviewKeep => 'Garder';

  @override
  String get reviewDiscard => 'Jeter';

  @override
  String reviewDoneTitle(int count) {
    return '$count cartes faites';
  }

  @override
  String wordbooksCardsLeft(int count) {
    return 'restantes · $count au total';
  }

  @override
  String get wordbookCardsLeftSuffix => 'restantes';

  @override
  String get wordbookDetailAllDiscarded => 'Plus aucune carte';

  @override
  String wordbookDetailDiscarded(String term) {
    return '\'$term\' jetée';
  }

  @override
  String get wordbookDetailReleaseToDiscard => 'Relâchez pour jeter';

  @override
  String get wordbookAddWordShort => 'Mot';

  @override
  String get discardedTitle => 'Cartes jetées';

  @override
  String get discardedEmpty => 'Rien de jeté';

  @override
  String get discardedRestore => 'Remettre';

  @override
  String get wordAddMeaningSelect => 'Choisir les sens';

  @override
  String get wordAddManualInput => 'Saisir un sens';

  @override
  String get wordAddMeaningLabel => 'Sens';

  @override
  String wordAddExamplesOf(String pos) {
    return 'Exemples : $pos';
  }

  @override
  String wordAddSelectedCount(int count) {
    return '$count choisis';
  }

  @override
  String get wordAddWriteExample => 'Écrire un exemple';

  @override
  String get wordAddSave => 'Ajouter';

  @override
  String get wordAddAlreadyInDeck => 'Déjà dans le paquet';

  @override
  String get wordAddNoResults => 'Absent du dictionnaire';

  @override
  String get wordAddLookupFailed => 'Dictionnaire indisponible';

  @override
  String get wordAddAutoInput => 'Remplissage auto';

  @override
  String get wordAddAutoOff => 'Remplissage auto désactivé';

  @override
  String get wordAddExampleTranslation => 'Traductions';

  @override
  String get wordAddNoExamples =>
      'Aucun exemple trouvé. Vous pouvez ajouter le mot sans exemple.';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get themeSlate => 'Ardoise';

  @override
  String get themeNavy => 'Marine';

  @override
  String get themeBrown => 'Brun';

  @override
  String get themePlum => 'Prune';

  @override
  String get themeCharcoal => 'Anthracite';

  @override
  String get themeCustom => 'Perso';

  @override
  String get themeCustomTitle => 'Thème personnalisé';

  @override
  String get themeBase => 'Fond';

  @override
  String get themePoint => 'Accent';

  @override
  String get themeAutoText => 'La couleur du texte s\'ajuste';

  @override
  String get themeApply => 'Appliquer';

  @override
  String get themeReset => 'Réinitialiser';

  @override
  String get settingsLanguageSection => 'Langue';

  @override
  String get settingsLanguageRow => 'Sens · exemples · appli';

  @override
  String get settingsFollowDevice => 'Selon l\'appareil';

  @override
  String get settingsReviewSection => 'Révision';

  @override
  String get settingsSessionSize => 'Cartes par révision';

  @override
  String get settingsMixLabel => 'Mélanger les cartes jetées';

  @override
  String settingsMixExample(int total, int mixed) {
    return '$mixed sur $total';
  }

  @override
  String get settingsWordAddSection => 'Ajout de mots';

  @override
  String get settingsNotificationsSection => 'Rappels';

  @override
  String get settingsReminderMaster => 'Notifications de mots';

  @override
  String get settingsAddSlot => 'Plage de rappel';

  @override
  String settingsWeeklyCount(int count) {
    return '$count fois par semaine';
  }

  @override
  String reminderCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes',
      one: '1 carte',
    );
    return '$_temp0';
  }

  @override
  String get settingsPronunciationSection => 'Prononciation';

  @override
  String get settingsAccent => 'Accent';

  @override
  String get settingsVoice => 'Voix';

  @override
  String get settingsVoiceDefault => 'Par défaut';

  @override
  String get settingsSpeed => 'Vitesse';

  @override
  String get settingsSpeedSlow => 'Lente';

  @override
  String get settingsSpeedNormal => 'Normale';

  @override
  String get settingsSpeedFast => 'Rapide';

  @override
  String get settingsRecorded => 'Enregistrements humains pour les mots';

  @override
  String get settingsRecordedHelp => 'Sinon, utilise la voix';

  @override
  String get settingsAbout => 'À propos · sources';

  @override
  String get settingsPrivacy => 'Politique de confidentialité';

  @override
  String get aboutDataSources => 'Sources des données';

  @override
  String get aboutUseMeanings => 'Sens · exemples du dictionnaire';

  @override
  String get aboutUseOnline => 'Dictionnaire en ligne';

  @override
  String get aboutUseExamples => 'Exemples traduits';

  @override
  String get aboutUseRecordings => 'Enregistrements des mots';

  @override
  String get aboutApp => 'Appli';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutLicenses => 'Licences open source';

  @override
  String reminderPerDayTotal(int times, int cards) {
    return '$times par jour · $cards cartes';
  }

  @override
  String settingsPackDownloading(String size) {
    return 'Téléchargement des traductions d\'exemples · $size';
  }

  @override
  String settingsPackReady(String size) {
    return 'Traductions d\'exemples prêtes · $size';
  }

  @override
  String get settingsPackFailed => 'Impossible de télécharger les traductions';

  @override
  String get settingsPackRetry => 'Réessayer';

  @override
  String get settingsExampleDataSection => 'Données d\'exemples';

  @override
  String get settingsExampleData => 'Télécharger les traductions d\'exemples';

  @override
  String get settingsPackNone => 'Non téléchargé';

  @override
  String get settingsPackNotNeeded => 'Pas de traduction pour l\'anglais';

  @override
  String settingsPackVersion(int version, String size) {
    return 'Téléchargé · v$version · $size';
  }

  @override
  String get settingsPackUpdate => 'Rechercher des mises à jour';

  @override
  String settingsPackUpToDate(int version) {
    return 'À jour (v$version)';
  }

  @override
  String settingsPackUpdated(int version) {
    return 'Mis à jour en v$version';
  }

  @override
  String get examplePromptTitle => 'Télécharger les traductions d\'exemples ?';

  @override
  String examplePromptBody(String language, String size) {
    return 'Les traductions en $language des exemples anglais seront téléchargées$size. Modifiable dans Réglages › Données d\'exemples.';
  }

  @override
  String get examplePromptAccept => 'Télécharger';

  @override
  String get examplePromptDecline => 'Pas maintenant';

  @override
  String get wordAddPosLabel => 'Nature';

  @override
  String get wordAddPosUnknown => 'Inconnue';

  @override
  String get homeQuickGuessFromMeaning => 'Trouver le mot d\'après le sens';

  @override
  String get wordFoundExample => 'Exemple trouvé';

  @override
  String get wordAddFoundExample => 'Ajouter l\'exemple';

  @override
  String wordbookFoundExamples(int count) {
    return '$count exemples trouvés';
  }

  @override
  String get wordAddScanExample => 'Exemples depuis une photo';

  @override
  String get wordScanCamera => 'Prendre une photo';

  @override
  String get wordScanGallery => 'Choisir dans la galerie';

  @override
  String get wordScanFailed => 'Impossible de lire le texte de la photo';

  @override
  String wordScanNoSentence(String term) {
    return 'Aucune phrase avec « $term » dans la photo';
  }

  @override
  String get exampleSourcePhoto => 'Ma photo';

  @override
  String wordScanAdded(int count) {
    return '$count phrases ajoutées depuis la photo';
  }

  @override
  String homeNewReviewBreakdown(int fresh, int review) {
    return 'Nouvelles $fresh · Révision $review';
  }

  @override
  String get settingsAnswerStyle => 'Type de réponse';

  @override
  String get settingsAnswerInput => 'Écrire le mot';

  @override
  String get settingsAnswerChoice => 'Choisir parmi 4';

  @override
  String get settingsAnswerHelp =>
      'Utilisé quand vous révisez avec Commencer sur l\'accueil.';

  @override
  String get sampleWelcomeMeaning => 'bienvenue';

  @override
  String get sampleWelcomeExample1 => 'Bienvenue dans Vocab with Examples !';

  @override
  String get sampleWelcomeExample2 => 'Bon retour à tous.';

  @override
  String get homeAddCardHint =>
      'Tapez un mot anglais : on trouve sens et exemples pour en faire une carte';
}
