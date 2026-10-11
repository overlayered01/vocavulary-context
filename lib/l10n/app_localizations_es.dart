// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Vocab with Examples';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonAdd => 'Agregar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonNext => 'Siguiente';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonConfirm => 'Aceptar';

  @override
  String get commonLoading => 'Cargando';

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ko': 'Coreano',
      'ja': 'Japonés',
      'zh': 'Chino',
      'es': 'Español',
      'fr': 'Francés',
      'de': 'Alemán',
      'pt': 'Portugués',
      'vi': 'Vietnamita',
      'th': 'Tailandés',
      'id': 'Indonesio',
      'en': 'Inglés',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'lun',
      'd2': 'mar',
      'd3': 'mié',
      'd4': 'jue',
      'd5': 'vie',
      'd6': 'sáb',
      'd7': 'dom',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get wordAddWord => 'Agregar palabra';

  @override
  String get wordEditWord => 'Editar palabra';

  @override
  String get wordExamples => 'Ejemplos';

  @override
  String wordExampleSource(String source) {
    return 'Fuente: $source';
  }

  @override
  String wordPartOfSpeech(String pos, String value) {
    String _temp0 = intl.Intl.selectLogic(pos, {
      'noun': 'Sustantivo',
      'verb': 'Verbo',
      'adjective': 'Adjetivo',
      'adverb': 'Adverbio',
      'pronoun': 'Pronombre',
      'preposition': 'Preposición',
      'conjunction': 'Conjunción',
      'interjection': 'Interjección',
      'article': 'Artículo',
      'determiner': 'Determinante',
      'phrasalVerb': 'Verbo frasal',
      'idiom': 'Modismo',
      'other': '$value',
    });
    return '$_temp0';
  }

  @override
  String get wordEditTermRequired => 'Primero escribe una palabra en inglés.';

  @override
  String wordEditNoExamplesFound(String term) {
    return 'No se encontraron ejemplos para “$term”.';
  }

  @override
  String get wordEditExamplesAlreadyAdded =>
      'Ya se agregaron todos los ejemplos encontrados.';

  @override
  String wordEditExamplesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se agregaron $count ejemplos.',
      one: 'Se agregó $count ejemplo.',
    );
    return '$_temp0';
  }

  @override
  String wordEditExamplesFetchFailed(String error) {
    return 'No se pudieron obtener ejemplos: $error';
  }

  @override
  String get wordEditTermAndMeaningRequired =>
      'Escribe una palabra y al menos un significado.';

  @override
  String get wordEditSaveFailed => 'No se pudo guardar. Inténtalo de nuevo.';

  @override
  String get wordEditSectionTerm => 'Palabra';

  @override
  String get wordEditSectionMeaning => 'Significado y pronunciación';

  @override
  String get wordEditPhonetic => 'Fonética';

  @override
  String get wordEditSearching => 'Buscando';

  @override
  String get wordEditFetchExamples => 'Obtener ejemplos';

  @override
  String get wordEditAddManually => 'Agregar a mano';

  @override
  String get wordEditOptional => 'Opcional';

  @override
  String wordEditExampleNumber(int index) {
    return 'Ejemplo $index';
  }

  @override
  String get wordEditDeleteExample => 'Eliminar ejemplo';

  @override
  String get wordEditSentence => 'Oración en inglés';

  @override
  String wordEditTranslationLabel(String language) {
    return 'Traducción ($language)';
  }

  @override
  String get wordEditTermLabel => 'Palabra *';

  @override
  String get wordEditTermHint =>
      'Elige una palabra guardada para completar sus significados y ejemplos automáticamente.';

  @override
  String get wordEditPartOfSpeech => 'Categoría gramatical';

  @override
  String get wordEditPartOfSpeechNone => 'Ninguna';

  @override
  String get wordEditManualExampleTitle => 'Agregar ejemplo a mano';

  @override
  String get wordEditSentenceRequiredLabel => 'Oración en inglés *';

  @override
  String get wordEditSentenceRequired => 'Escribe una oración en inglés.';

  @override
  String wordEditPickerTitle(String term) {
    return 'Ejemplos de “$term”';
  }

  @override
  String get wordEditPickerDescription =>
      'Elige los ejemplos que quieras agregar. Puedes escribir la traducción de las oraciones que no la tengan.';

  @override
  String wordEditNoTranslation(String language) {
    return 'Sin traducción ($language)';
  }

  @override
  String get wordEditPickerAttribution => 'Ejemplos de Tatoeba · CC BY 2.0 FR';

  @override
  String wordEditAddSelectedExamples(int count) {
    return 'Agregar selección ($count)';
  }

  @override
  String get wordCreateLoadFailed => 'No se pudo cargar. Inténtalo de nuevo.';

  @override
  String get wordCreateSectionTitle => 'Escribe una palabra';

  @override
  String get wordCreateWordbook => 'Lista';

  @override
  String get wordCreateNoWordbook => 'No hay listas';

  @override
  String get wordCreateReload => 'Recargar';

  @override
  String get wordCreateTermLabel => 'Palabra';

  @override
  String get wordCreateLookingUp => 'Buscando';

  @override
  String get wordCreateAutoInputSettings => 'Ajustes de autocompletado';

  @override
  String get wordCreateMeaningsOn => 'Significados: sí';

  @override
  String get wordCreateMeaningsOff => 'Significados: no';

  @override
  String get wordCreateExamplesOn => 'Ejemplos: sí';

  @override
  String get wordCreateExamplesOff => 'Ejemplos: no';

  @override
  String get wordCreateCollapse => 'Contraer';

  @override
  String get wordCreateExpand => 'Expandir';

  @override
  String get wordCreateAutoMeanings => 'Autocompletar significados';

  @override
  String get wordCreateAutoExamples => 'Autocompletar ejemplos';

  @override
  String get wordDetailDictionaryMeaningsAdded =>
      'Se agregaron los significados seleccionados.';

  @override
  String get wordDetailTitle => 'Detalles de la palabra';

  @override
  String get wordDetailFavorite => 'Agregar a favoritos';

  @override
  String get wordDetailUnfavorite => 'Quitar de favoritos';

  @override
  String get wordDetailAccentUs => 'Americano';

  @override
  String get wordDetailAccentUk => 'Británico';

  @override
  String get wordDetailMyMeanings => 'Mis significados';

  @override
  String get wordDetailListenExample => 'Escuchar ejemplo';

  @override
  String get wordDetailGoogleTranslate => 'Traductor de Google';

  @override
  String get meaningFieldsLabel => 'Significado';

  @override
  String get meaningFieldsLabelRequired => 'Significado *';

  @override
  String meaningFieldsLabelNumbered(int index) {
    return 'Significado $index';
  }

  @override
  String meaningFieldsRemove(int index) {
    return 'Quitar significado $index';
  }

  @override
  String get meaningFieldsAdd => 'Agregar significado';

  @override
  String get meaningFieldsEmptyError => 'Escribe al menos un significado.';

  @override
  String get meaningFieldsEditTitle => 'Editar significados';

  @override
  String get dictLookupAddFailed =>
      'No se pudieron agregar los significados. Inténtalo de nuevo.';

  @override
  String get dictLookupButton => 'Significados del diccionario';

  @override
  String dictLookupTitle(String term) {
    return '$term · Diccionario';
  }

  @override
  String dictLookupFallbackNotice(String language) {
    return 'Las entradas sin traducción ($language) muestran la definición en inglés.';
  }

  @override
  String get dictLookupLoadFailed =>
      'No se pudieron cargar los significados del diccionario.';

  @override
  String get dictLookupNoResults =>
      'No se encontraron significados en el diccionario.\nRevisa la ortografía o prueba con otro diccionario.';

  @override
  String get dictLookupAlreadyAdded => 'Agregado';

  @override
  String dictLookupAddSelected(int count) {
    return 'Agregar selección ($count)';
  }

  @override
  String get dictLookupLinkFailed =>
      'No se pudo abrir el enlace del diccionario.';

  @override
  String get dictLinksNaver => 'Naver (inglés–coreano)';

  @override
  String get dictLinksOxford => 'Oxford (inglés–inglés)';

  @override
  String get dictLinksOpenFailed =>
      'No se pudo abrir el diccionario. Inténtalo de nuevo.';

  @override
  String get dictLinksTitle => 'Ver más en diccionarios';

  @override
  String wordbookError(String error) {
    return 'Error: $error';
  }

  @override
  String get wordbookShareCode => 'Código para compartir';

  @override
  String wordbookDeleteTitle(String name) {
    return 'Eliminar “$name”';
  }

  @override
  String get wordbooksTitle => 'Mis listas';

  @override
  String get wordbooksNew => 'Nueva lista';

  @override
  String get wordbooksEmpty => 'Aún no hay listas.\nToca + para crear una.';

  @override
  String get wordbooksCreate => 'Crear';

  @override
  String get wordbooksNameLabel => 'Nombre de la lista';

  @override
  String get wordbooksTagsLabel => 'Etiquetas';

  @override
  String get wordbooksTagsHint =>
      'TOEIC, conversación diaria (separadas por comas)';

  @override
  String wordbooksWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palabras',
      one: '$count palabra',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksMenu => 'Menú de la lista';

  @override
  String get wordbooksMenuRename => 'Editar nombre y etiquetas';

  @override
  String get wordbooksShareSettings => 'Compartir y visibilidad';

  @override
  String get wordbooksMenuDelete => 'Eliminar lista';

  @override
  String get wordbooksEditTitle => 'Editar lista';

  @override
  String get wordbooksShareLoginRequired =>
      'Inicia sesión para compartir o publicar listas.';

  @override
  String get wordbooksVisibilityPrivate => 'Privada';

  @override
  String get wordbooksVisibilityShared => 'Con código';

  @override
  String get wordbooksVisibilityPublic => 'Pública';

  @override
  String get wordbooksVisibilityPrivateDesc => 'Solo tú puedes verla.';

  @override
  String get wordbooksVisibilitySharedDesc =>
      'Cualquier persona con el código puede copiar esta lista.';

  @override
  String get wordbooksVisibilityPublicDesc =>
      'Aparece en la pestaña Explorar, donde cualquiera puede copiarla.';

  @override
  String get wordbooksCopyCode => 'Copiar código';

  @override
  String get wordbooksCodeCopied => 'Código copiado.';

  @override
  String wordbooksDeleteWithWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'También se eliminarán las $count palabras de esta lista.\nLas listas eliminadas no se pueden recuperar.',
      one:
          'También se eliminará $count palabra de esta lista.\nLas listas eliminadas no se pueden recuperar.',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksDeleteEmpty =>
      'Las listas eliminadas no se pueden recuperar.';

  @override
  String get wordbookDetailEmpty =>
      'Aún no hay palabras.\nToca el botón Agregar palabra.';

  @override
  String wordbookDetailWordDeleted(String term) {
    return 'Se eliminó “$term”';
  }

  @override
  String get wordbookDetailUndo => 'Deshacer';

  @override
  String get wordbookDetailEditWholeWord => 'Editar palabra completa';

  @override
  String get wordbookDetailEditWord => 'Editar palabra';

  @override
  String get wordbookDetailFavorite => 'Favorito';

  @override
  String get wordbookDetailUnfavorite => 'Quitar de favoritos';

  @override
  String get wordbookDetailEditMeaning => 'Editar significado';

  @override
  String get wordbookDetailEditAll => 'Editar todo';

  @override
  String get wordbookDetailStatusFresh => 'Nueva';

  @override
  String get wordbookDetailStatusLearning => 'Aprendiendo';

  @override
  String get wordbookDetailStatusCompleted => 'Dominada';

  @override
  String get wordbookDetailDeleteWordConfirm => '¿Eliminar esta palabra?';

  @override
  String get wordbookDetailReleaseToDelete => 'Suelta para eliminar';

  @override
  String get exploreTitle => 'Explorar';

  @override
  String get exploreCodeNotFound =>
      'No hay ninguna lista compartida con este código.';

  @override
  String get exploreImportFailed =>
      'No se pudo importar. Revisa tu conexión a internet.';

  @override
  String exploreCopyTitle(String title) {
    return 'Copiar “$title”';
  }

  @override
  String exploreCopyConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '¿Copiar $count palabras a tus listas?\nEl progreso empezará desde cero.',
      one:
          '¿Copiar $count palabra a tus listas?\nEl progreso empezará desde cero.',
    );
    return '$_temp0';
  }

  @override
  String get exploreCopy => 'Copiar';

  @override
  String exploreImported(String title) {
    return 'Se importó “$title”.';
  }

  @override
  String get exploreLoggedOutHeadline => 'Descubre nuevas\nlistas';

  @override
  String get exploreLoginRequired =>
      'Inicia sesión para explorar listas compartidas.';

  @override
  String get exploreGoToLogin => 'Iniciar sesión';

  @override
  String get exploreSupabaseRequired =>
      'Disponible después de conectar Supabase.';

  @override
  String get exploreImportByCode => 'Importar con código';

  @override
  String get exploreCodeHint => 'Pega el código que recibiste';

  @override
  String get exploreImport => 'Importar';

  @override
  String get exploreCodeHelp =>
      'Para compartir una lista, copia su código en Compartir y visibilidad, en el menú de la lista.';

  @override
  String get explorePublicWordbooks => 'Listas públicas';

  @override
  String get explorePublicLoadFailed =>
      'No se pudieron cargar las listas públicas.\nDesliza hacia abajo para actualizar.';

  @override
  String get explorePublicEmpty => 'Aún no hay listas públicas.';

  @override
  String get loginMigrateTitle => 'Importar listas locales';

  @override
  String loginMigrateConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '¿Copiar a la nube $count listas creadas en este dispositivo?\nSe omitirán las listas que ya estén en la nube.',
      one:
          '¿Copiar a la nube $count lista creada en este dispositivo?\nSe omitirán las listas que ya estén en la nube.',
    );
    return '$_temp0';
  }

  @override
  String get loginLater => 'Más tarde';

  @override
  String get loginImport => 'Importar';

  @override
  String loginMigrated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se importaron $count listas.',
      one: 'Se importó $count lista.',
    );
    return '$_temp0';
  }

  @override
  String get loginAlreadyInCloud => 'Todas las listas ya están en la nube.';

  @override
  String get loginErrorInvalidCredentials => 'Correo o contraseña incorrectos.';

  @override
  String get loginErrorUserExists =>
      'Este correo ya está registrado. Inicia sesión.';

  @override
  String get loginErrorWeakPassword =>
      'La contraseña es muy corta. Usa al menos 6 caracteres.';

  @override
  String get loginErrorEmailNotConfirmed =>
      'Verifica tu correo. Revisa tu bandeja de entrada.';

  @override
  String get loginErrorRateLimit => 'Demasiados intentos. Inténtalo más tarde.';

  @override
  String loginErrorGeneric(String message) {
    return 'No se pudo iniciar sesión. ($message)';
  }

  @override
  String get loginErrorNetwork =>
      'No se pudo procesar la solicitud. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get loginTagline =>
      'Aprende fácil con ejemplos y sin parar con recordatorios';

  @override
  String get loginEmail => 'Correo electrónico';

  @override
  String get loginPassword => 'Contraseña';

  @override
  String get loginSignUpWithEmail => 'Registrarse con correo';

  @override
  String get loginContinueWithGoogle => 'Continuar con Google';

  @override
  String get navHome => 'Inicio';

  @override
  String get navWordbooks => 'Listas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsTranslationSection =>
      'Traducción de significados y ejemplos';

  @override
  String get settingsTranslationHelp =>
      'Automático usa el idioma y la región de tu dispositivo. La traducción se aplica a los significados y ejemplos de las palabras que busques a partir de ahora. Los significados sin traducción muestran la definición en inglés y las traducciones de los ejemplos quedan en blanco. Lo que ya guardaste no cambiará automáticamente.';

  @override
  String get settingsAppLanguageNote =>
      'La app también se mostrará en este idioma. Los idiomas sin traducción de la app se muestran en inglés.';

  @override
  String get settingsReviewMixSection => 'Mezcla de repaso';

  @override
  String get settingsReviewMixLabel => 'Mezclar palabras ya aprendidas';

  @override
  String settingsReviewMixHelp(int total, int mixed) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'preguntas',
      one: 'pregunta',
    );
    return 'Incluye esta proporción de palabras dominadas en tus repasos para reforzar la memoria a largo plazo. (p. ej., $mixed de $total $_temp0)';
  }

  @override
  String get settingsReminderSection => 'Recordatorios · Repaso';

  @override
  String get settingsReminderToggle => 'Recibir recordatorios de repaso';

  @override
  String get settingsReminderOff => 'Los recordatorios están desactivados.';

  @override
  String get settingsReminderNoActive =>
      'No hay franjas de recordatorio activas.';

  @override
  String settingsReminderSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordatorios',
      one: '$count recordatorio',
    );
    return 'Se repite cada semana · $_temp0 por semana. Incluye las palabras que estás aprendiendo según el orden en que toca repasarlas.';
  }

  @override
  String settingsReminderCapped(int limit) {
    return 'Se omiten algunos recordatorios tardíos porque superan el límite de $limit notificaciones programadas del dispositivo.';
  }

  @override
  String get settingsTtsSection => 'Pronunciación · TTS';

  @override
  String get settingsTtsDefault => 'Acento predeterminado';

  @override
  String get settingsTtsDefaultHelp =>
      'Elige el acento con el que se leen las palabras y los ejemplos.';

  @override
  String get settingsTtsUs => 'Americano';

  @override
  String get settingsTtsUk => 'Británico';

  @override
  String get settingsTtsQuality => 'Calidad de voz';

  @override
  String get settingsTtsQualityValue => 'TTS del dispositivo (gratis)';

  @override
  String get settingsTatoebaCredit =>
      'Ejemplos externos: Tatoeba · CC BY 2.0 FR';

  @override
  String get reminderEveryDay => 'Todos los días';

  @override
  String get reminderNoWeekdays => 'Ningún día';

  @override
  String get reminderWeekdays => 'Lunes a viernes';

  @override
  String get reminderWeekends => 'Fines de semana';

  @override
  String reminderIntervalMinutes(int minutes) {
    return 'Cada $minutes min';
  }

  @override
  String reminderIntervalHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Cada $hours horas',
      one: 'Cada hora',
    );
    return '$_temp0';
  }

  @override
  String reminderIntervalHoursMinutes(int hours, int minutes) {
    return 'Cada $hours h $minutes min';
  }

  @override
  String get reminderAddSchedule => 'Agregar franja horaria';

  @override
  String get reminderEditSchedule => 'Editar franja horaria';

  @override
  String get reminderStart => 'Inicio';

  @override
  String get reminderEnd => 'Fin';

  @override
  String get reminderCrossesMidnight =>
      'Si la hora de fin es anterior a la de inicio, los recordatorios siguen después de medianoche hasta la hora de fin del día siguiente.';

  @override
  String get reminderWeekdaysTitle => 'Días de recordatorio';

  @override
  String get reminderWeekdaysRequired => 'Elige al menos un día.';

  @override
  String get reminderInterval => 'Intervalo';

  @override
  String get reminderWordsPerAlert => 'Por aviso';

  @override
  String get reminderDecreaseWords => 'Menos palabras';

  @override
  String get reminderIncreaseWords => 'Más palabras';

  @override
  String reminderWordCount(int count) {
    return '$count';
  }

  @override
  String reminderWordCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palabras',
      one: '$count palabra',
    );
    return '$_temp0';
  }

  @override
  String reminderTimesPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces al día',
      one: '$count vez al día',
    );
    return '$_temp0';
  }

  @override
  String reminderPreview(String days, int count, String times) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces',
      one: '$count vez',
    );
    return '$days, $_temp0 · $times';
  }

  @override
  String get translationLanguageLabel => 'Idioma de traducción';

  @override
  String translationLanguageAuto(String language) {
    return 'Automático · $language';
  }

  @override
  String get notificationChannelName => 'Recordatorios de repaso';

  @override
  String get notificationChannelDescription =>
      'Recordatorios para repasar palabras en los días y horas que elijas';

  @override
  String get notificationTitleDefault => 'Hora de repasar';

  @override
  String notificationTitleWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tus $count palabras de hoy',
      one: 'Tu palabra de hoy',
    );
    return '$_temp0';
  }

  @override
  String get notificationBodyDefault =>
      'Tus palabras de hoy te esperan. ¡Toca para empezar!';

  @override
  String homeError(String error) {
    return 'Error: $error';
  }

  @override
  String get homeGreeting => '¿Aprendemos unas palabras?';

  @override
  String get homeTodayStudy => 'Hoy';

  @override
  String homeTotalWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palabras en total',
      one: '$count palabra en total',
    );
    return '$_temp0';
  }

  @override
  String get homeAccuracy => 'Aciertos';

  @override
  String homeCompletedWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dominadas',
      one: '$count dominada',
    );
    return '$_temp0';
  }

  @override
  String get homeWordOfTheDay => 'Palabra del día';

  @override
  String get homeQuickStart => 'Inicio rápido';

  @override
  String get homeQuickGuessWord => 'Adivina la palabra por los ejemplos';

  @override
  String get homeQuickFillBlank => 'Completa los espacios';

  @override
  String get homeQuickBrowseWordbooks => 'Ver listas';

  @override
  String get homeCreateWordbookFirst => 'Primero crea una lista.';

  @override
  String get homeEditWord => 'Editar palabra';

  @override
  String get homeListenWord => 'Escuchar la palabra';

  @override
  String get homeSeeDetails => 'Ver detalles';

  @override
  String get homeReviewAllDone => '¡Terminaste los\nrepasos de hoy!';

  @override
  String homeReviewWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palabras\nte esperan',
      one: '$count palabra\nte espera',
    );
    return '$_temp0';
  }

  @override
  String homeCompletedBadge(int count) {
    return '$count\ndominadas';
  }

  @override
  String homeReviewBreakdown(int due, int mixed) {
    return 'Nuevas/repaso $due · Mezcla $mixed';
  }

  @override
  String get homeStart => 'Empezar';

  @override
  String get reviewNoExample =>
      '(Sin ejemplo: escribe la palabra según su significado)';

  @override
  String get reviewTitle => 'Repaso con ejemplos';

  @override
  String get reviewEmpty => 'Sin tarjetas hoy';

  @override
  String get reviewFillBlankTitle => 'Completa el espacio';

  @override
  String get reviewChoiceInstruction =>
      'Elige la palabra que encaja con el ejemplo y el significado';

  @override
  String get reviewInputInstruction =>
      'Escribe la palabra que encaja con el ejemplo y el significado';

  @override
  String reviewOtherExample(int current, int total) {
    return 'Otro ejemplo  $current/$total';
  }

  @override
  String get reviewDontKnow => 'No lo sé';

  @override
  String get reviewInputHint => 'Escribe la palabra';

  @override
  String reviewHint(String hint) {
    return 'Pista: $hint';
  }

  @override
  String get reviewCheckAnswer => 'Comprobar';

  @override
  String get reviewCorrect => '¡Correcto!';

  @override
  String get reviewWrongAnswerIs => 'Casi. La respuesta es';

  @override
  String reviewSource(String source) {
    return 'Fuente: $source';
  }

  @override
  String get reviewMixedNotice => 'Una palabra dominada vuelve para repasar';

  @override
  String get reviewSummaryTitle => 'Repaso terminado';

  @override
  String get reviewSummaryDone => 'Terminaste el repaso';

  @override
  String reviewSummaryScore(int correct, int total) {
    return '$correct de $total correctas';
  }

  @override
  String get reviewGoHome => 'Volver al inicio';

  @override
  String get dictionaryRateLimited =>
      'Las búsquedas en el diccionario están limitadas por ahora. Inténtalo de nuevo en un momento.';

  @override
  String get dictionaryConnectionFailed =>
      'No se pudo conectar con el diccionario. Inténtalo de nuevo en un momento.';

  @override
  String get dictionaryTimeout =>
      'El diccionario está tardando demasiado. Inténtalo de nuevo.';

  @override
  String get dictionaryLoadFailed =>
      'No se pudieron cargar los significados del diccionario. Revisa tu conexión a internet e inténtalo de nuevo.';

  @override
  String get draftDictionaryUnavailable =>
      'No se pudo conectar con el diccionario. Escribe el significado a mano o vuelve a buscarlo.';

  @override
  String get draftMeaningNotFound =>
      'No se encontró el significado. Escríbelo a mano o búscalo en el diccionario.';

  @override
  String draftNoTranslationUsedEnglish(String language) {
    return 'El diccionario no tiene traducción ($language), así que se usaron definiciones en inglés. Puedes cambiar el idioma de traducción en Ajustes.';
  }

  @override
  String draftSomeUsedEnglish(String language) {
    return 'Las entradas sin traducción ($language) se completaron con definiciones en inglés.';
  }

  @override
  String get draftExamplesRetry =>
      'Puedes volver a cargar ejemplos con “Obtener ejemplos”, más abajo.';

  @override
  String get speakListen => 'Escuchar';

  @override
  String get speakListenExample => 'Escuchar ejemplo';

  @override
  String get adPreview => 'Vista previa del anuncio';

  @override
  String get addWordButton => 'Agregar palabra';

  @override
  String get wordCreateExampleTranslations => 'Incluir traducciones';

  @override
  String get wordCreateNoExampleTranslations => 'Sin traducción';

  @override
  String get homeRemainingCards => 'Tarjetas restantes';

  @override
  String homeTodayCards(int count) {
    return '$count hoy';
  }

  @override
  String homeNewReviewBreakdown(int fresh, int review) {
    return 'Nuevas $fresh · Repaso $review';
  }

  @override
  String get homeStartButton => 'Empezar';

  @override
  String get homeNoCardsToday => 'Sin tarjetas hoy';

  @override
  String reviewRemaining(int count) {
    return 'Quedan $count';
  }

  @override
  String get reviewKeep => 'Guardar';

  @override
  String get reviewDiscard => 'Descartar';

  @override
  String reviewDoneTitle(int count) {
    return '$count tarjetas hechas';
  }

  @override
  String wordbooksCardsLeft(int count) {
    return 'restantes · $count en total';
  }

  @override
  String get wordbookCardsLeftSuffix => 'restantes';

  @override
  String get wordbookDetailAllDiscarded => 'No quedan tarjetas';

  @override
  String wordbookDetailDiscarded(String term) {
    return '\'$term\' descartada';
  }

  @override
  String get wordbookDetailReleaseToDiscard => 'Suelta para descartar';

  @override
  String get wordbookAddWordShort => 'Palabra';

  @override
  String get discardedTitle => 'Descartadas';

  @override
  String get discardedEmpty => 'Nada descartado';

  @override
  String get discardedRestore => 'Devolver';

  @override
  String get wordAddMeaningSelect => 'Elige significados';

  @override
  String get wordAddManualInput => 'Escribir un significado';

  @override
  String get wordAddMeaningLabel => 'Significado';

  @override
  String wordAddExamplesOf(String pos) {
    return 'Ejemplos de $pos';
  }

  @override
  String wordAddSelectedCount(int count) {
    return '$count elegidos';
  }

  @override
  String get wordAddWriteExample => 'Escribir un ejemplo';

  @override
  String get wordAddSave => 'Añadir';

  @override
  String get wordAddAlreadyInDeck => 'Ya en el mazo';

  @override
  String get wordAddNoResults => 'No está en el diccionario';

  @override
  String get wordAddLookupFailed => 'Diccionario no disponible';

  @override
  String get wordAddAutoInput => 'Autocompletar';

  @override
  String get wordAddAutoOff => 'Autocompletar apagado';

  @override
  String get wordAddExampleTranslation => 'Traducciones';

  @override
  String get wordAddNoExamples =>
      'No hay ejemplos. Puedes añadir la palabra sin ninguno.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSlate => 'Pizarra';

  @override
  String get themeNavy => 'Marino';

  @override
  String get themeBrown => 'Marrón';

  @override
  String get themePlum => 'Ciruela';

  @override
  String get themeCharcoal => 'Carbón';

  @override
  String get themeCustom => 'Propio';

  @override
  String get themeCustomTitle => 'Tema propio';

  @override
  String get themeBase => 'Base';

  @override
  String get themePoint => 'Acento';

  @override
  String get themeAutoText => 'El color del texto se ajusta solo';

  @override
  String get themeApply => 'Aplicar';

  @override
  String get themeReset => 'Restablecer';

  @override
  String get settingsLanguageSection => 'Idioma';

  @override
  String get settingsLanguageRow => 'Significados · ejemplos · app';

  @override
  String get settingsFollowDevice => 'Según el dispositivo';

  @override
  String get settingsReviewSection => 'Repaso';

  @override
  String get settingsSessionSize => 'Tarjetas por sesión';

  @override
  String get settingsMixLabel => 'Mezclar descartadas';

  @override
  String settingsMixExample(int total, int mixed) {
    return '$mixed de $total';
  }

  @override
  String get settingsWordAddSection => 'Añadir palabras';

  @override
  String get settingsNotificationsSection => 'Recordatorios';

  @override
  String get settingsReminderMaster => 'Recordatorios de repaso';

  @override
  String get settingsAddSlot => 'Franja de aviso';

  @override
  String settingsWeeklyCount(int count) {
    return '$count veces por semana';
  }

  @override
  String reminderCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tarjetas',
      one: '1 tarjeta',
    );
    return '$_temp0';
  }

  @override
  String get settingsPronunciationSection => 'Pronunciación';

  @override
  String get settingsAccent => 'Acento';

  @override
  String get settingsVoice => 'Voz';

  @override
  String get settingsVoiceDefault => 'Predeterminada';

  @override
  String get settingsSpeed => 'Velocidad';

  @override
  String get settingsSpeedSlow => 'Lenta';

  @override
  String get settingsSpeedNormal => 'Normal';

  @override
  String get settingsSpeedFast => 'Rápida';

  @override
  String get settingsRecorded => 'Grabaciones humanas para palabras';

  @override
  String get settingsRecordedHelp => 'Si no hay, usa la voz';

  @override
  String get settingsAbout => 'Acerca de · fuentes';

  @override
  String get aboutDataSources => 'Fuentes de datos';

  @override
  String get aboutUseMeanings => 'Significados · ejemplos del diccionario';

  @override
  String get aboutUseOnline => 'Diccionario en línea';

  @override
  String get aboutUseExamples => 'Ejemplos traducidos';

  @override
  String get aboutUseRecordings => 'Grabaciones de palabras';

  @override
  String get aboutApp => 'App';

  @override
  String get aboutVersion => 'Versión';

  @override
  String get aboutLicenses => 'Licencias de código abierto';

  @override
  String reminderPerDayTotal(int times, int cards) {
    return '$times al día · $cards tarjetas';
  }

  @override
  String settingsPackDownloading(String size) {
    return 'Descargando traducciones de ejemplos · $size';
  }

  @override
  String settingsPackReady(String size) {
    return 'Traducciones de ejemplos listas · $size';
  }

  @override
  String get settingsPackFailed => 'No se pudieron descargar las traducciones';

  @override
  String get settingsPackRetry => 'Reintentar';

  @override
  String get settingsExampleDataSection => 'Datos de ejemplos';

  @override
  String get settingsExampleData => 'Descargar traducciones de ejemplos';

  @override
  String get settingsPackNone => 'No descargado';

  @override
  String get settingsPackNotNeeded => 'El inglés no necesita traducción';

  @override
  String settingsPackVersion(int version, String size) {
    return 'Descargado · v$version · $size';
  }

  @override
  String get settingsPackUpdate => 'Buscar actualizaciones';

  @override
  String settingsPackUpToDate(int version) {
    return 'Actualizado (v$version)';
  }

  @override
  String settingsPackUpdated(int version) {
    return 'Actualizado a v$version';
  }

  @override
  String get examplePromptTitle => '¿Descargar traducciones de ejemplos?';

  @override
  String examplePromptBody(String language, String size) {
    return 'Se descargarán las traducciones al $language de los ejemplos en inglés$size. Puedes cambiarlo en Ajustes › Datos de ejemplos.';
  }

  @override
  String get examplePromptAccept => 'Descargar';

  @override
  String get examplePromptDecline => 'Ahora no';

  @override
  String get wordAddPosLabel => 'Categoría gramatical';

  @override
  String get wordAddPosUnknown => 'No sé';

  @override
  String get homeQuickGuessFromMeaning =>
      'Adivina la palabra por su significado';

  @override
  String get wordFoundExample => 'Ejemplo encontrado';

  @override
  String get wordAddFoundExample => 'Añadir ejemplo';

  @override
  String wordbookFoundExamples(int count) {
    return '$count ejemplos encontrados';
  }

  @override
  String get wordAddScanExample => 'Ejemplos desde una foto';

  @override
  String get wordScanCamera => 'Hacer una foto';

  @override
  String get wordScanGallery => 'Elegir de la galería';

  @override
  String get wordScanPick => 'Elige las frases';

  @override
  String get wordScanFailed => 'No se pudo leer el texto de la foto';

  @override
  String wordScanNoSentence(String term) {
    return 'No hay frases con «$term» en la foto';
  }

  @override
  String get exampleSourcePhoto => 'Mi foto';
}
