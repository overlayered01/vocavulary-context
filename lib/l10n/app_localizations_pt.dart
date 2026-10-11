// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Vocab with Examples';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonAdd => 'Adicionar';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonRetry => 'Tentar novamente';

  @override
  String get commonNext => 'Próximo';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonConfirm => 'OK';

  @override
  String get commonLoading => 'Carregando';

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ko': 'Coreano',
      'ja': 'Japonês',
      'zh': 'Chinês',
      'es': 'Espanhol',
      'fr': 'Francês',
      'de': 'Alemão',
      'pt': 'Português',
      'vi': 'Vietnamita',
      'th': 'Tailandês',
      'id': 'Indonésio',
      'en': 'Inglês',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'seg',
      'd2': 'ter',
      'd3': 'qua',
      'd4': 'qui',
      'd5': 'sex',
      'd6': 'sáb',
      'd7': 'dom',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get wordAddWord => 'Adicionar palavra';

  @override
  String get wordEditWord => 'Editar palavra';

  @override
  String get wordExamples => 'Exemplos';

  @override
  String wordExampleSource(String source) {
    return 'Fonte: $source';
  }

  @override
  String wordPartOfSpeech(String pos, String value) {
    String _temp0 = intl.Intl.selectLogic(pos, {
      'noun': 'Substantivo',
      'verb': 'Verbo',
      'adjective': 'Adjetivo',
      'adverb': 'Advérbio',
      'pronoun': 'Pronome',
      'preposition': 'Preposição',
      'conjunction': 'Conjunção',
      'interjection': 'Interjeição',
      'article': 'Artigo',
      'determiner': 'Determinante',
      'phrasalVerb': 'Phrasal verb',
      'idiom': 'Expressão idiomática',
      'other': '$value',
    });
    return '$_temp0';
  }

  @override
  String get wordEditTermRequired => 'Primeiro, digite uma palavra em inglês.';

  @override
  String wordEditNoExamplesFound(String term) {
    return 'Nenhum exemplo encontrado para “$term”.';
  }

  @override
  String get wordEditExamplesAlreadyAdded =>
      'Todos os exemplos encontrados já foram adicionados.';

  @override
  String wordEditExamplesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exemplos adicionados.',
      one: '$count exemplo adicionado.',
    );
    return '$_temp0';
  }

  @override
  String wordEditExamplesFetchFailed(String error) {
    return 'Não foi possível buscar exemplos: $error';
  }

  @override
  String get wordEditTermAndMeaningRequired =>
      'Digite uma palavra e pelo menos um significado.';

  @override
  String get wordEditSaveFailed => 'Não foi possível salvar. Tente novamente.';

  @override
  String get wordEditSectionTerm => 'Palavra';

  @override
  String get wordEditSectionMeaning => 'Significado e pronúncia';

  @override
  String get wordEditPhonetic => 'Fonética';

  @override
  String get wordEditSearching => 'Buscando';

  @override
  String get wordEditFetchExamples => 'Buscar exemplos';

  @override
  String get wordEditAddManually => 'Adicionar manualmente';

  @override
  String get wordEditOptional => 'Opcional';

  @override
  String wordEditExampleNumber(int index) {
    return 'Exemplo $index';
  }

  @override
  String get wordEditDeleteExample => 'Excluir exemplo';

  @override
  String get wordEditSentence => 'Frase em inglês';

  @override
  String wordEditTranslationLabel(String language) {
    return 'Tradução ($language)';
  }

  @override
  String get wordEditTermLabel => 'Palavra *';

  @override
  String get wordEditTermHint =>
      'Escolha uma palavra salva para preencher os significados e exemplos automaticamente.';

  @override
  String get wordEditPartOfSpeech => 'Classe gramatical';

  @override
  String get wordEditPartOfSpeechNone => 'Nenhuma';

  @override
  String get wordEditManualExampleTitle => 'Adicionar exemplo manualmente';

  @override
  String get wordEditSentenceRequiredLabel => 'Frase em inglês *';

  @override
  String get wordEditSentenceRequired => 'Digite uma frase em inglês.';

  @override
  String wordEditPickerTitle(String term) {
    return 'Exemplos de “$term”';
  }

  @override
  String get wordEditPickerDescription =>
      'Escolha os exemplos que quer adicionar. Você pode digitar a tradução das frases que não têm uma.';

  @override
  String wordEditNoTranslation(String language) {
    return 'Sem tradução ($language)';
  }

  @override
  String get wordEditPickerAttribution => 'Exemplos do Tatoeba · CC BY 2.0 FR';

  @override
  String wordEditAddSelectedExamples(int count) {
    return 'Adicionar seleção ($count)';
  }

  @override
  String get wordCreateLoadFailed =>
      'Não foi possível carregar. Tente novamente.';

  @override
  String get wordCreateSectionTitle => 'Digite uma palavra';

  @override
  String get wordCreateWordbook => 'Lista';

  @override
  String get wordCreateNoWordbook => 'Nenhuma lista';

  @override
  String get wordCreateReload => 'Recarregar';

  @override
  String get wordCreateTermLabel => 'Palavra';

  @override
  String get wordCreateLookingUp => 'Buscando';

  @override
  String get wordCreateAutoInputSettings => 'Preenchimento automático';

  @override
  String get wordCreateMeaningsOn => 'Significados: sim';

  @override
  String get wordCreateMeaningsOff => 'Significados: não';

  @override
  String get wordCreateExamplesOn => 'Exemplos: sim';

  @override
  String get wordCreateExamplesOff => 'Exemplos: não';

  @override
  String get wordCreateCollapse => 'Recolher';

  @override
  String get wordCreateExpand => 'Expandir';

  @override
  String get wordCreateAutoMeanings => 'Preencher significados';

  @override
  String get wordCreateAutoExamples => 'Preencher exemplos';

  @override
  String get wordDetailDictionaryMeaningsAdded =>
      'Os significados selecionados foram adicionados.';

  @override
  String get wordDetailTitle => 'Detalhes da palavra';

  @override
  String get wordDetailFavorite => 'Adicionar aos favoritos';

  @override
  String get wordDetailUnfavorite => 'Remover dos favoritos';

  @override
  String get wordDetailAccentUs => 'Americano';

  @override
  String get wordDetailAccentUk => 'Britânico';

  @override
  String get wordDetailMyMeanings => 'Meus significados';

  @override
  String get wordDetailListenExample => 'Ouvir exemplo';

  @override
  String get wordDetailGoogleTranslate => 'Google Tradutor';

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
    return 'Remover significado $index';
  }

  @override
  String get meaningFieldsAdd => 'Adicionar significado';

  @override
  String get meaningFieldsEmptyError => 'Digite pelo menos um significado.';

  @override
  String get meaningFieldsEditTitle => 'Editar significados';

  @override
  String get dictLookupAddFailed =>
      'Não foi possível adicionar os significados. Tente novamente.';

  @override
  String get dictLookupButton => 'Significados do dicionário';

  @override
  String dictLookupTitle(String term) {
    return '$term · Dicionário';
  }

  @override
  String dictLookupFallbackNotice(String language) {
    return 'Itens sem tradução ($language) mostram a definição em inglês.';
  }

  @override
  String get dictLookupLoadFailed =>
      'Não foi possível carregar os significados do dicionário.';

  @override
  String get dictLookupNoResults =>
      'Nenhum significado encontrado no dicionário.\nVerifique a ortografia ou tente outro dicionário.';

  @override
  String get dictLookupAlreadyAdded => 'Adicionado';

  @override
  String dictLookupAddSelected(int count) {
    return 'Adicionar seleção ($count)';
  }

  @override
  String get dictLookupLinkFailed =>
      'Não foi possível abrir o link do dicionário.';

  @override
  String get dictLinksNaver => 'Naver (inglês–coreano)';

  @override
  String get dictLinksOxford => 'Oxford (inglês–inglês)';

  @override
  String get dictLinksOpenFailed =>
      'Não foi possível abrir o dicionário. Tente novamente.';

  @override
  String get dictLinksTitle => 'Ver mais nos dicionários';

  @override
  String wordbookError(String error) {
    return 'Erro: $error';
  }

  @override
  String get wordbookShareCode => 'Código de compartilhamento';

  @override
  String wordbookDeleteTitle(String name) {
    return 'Excluir “$name”';
  }

  @override
  String get wordbooksTitle => 'Minhas listas';

  @override
  String get wordbooksNew => 'Nova lista';

  @override
  String get wordbooksEmpty =>
      'Nenhuma lista ainda.\nToque em + para criar uma.';

  @override
  String get wordbooksCreate => 'Criar';

  @override
  String get wordbooksNameLabel => 'Nome da lista';

  @override
  String get wordbooksTagsLabel => 'Tags';

  @override
  String get wordbooksTagsHint =>
      'TOEIC, conversação do dia a dia (separadas por vírgula)';

  @override
  String wordbooksWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palavras',
      one: '$count palavra',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksMenu => 'Menu da lista';

  @override
  String get wordbooksMenuRename => 'Editar nome e tags';

  @override
  String get wordbooksShareSettings => 'Compartilhamento e visibilidade';

  @override
  String get wordbooksMenuDelete => 'Excluir lista';

  @override
  String get wordbooksEditTitle => 'Editar lista';

  @override
  String get wordbooksShareLoginRequired =>
      'Entre na sua conta para compartilhar ou publicar listas.';

  @override
  String get wordbooksVisibilityPrivate => 'Privada';

  @override
  String get wordbooksVisibilityShared => 'Por código';

  @override
  String get wordbooksVisibilityPublic => 'Pública';

  @override
  String get wordbooksVisibilityPrivateDesc => 'Só você pode ver.';

  @override
  String get wordbooksVisibilitySharedDesc =>
      'Qualquer pessoa com o código pode copiar esta lista.';

  @override
  String get wordbooksVisibilityPublicDesc =>
      'Aparece na aba Explorar, onde qualquer pessoa pode copiá-la.';

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
          'As $count palavras desta lista também serão excluídas.\nListas excluídas não podem ser restauradas.',
      one:
          '$count palavra desta lista também será excluída.\nListas excluídas não podem ser restauradas.',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksDeleteEmpty =>
      'Listas excluídas não podem ser restauradas.';

  @override
  String get wordbookDetailEmpty =>
      'Nenhuma palavra ainda.\nToque no botão Adicionar palavra.';

  @override
  String wordbookDetailWordDeleted(String term) {
    return '“$term” excluída';
  }

  @override
  String get wordbookDetailUndo => 'Desfazer';

  @override
  String get wordbookDetailEditWholeWord => 'Editar palavra inteira';

  @override
  String get wordbookDetailEditWord => 'Editar palavra';

  @override
  String get wordbookDetailFavorite => 'Favoritar';

  @override
  String get wordbookDetailUnfavorite => 'Remover dos favoritos';

  @override
  String get wordbookDetailEditMeaning => 'Editar significado';

  @override
  String get wordbookDetailEditAll => 'Editar tudo';

  @override
  String get wordbookDetailStatusFresh => 'Nova';

  @override
  String get wordbookDetailStatusLearning => 'Aprendendo';

  @override
  String get wordbookDetailStatusCompleted => 'Dominada';

  @override
  String get wordbookDetailDeleteWordConfirm => 'Excluir esta palavra?';

  @override
  String get wordbookDetailReleaseToDelete => 'Solte para excluir';

  @override
  String get exploreTitle => 'Explorar';

  @override
  String get exploreCodeNotFound =>
      'Nenhuma lista compartilhada corresponde a este código.';

  @override
  String get exploreImportFailed =>
      'Não foi possível importar. Verifique sua conexão.';

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
          'Copiar $count palavras para suas listas?\nO progresso começará do zero.',
      one:
          'Copiar $count palavra para suas listas?\nO progresso começará do zero.',
    );
    return '$_temp0';
  }

  @override
  String get exploreCopy => 'Copiar';

  @override
  String exploreImported(String title) {
    return '“$title” importada.';
  }

  @override
  String get exploreLoggedOutHeadline => 'Descubra novas\nlistas';

  @override
  String get exploreLoginRequired =>
      'Entre na sua conta para explorar listas compartilhadas.';

  @override
  String get exploreGoToLogin => 'Entrar';

  @override
  String get exploreSupabaseRequired => 'Disponível após conectar o Supabase.';

  @override
  String get exploreImportByCode => 'Importar com código';

  @override
  String get exploreCodeHint => 'Cole o código que você recebeu';

  @override
  String get exploreImport => 'Importar';

  @override
  String get exploreCodeHelp =>
      'Para compartilhar uma lista, copie o código em Compartilhamento e visibilidade, no menu da lista.';

  @override
  String get explorePublicWordbooks => 'Listas públicas';

  @override
  String get explorePublicLoadFailed =>
      'Não foi possível carregar as listas públicas.\nPuxe para baixo para atualizar.';

  @override
  String get explorePublicEmpty => 'Nenhuma lista pública ainda.';

  @override
  String get loginMigrateTitle => 'Importar listas locais';

  @override
  String loginMigrateConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Copiar para a nuvem $count listas criadas neste dispositivo?\nListas que já estão na nuvem serão ignoradas.',
      one:
          'Copiar para a nuvem $count lista criada neste dispositivo?\nListas que já estão na nuvem serão ignoradas.',
    );
    return '$_temp0';
  }

  @override
  String get loginLater => 'Depois';

  @override
  String get loginImport => 'Importar';

  @override
  String loginMigrated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listas importadas.',
      one: '$count lista importada.',
    );
    return '$_temp0';
  }

  @override
  String get loginAlreadyInCloud => 'Todas as listas já estão na nuvem.';

  @override
  String get loginErrorInvalidCredentials => 'E-mail ou senha incorretos.';

  @override
  String get loginErrorUserExists =>
      'Este e-mail já está cadastrado. Entre na sua conta.';

  @override
  String get loginErrorWeakPassword =>
      'A senha é muito curta. Use pelo menos 6 caracteres.';

  @override
  String get loginErrorEmailNotConfirmed =>
      'Confirme seu e-mail. Verifique sua caixa de entrada.';

  @override
  String get loginErrorRateLimit =>
      'Muitas tentativas. Tente novamente mais tarde.';

  @override
  String loginErrorGeneric(String message) {
    return 'Não foi possível entrar. ($message)';
  }

  @override
  String get loginErrorNetwork =>
      'Não foi possível processar a solicitação. Verifique sua conexão e tente novamente.';

  @override
  String get loginTitle => 'Entrar';

  @override
  String get loginTagline =>
      'Aprenda fácil com exemplos e sem parar com lembretes';

  @override
  String get loginEmail => 'E-mail';

  @override
  String get loginPassword => 'Senha';

  @override
  String get loginSignUpWithEmail => 'Cadastrar com e-mail';

  @override
  String get loginContinueWithGoogle => 'Continuar com o Google';

  @override
  String get navHome => 'Início';

  @override
  String get navWordbooks => 'Listas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsTranslationSection =>
      'Tradução de significados e exemplos';

  @override
  String get settingsTranslationHelp =>
      'O modo Automático segue o idioma e a região do seu dispositivo. A tradução é usada nos significados e exemplos das palavras que você pesquisar a partir de agora. Significados sem tradução mostram a definição em inglês, e as traduções dos exemplos ficam em branco. O conteúdo que você já salvou não muda automaticamente.';

  @override
  String get settingsAppLanguageNote =>
      'O app também é exibido neste idioma. Idiomas sem tradução do app aparecem em inglês.';

  @override
  String get settingsReviewMixSection => 'Mistura na revisão';

  @override
  String get settingsReviewMixLabel => 'Misturar palavras já aprendidas';

  @override
  String settingsReviewMixHelp(int total, int mixed) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'questões',
      one: 'questão',
    );
    return 'Inclui essa proporção de palavras dominadas nas revisões para reforçar a memória de longo prazo. (ex.: $mixed de $total $_temp0)';
  }

  @override
  String get settingsReminderSection => 'Lembretes · Revisão';

  @override
  String get settingsReminderToggle => 'Receber lembretes de revisão';

  @override
  String get settingsReminderOff => 'Os lembretes estão desativados.';

  @override
  String get settingsReminderNoActive => 'Nenhum período de lembrete ativado.';

  @override
  String settingsReminderSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lembretes',
      one: '$count lembrete',
    );
    return 'Repete toda semana · $_temp0 por semana. As palavras em estudo entram na ordem em que devem ser revisadas.';
  }

  @override
  String settingsReminderCapped(int limit) {
    return 'Alguns lembretes mais tarde ficam de fora porque ultrapassam o limite de $limit notificações agendadas do dispositivo.';
  }

  @override
  String get settingsTtsSection => 'Pronúncia · TTS';

  @override
  String get settingsTtsDefault => 'Sotaque padrão';

  @override
  String get settingsTtsDefaultHelp =>
      'Escolha o sotaque usado para ler palavras e exemplos.';

  @override
  String get settingsTtsUs => 'Americano';

  @override
  String get settingsTtsUk => 'Britânico';

  @override
  String get settingsTtsQuality => 'Qualidade da voz';

  @override
  String get settingsTtsQualityValue => 'TTS do dispositivo (grátis)';

  @override
  String get settingsTatoebaCredit =>
      'Exemplos externos: Tatoeba · CC BY 2.0 FR';

  @override
  String get reminderEveryDay => 'Todos os dias';

  @override
  String get reminderNoWeekdays => 'Nenhum dia';

  @override
  String get reminderWeekdays => 'Dias úteis';

  @override
  String get reminderWeekends => 'Fins de semana';

  @override
  String reminderIntervalMinutes(int minutes) {
    return 'A cada $minutes min';
  }

  @override
  String reminderIntervalHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'A cada $hours horas',
      one: 'A cada hora',
    );
    return '$_temp0';
  }

  @override
  String reminderIntervalHoursMinutes(int hours, int minutes) {
    return 'A cada $hours h $minutes min';
  }

  @override
  String get reminderAddSchedule => 'Adicionar período de lembrete';

  @override
  String get reminderEditSchedule => 'Editar período de lembrete';

  @override
  String get reminderStart => 'Início';

  @override
  String get reminderEnd => 'Fim';

  @override
  String get reminderCrossesMidnight =>
      'Se o horário de fim for anterior ao de início, os lembretes continuam após a meia-noite até o horário de fim do dia seguinte.';

  @override
  String get reminderWeekdaysTitle => 'Dias dos lembretes';

  @override
  String get reminderWeekdaysRequired => 'Selecione pelo menos um dia.';

  @override
  String get reminderInterval => 'Intervalo dos lembretes';

  @override
  String get reminderWordsPerAlert => 'Por lembrete';

  @override
  String get reminderDecreaseWords => 'Menos palavras';

  @override
  String get reminderIncreaseWords => 'Mais palavras';

  @override
  String reminderWordCount(int count) {
    return '$count';
  }

  @override
  String reminderWordCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palavras',
      one: '$count palavra',
    );
    return '$_temp0';
  }

  @override
  String reminderTimesPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vezes por dia',
      one: '$count vez por dia',
    );
    return '$_temp0';
  }

  @override
  String reminderPreview(String days, int count, String times) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vezes',
      one: '$count vez',
    );
    return '$days, $_temp0 · $times';
  }

  @override
  String get translationLanguageLabel => 'Idioma de tradução';

  @override
  String translationLanguageAuto(String language) {
    return 'Automático · $language';
  }

  @override
  String get notificationChannelName => 'Lembretes de revisão';

  @override
  String get notificationChannelDescription =>
      'Lembretes para revisar palavras nos dias e horários escolhidos';

  @override
  String get notificationTitleDefault => 'Hora de revisar';

  @override
  String notificationTitleWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Suas $count palavras de hoje',
      one: 'Sua palavra de hoje',
    );
    return '$_temp0';
  }

  @override
  String get notificationBodyDefault =>
      'Suas palavras de hoje estão esperando. Toque para começar!';

  @override
  String homeError(String error) {
    return 'Erro: $error';
  }

  @override
  String get homeGreeting => 'Vamos aprender algumas palavras?';

  @override
  String get homeTodayStudy => 'Hoje';

  @override
  String homeTotalWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palavras no total',
      one: '$count palavra no total',
    );
    return '$_temp0';
  }

  @override
  String get homeAccuracy => 'Acertos';

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
  String get homeWordOfTheDay => 'Palavra do dia';

  @override
  String get homeQuickStart => 'Início rápido';

  @override
  String get homeQuickGuessWord => 'Adivinhe a palavra pelos exemplos';

  @override
  String get homeQuickFillBlank => 'Complete as lacunas';

  @override
  String get homeQuickBrowseWordbooks => 'Ver listas';

  @override
  String get homeCreateWordbookFirst => 'Crie uma lista primeiro.';

  @override
  String get homeEditWord => 'Editar palavra';

  @override
  String get homeListenWord => 'Ouvir a palavra';

  @override
  String get homeSeeDetails => 'Ver detalhes';

  @override
  String get homeReviewAllDone => 'Revisões de hoje\nconcluídas!';

  @override
  String homeReviewWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palavras\nesperam por você',
      one: '$count palavra\nespera por você',
    );
    return '$_temp0';
  }

  @override
  String homeCompletedBadge(int count) {
    return '$count\ndominadas';
  }

  @override
  String homeReviewBreakdown(int due, int mixed) {
    return 'Novas/revisão $due · Mistura $mixed';
  }

  @override
  String get homeStart => 'Começar';

  @override
  String get reviewNoExample =>
      '(Sem exemplo — digite a palavra pelo significado)';

  @override
  String get reviewTitle => 'Revisão com exemplos';

  @override
  String get reviewEmpty => 'Sem cartões hoje';

  @override
  String get reviewFillBlankTitle => 'Complete a lacuna';

  @override
  String get reviewChoiceInstruction =>
      'Escolha a palavra que combina com o exemplo e o significado';

  @override
  String get reviewInputInstruction =>
      'Digite a palavra que combina com o exemplo e o significado';

  @override
  String reviewOtherExample(int current, int total) {
    return 'Outro exemplo  $current/$total';
  }

  @override
  String get reviewDontKnow => 'Não sei';

  @override
  String get reviewInputHint => 'Digite a palavra';

  @override
  String reviewHint(String hint) {
    return 'Dica: $hint';
  }

  @override
  String get reviewCheckAnswer => 'Verificar';

  @override
  String get reviewCorrect => 'Correto!';

  @override
  String get reviewWrongAnswerIs => 'Quase. A resposta é';

  @override
  String reviewSource(String source) {
    return 'Fonte: $source';
  }

  @override
  String get reviewMixedNotice => 'Uma palavra dominada voltou para revisão';

  @override
  String get reviewSummaryTitle => 'Revisão concluída';

  @override
  String get reviewSummaryDone => 'Você concluiu a revisão';

  @override
  String reviewSummaryScore(int correct, int total) {
    return '$correct de $total corretas';
  }

  @override
  String get reviewGoHome => 'Voltar ao início';

  @override
  String get dictionaryRateLimited =>
      'As buscas no dicionário estão temporariamente limitadas. Tente novamente em instantes.';

  @override
  String get dictionaryConnectionFailed =>
      'Não foi possível acessar o dicionário. Tente novamente em instantes.';

  @override
  String get dictionaryTimeout =>
      'O dicionário está demorando muito. Tente novamente.';

  @override
  String get dictionaryLoadFailed =>
      'Não foi possível carregar os significados do dicionário. Verifique sua conexão com a internet e tente novamente.';

  @override
  String get draftDictionaryUnavailable =>
      'Não foi possível acessar o dicionário. Digite o significado manualmente ou busque novamente.';

  @override
  String get draftMeaningNotFound =>
      'Nenhum significado encontrado. Digite manualmente ou pesquise no dicionário.';

  @override
  String draftNoTranslationUsedEnglish(String language) {
    return 'O dicionário não tem tradução ($language), então foram usadas definições em inglês. Você pode mudar o idioma de tradução em Ajustes.';
  }

  @override
  String draftSomeUsedEnglish(String language) {
    return 'Itens sem tradução ($language) foram preenchidos com definições em inglês.';
  }

  @override
  String get draftExamplesRetry =>
      'Você pode carregar exemplos de novo com “Buscar exemplos”, logo abaixo.';

  @override
  String get speakListen => 'Ouvir';

  @override
  String get speakListenExample => 'Ouvir exemplo';

  @override
  String get adPreview => 'Prévia do anúncio';

  @override
  String get addWordButton => 'Adicionar palavra';

  @override
  String get wordCreateExampleTranslations => 'Incluir traduções';

  @override
  String get wordCreateNoExampleTranslations => 'Sem tradução';

  @override
  String get homeRemainingCards => 'Cartões restantes';

  @override
  String homeTodayCards(int count) {
    return '$count hoje';
  }

  @override
  String homeNewReviewBreakdown(int fresh, int review) {
    return 'Novos $fresh · Revisão $review';
  }

  @override
  String get homeStartButton => 'Começar';

  @override
  String get homeNoCardsToday => 'Sem cartões hoje';

  @override
  String reviewRemaining(int count) {
    return 'Restam $count';
  }

  @override
  String get reviewKeep => 'Manter';

  @override
  String get reviewDiscard => 'Descartar';

  @override
  String reviewDoneTitle(int count) {
    return '$count cartões feitos';
  }

  @override
  String wordbooksCardsLeft(int count) {
    return 'restantes · $count no total';
  }

  @override
  String get wordbookCardsLeftSuffix => 'restantes';

  @override
  String get wordbookDetailAllDiscarded => 'Nenhum cartão restante';

  @override
  String wordbookDetailDiscarded(String term) {
    return '\'$term\' descartado';
  }

  @override
  String get wordbookDetailReleaseToDiscard => 'Solte para descartar';

  @override
  String get wordbookAddWordShort => 'Palavra';

  @override
  String get discardedTitle => 'Descartados';

  @override
  String get discardedEmpty => 'Nada descartado';

  @override
  String get discardedRestore => 'Devolver';

  @override
  String get wordAddMeaningSelect => 'Escolha significados';

  @override
  String get wordAddManualInput => 'Digitar um significado';

  @override
  String get wordAddMeaningLabel => 'Significado';

  @override
  String wordAddExamplesOf(String pos) {
    return 'Exemplos de $pos';
  }

  @override
  String wordAddSelectedCount(int count) {
    return '$count escolhidos';
  }

  @override
  String get wordAddWriteExample => 'Escrever um exemplo';

  @override
  String get wordAddSave => 'Adicionar';

  @override
  String get wordAddAlreadyInDeck => 'Já no baralho';

  @override
  String get wordAddNoResults => 'Não está no dicionário';

  @override
  String get wordAddLookupFailed => 'Dicionário indisponível';

  @override
  String get wordAddAutoInput => 'Preenchimento automático';

  @override
  String get wordAddAutoOff => 'Preenchimento automático desligado';

  @override
  String get wordAddExampleTranslation => 'Traduções';

  @override
  String get wordAddNoExamples =>
      'Nenhum exemplo encontrado. Você pode adicionar a palavra sem exemplo.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSlate => 'Ardósia';

  @override
  String get themeNavy => 'Marinho';

  @override
  String get themeBrown => 'Marrom';

  @override
  String get themePlum => 'Ameixa';

  @override
  String get themeCharcoal => 'Carvão';

  @override
  String get themeCustom => 'Próprio';

  @override
  String get themeCustomTitle => 'Tema próprio';

  @override
  String get themeBase => 'Base';

  @override
  String get themePoint => 'Destaque';

  @override
  String get themeAutoText => 'A cor do texto se ajusta';

  @override
  String get themeApply => 'Aplicar';

  @override
  String get themeReset => 'Redefinir';

  @override
  String get settingsLanguageSection => 'Idioma';

  @override
  String get settingsLanguageRow => 'Significados · exemplos · app';

  @override
  String get settingsFollowDevice => 'Segue o dispositivo';

  @override
  String get settingsReviewSection => 'Revisão';

  @override
  String get settingsSessionSize => 'Cartões por sessão';

  @override
  String get settingsMixLabel => 'Misturar descartados';

  @override
  String settingsMixExample(int total, int mixed) {
    return '$mixed de $total';
  }

  @override
  String get settingsWordAddSection => 'Adicionar palavras';

  @override
  String get settingsNotificationsSection => 'Lembretes';

  @override
  String get settingsReminderMaster => 'Lembretes de revisão';

  @override
  String get settingsAddSlot => 'Faixa de lembrete';

  @override
  String settingsWeeklyCount(int count) {
    return '$count vezes por semana';
  }

  @override
  String reminderCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartões',
      one: '1 cartão',
    );
    return '$_temp0';
  }

  @override
  String get settingsPronunciationSection => 'Pronúncia';

  @override
  String get settingsAccent => 'Sotaque';

  @override
  String get settingsVoice => 'Voz';

  @override
  String get settingsVoiceDefault => 'Padrão';

  @override
  String get settingsSpeed => 'Velocidade';

  @override
  String get settingsSpeedSlow => 'Lenta';

  @override
  String get settingsSpeedNormal => 'Normal';

  @override
  String get settingsSpeedFast => 'Rápida';

  @override
  String get settingsRecorded => 'Gravações humanas para palavras';

  @override
  String get settingsRecordedHelp => 'Se não houver, usa a voz';

  @override
  String get settingsAbout => 'Sobre · fontes';

  @override
  String get aboutDataSources => 'Fontes de dados';

  @override
  String get aboutUseMeanings => 'Significados · exemplos do dicionário';

  @override
  String get aboutUseOnline => 'Dicionário online';

  @override
  String get aboutUseExamples => 'Exemplos traduzidos';

  @override
  String get aboutUseRecordings => 'Gravações de palavras';

  @override
  String get aboutApp => 'App';

  @override
  String get aboutVersion => 'Versão';

  @override
  String get aboutLicenses => 'Licenças de código aberto';

  @override
  String reminderPerDayTotal(int times, int cards) {
    return '$times por dia · $cards cartões';
  }

  @override
  String settingsPackDownloading(String size) {
    return 'Baixando traduções dos exemplos · $size';
  }

  @override
  String settingsPackReady(String size) {
    return 'Traduções dos exemplos prontas · $size';
  }

  @override
  String get settingsPackFailed => 'Não foi possível baixar as traduções';

  @override
  String get settingsPackRetry => 'Tentar de novo';

  @override
  String get settingsExampleDataSection => 'Dados de exemplos';

  @override
  String get settingsExampleData => 'Baixar traduções dos exemplos';

  @override
  String get settingsPackNone => 'Não baixado';

  @override
  String get settingsPackNotNeeded => 'Inglês não precisa de tradução';

  @override
  String settingsPackVersion(int version, String size) {
    return 'Baixado · v$version · $size';
  }

  @override
  String get settingsPackUpdate => 'Verificar atualizações';

  @override
  String settingsPackUpToDate(int version) {
    return 'Atualizado (v$version)';
  }

  @override
  String settingsPackUpdated(int version) {
    return 'Atualizado para v$version';
  }

  @override
  String get examplePromptTitle => 'Baixar traduções dos exemplos?';

  @override
  String examplePromptBody(String language, String size) {
    return 'As traduções em $language dos exemplos em inglês serão baixadas$size. Você pode mudar isso em Ajustes › Dados de exemplos.';
  }

  @override
  String get examplePromptAccept => 'Baixar';

  @override
  String get examplePromptDecline => 'Agora não';

  @override
  String get wordAddPosLabel => 'Classe gramatical';

  @override
  String get wordAddPosUnknown => 'Não sei';

  @override
  String get homeQuickGuessFromMeaning => 'Adivinhe a palavra pelo significado';

  @override
  String get wordFoundExample => 'Exemplo encontrado';

  @override
  String get wordAddFoundExample => 'Adicionar exemplo';

  @override
  String wordbookFoundExamples(int count) {
    return '$count exemplos encontrados';
  }

  @override
  String get wordAddScanExample => 'Exemplos de uma foto';

  @override
  String get wordScanCamera => 'Tirar foto';

  @override
  String get wordScanGallery => 'Escolher da galeria';

  @override
  String get wordScanPick => 'Escolha as frases';

  @override
  String get wordScanFailed => 'Não foi possível ler o texto da foto';

  @override
  String wordScanNoSentence(String term) {
    return 'Nenhuma frase com \"$term\" na foto';
  }

  @override
  String get exampleSourcePhoto => 'Minha foto';
}
