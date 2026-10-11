"""Translations for the card redesign strings (ja, zh, es, fr, de, pt, vi, th, id).

Usage: python -X utf8 tool/l10n_cards_translations.py
Writes into lib/l10n/app_<lang>.arb through tool/l10n_add.py.
"""
import json
import pathlib
import subprocess
import sys
import tempfile

LANGS = ["ja", "zh", "es", "fr", "de", "pt", "vi", "th", "id"]

T = {
    "homeRemainingCards": ["残りのカード", "剩余卡片", "Tarjetas restantes", "Cartes restantes", "Verbleibende Karten", "Cartões restantes", "Thẻ còn lại", "การ์ดที่เหลือ", "Kartu tersisa"],
    "homeTodayCards": ["今日 {count}枚", "今天 {count}张", "{count} hoy", "{count} aujourd'hui", "{count} heute", "{count} hoje", "Hôm nay {count} thẻ", "วันนี้ {count} ใบ", "{count} hari ini"],
    "homeNewReviewBreakdown": ["新規 {fresh} · 復習 {review}", "新 {fresh} · 复习 {review}", "Nuevas {fresh} · Repaso {review}", "Nouvelles {fresh} · Révision {review}", "Neu {fresh} · Wiederholen {review}", "Novos {fresh} · Revisão {review}", "Mới {fresh} · Ôn {review}", "ใหม่ {fresh} · ทบทวน {review}", "Baru {fresh} · Ulang {review}"],
    "homeStartButton": ["スタート", "开始", "Empezar", "Commencer", "Start", "Começar", "Bắt đầu", "เริ่ม", "Mulai"],
    "homeNoCardsToday": ["今日のカードなし", "今天没有卡片", "Sin tarjetas hoy", "Aucune carte aujourd'hui", "Heute keine Karten", "Sem cartões hoje", "Hôm nay không có thẻ", "วันนี้ไม่มีการ์ด", "Tidak ada kartu hari ini"],
    "homeNewCard": ["新しい", "新卡", "Nueva", "Nouvelle", "Neu", "Novo", "Mới", "ใหม่", "Baru"],
    "homeSeenCount": ["{count}回目", "第{count}次", "Ronda {count}", "Tour {count}", "Runde {count}", "Rodada {count}", "Lần {count}", "รอบที่ {count}", "Putaran {count}"],
    "reviewRemaining": ["残り {count}", "剩余 {count}", "Quedan {count}", "Reste {count}", "Noch {count}", "Restam {count}", "Còn {count}", "เหลือ {count}", "Sisa {count}"],
    "reviewKeep": ["残す", "保留", "Guardar", "Garder", "Behalten", "Manter", "Giữ lại", "เก็บไว้", "Simpan"],
    "reviewDiscard": ["捨てる", "丢弃", "Descartar", "Jeter", "Ablegen", "Descartar", "Bỏ đi", "ทิ้ง", "Buang"],
    "reviewDoneTitle": ["今日の{count}枚 完了", "今天的{count}张 完成", "{count} tarjetas hechas", "{count} cartes faites", "{count} Karten erledigt", "{count} cartões feitos", "Xong {count} thẻ", "เสร็จ {count} ใบ", "{count} kartu selesai"],
    "reviewEmpty": ["今日のカードなし", "今天没有卡片", "Sin tarjetas hoy", "Aucune carte aujourd'hui", "Heute keine Karten", "Sem cartões hoje", "Hôm nay không có thẻ", "วันนี้ไม่มีการ์ด", "Tidak ada kartu hari ini"],
    "reviewDontKnow": ["わからない", "不知道", "No lo sé", "Je ne sais pas", "Weiß nicht", "Não sei", "Không biết", "ไม่รู้", "Tidak tahu"],
    "wordbooksCardsLeft": ["枚残り · 全{count}", "张剩余 · 共{count}", "restantes · {count} en total", "restantes · {count} au total", "übrig · {count} gesamt", "restantes · {count} no total", "còn lại · tổng {count}", "ใบที่เหลือ · ทั้งหมด {count}", "tersisa · total {count}"],
    "wordbookCardsLeftSuffix": ["枚残り", "张剩余", "restantes", "restantes", "übrig", "restantes", "còn lại", "ใบที่เหลือ", "tersisa"],
    "wordbookDetailAllDiscarded": ["残りのカードなし", "没有剩余卡片", "No quedan tarjetas", "Plus aucune carte", "Keine Karten übrig", "Nenhum cartão restante", "Không còn thẻ", "ไม่มีการ์ดเหลือ", "Tidak ada kartu tersisa"],
    "wordbookDetailDiscarded": ["'{term}' を捨てました", "已丢弃 '{term}'", "'{term}' descartada", "'{term}' jetée", "'{term}' abgelegt", "'{term}' descartado", "Đã bỏ '{term}'", "ทิ้ง '{term}' แล้ว", "'{term}' dibuang"],
    "wordbookDetailReleaseToDiscard": ["離すと捨てる", "松开即丢弃", "Suelta para descartar", "Relâchez pour jeter", "Loslassen zum Ablegen", "Solte para descartar", "Thả để bỏ", "ปล่อยเพื่อทิ้ง", "Lepas untuk membuang"],
    "wordbookAddWordShort": ["単語", "单词", "Palabra", "Mot", "Wort", "Palavra", "Từ", "คำ", "Kata"],
    "discardedTitle": ["捨てたカード", "已丢弃的卡片", "Descartadas", "Cartes jetées", "Abgelegt", "Descartados", "Thẻ đã bỏ", "การ์ดที่ทิ้ง", "Kartu dibuang"],
    "discardedEmpty": ["捨てたカードなし", "没有丢弃的卡片", "Nada descartado", "Rien de jeté", "Nichts abgelegt", "Nada descartado", "Chưa bỏ thẻ nào", "ยังไม่มีการ์ดที่ทิ้ง", "Belum ada yang dibuang"],
    "discardedRestore": ["戻す", "放回", "Devolver", "Remettre", "Zurücklegen", "Devolver", "Đưa lại", "ใส่คืน", "Kembalikan"],
    "wordAddMeaningSelect": ["意味を選ぶ", "选择词义", "Elige significados", "Choisir les sens", "Bedeutungen wählen", "Escolha significados", "Chọn nghĩa", "เลือกความหมาย", "Pilih arti"],
    "wordAddManualInput": ["自分で入力", "自己输入", "Escribir el tuyo", "Ajouter le vôtre", "Selbst eingeben", "Escrever o seu", "Tự nhập", "พิมพ์เอง", "Tulis sendiri"],
    "wordAddMeaningLabel": ["意味", "词义", "Significado", "Sens", "Bedeutung", "Significado", "Nghĩa", "ความหมาย", "Arti"],
    "wordAddPickExamples": ["例文を選ぶ", "选择例句", "Elegir ejemplos", "Choisir des exemples", "Beispiele wählen", "Escolher exemplos", "Chọn ví dụ", "เลือกประโยคตัวอย่าง", "Pilih contoh"],
    "wordAddExamplesOf": ["{pos} の例文", "{pos} 例句", "Ejemplos de {pos}", "Exemples : {pos}", "{pos}-Beispiele", "Exemplos de {pos}", "Ví dụ {pos}", "ตัวอย่าง {pos}", "Contoh {pos}"],
    "wordAddSelectedCount": ["{count}件選択", "已选{count}个", "{count} elegidos", "{count} choisis", "{count} gewählt", "{count} escolhidos", "Đã chọn {count}", "เลือก {count}", "{count} dipilih"],
    "wordAddWriteExample": ["自分で書く", "自己写", "Escribir el tuyo", "Écrire le vôtre", "Selbst schreiben", "Escrever o seu", "Tự viết", "เขียนเอง", "Tulis sendiri"],
    "wordAddSave": ["デッキに入れる", "加入卡组", "Añadir al mazo", "Ajouter au paquet", "Zum Stapel", "Adicionar ao baralho", "Thêm vào bộ thẻ", "ใส่ในสำรับ", "Masukkan ke dek"],
    "wordAddAlreadyInDeck": ["デッキにあります", "已在卡组中", "Ya en el mazo", "Déjà dans le paquet", "Schon im Stapel", "Já no baralho", "Đã có trong bộ", "มีในสำรับแล้ว", "Sudah ada di dek"],
    "wordAddNoResults": ["辞書になし", "词典中没有", "No está en el diccionario", "Absent du dictionnaire", "Nicht im Wörterbuch", "Não está no dicionário", "Không có trong từ điển", "ไม่มีในพจนานุกรม", "Tidak ada di kamus"],
    "wordAddLookupFailed": ["辞書に接続できません", "无法连接词典", "Diccionario no disponible", "Dictionnaire indisponible", "Wörterbuch nicht erreichbar", "Dicionário indisponível", "Không kết nối được từ điển", "เชื่อมต่อพจนานุกรมไม่ได้", "Kamus tidak tersedia"],
    "wordAddAutoInput": ["自動入力", "自动填写", "Autocompletar", "Remplissage auto", "Automatisch ausfüllen", "Preenchimento automático", "Tự điền", "กรอกอัตโนมัติ", "Isi otomatis"],
    "wordAddAutoOff": ["自動入力オフ", "自动填写已关闭", "Autocompletar apagado", "Remplissage auto désactivé", "Automatik aus", "Preenchimento automático desligado", "Tắt tự điền", "ปิดการกรอกอัตโนมัติ", "Isi otomatis mati"],
    "wordAddExampleTranslation": ["例文の訳", "例句翻译", "Traducciones", "Traductions", "Übersetzungen", "Traduções", "Bản dịch", "คำแปล", "Terjemahan"],
    "wordAddPosOther": ["その他", "其他", "otro", "autre", "andere", "outro", "khác", "อื่นๆ", "lainnya"],
    "wordAddNoExamples": ["例文の候補なし", "没有候选例句", "Sin ejemplos", "Aucun exemple", "Keine Beispiele", "Sem exemplos", "Không có ví dụ", "ไม่มีตัวอย่าง", "Tidak ada contoh"],
    "settingsTheme": ["テーマ", "主题", "Tema", "Thème", "Design", "Tema", "Giao diện", "ธีม", "Tema"],
    "themeSlate": ["スレート", "石板", "Pizarra", "Ardoise", "Schiefer", "Ardósia", "Đá phiến", "สเลท", "Batu"],
    "themeNavy": ["ネイビー", "藏青", "Marino", "Marine", "Marine", "Marinho", "Xanh navy", "กรมท่า", "Biru tua"],
    "themeBrown": ["ブラウン", "棕色", "Marrón", "Brun", "Braun", "Marrom", "Nâu", "น้ำตาล", "Cokelat"],
    "themePlum": ["プラム", "李紫", "Ciruela", "Prune", "Pflaume", "Ameixa", "Mận", "พลัม", "Plum"],
    "themeCharcoal": ["チャコール", "炭灰", "Carbón", "Anthracite", "Anthrazit", "Carvão", "Than", "ถ่าน", "Arang"],
    "themeCustom": ["カスタム", "自定义", "Propio", "Perso", "Eigene", "Próprio", "Tùy chỉnh", "กำหนดเอง", "Kustom"],
    "themeCustomTitle": ["テーマを自分で設定", "自定义主题", "Tema propio", "Thème personnalisé", "Eigenes Design", "Tema próprio", "Tự chọn giao diện", "ธีมกำหนดเอง", "Tema kustom"],
    "themeBase": ["ベース", "底色", "Base", "Fond", "Basis", "Base", "Nền", "พื้น", "Dasar"],
    "themePoint": ["アクセント", "强调色", "Acento", "Accent", "Akzent", "Destaque", "Điểm nhấn", "สีเน้น", "Aksen"],
    "themeAutoText": ["文字色は自動で調整", "文字颜色自动调整", "El color del texto se ajusta solo", "La couleur du texte s'ajuste", "Textfarben passen sich an", "A cor do texto se ajusta", "Màu chữ tự điều chỉnh", "สีตัวอักษรปรับอัตโนมัติ", "Warna teks menyesuaikan"],
    "themeApply": ["適用", "应用", "Aplicar", "Appliquer", "Anwenden", "Aplicar", "Áp dụng", "ใช้", "Terapkan"],
    "themeReset": ["リセット", "重置", "Restablecer", "Réinitialiser", "Zurücksetzen", "Redefinir", "Đặt lại", "รีเซ็ต", "Atur ulang"],
    "settingsLanguageSection": ["言語", "语言", "Idioma", "Langue", "Sprache", "Idioma", "Ngôn ngữ", "ภาษา", "Bahasa"],
    "settingsLanguageRow": ["意味 · 例文 · アプリ", "词义 · 例句 · 应用", "Significados · ejemplos · app", "Sens · exemples · appli", "Bedeutungen · Beispiele · App", "Significados · exemplos · app", "Nghĩa · ví dụ · ứng dụng", "ความหมาย · ตัวอย่าง · แอป", "Arti · contoh · aplikasi"],
    "settingsFollowDevice": ["端末の設定に従う", "跟随设备", "Según el dispositivo", "Selon l'appareil", "Wie Gerät", "Segue o dispositivo", "Theo thiết bị", "ตามอุปกรณ์", "Ikuti perangkat"],
    "settingsReviewSection": ["復習", "复习", "Repaso", "Révision", "Wiederholen", "Revisão", "Ôn tập", "ทบทวน", "Ulangan"],
    "settingsSessionSize": ["1回に出すカード", "每次的卡片数", "Tarjetas por sesión", "Cartes par session", "Karten pro Runde", "Cartões por sessão", "Số thẻ mỗi lần", "การ์ดต่อรอบ", "Kartu per sesi"],
    "settingsMixLabel": ["捨てたカードを混ぜる", "混入已丢弃的卡片", "Mezclar descartadas", "Mélanger les cartes jetées", "Abgelegte untermischen", "Misturar descartados", "Trộn lại thẻ đã bỏ", "ผสมการ์ดที่ทิ้งกลับมา", "Campur kartu dibuang"],
    "settingsMixExample": ["{total}枚中 {mixed}枚", "{total}张中{mixed}张", "{mixed} de {total}", "{mixed} sur {total}", "{mixed} von {total}", "{mixed} de {total}", "{mixed} trên {total}", "{mixed} จาก {total}", "{mixed} dari {total}"],
    "settingsWordAddSection": ["単語の追加", "添加单词", "Añadir palabras", "Ajout de mots", "Wörter hinzufügen", "Adicionar palavras", "Thêm từ", "การเพิ่มคำ", "Tambah kata"],
    "settingsNotificationsSection": ["通知", "提醒", "Recordatorios", "Rappels", "Erinnerungen", "Lembretes", "Nhắc nhở", "การแจ้งเตือน", "Pengingat"],
    "settingsReminderMaster": ["復習の通知", "复习提醒", "Recordatorios de repaso", "Rappels de révision", "Wiederholungs-Erinnerungen", "Lembretes de revisão", "Nhắc ôn tập", "แจ้งเตือนทบทวน", "Pengingat ulangan"],
    "settingsAddSlot": ["通知の時間帯", "提醒时段", "Franja de aviso", "Plage de rappel", "Erinnerungszeitraum", "Faixa de lembrete", "Khung giờ nhắc", "ช่วงเวลาแจ้งเตือน", "Rentang pengingat"],
    "settingsWeeklyCount": ["週{count}回", "每周{count}次", "{count} veces por semana", "{count} fois par semaine", "{count}× pro Woche", "{count} vezes por semana", "{count} lần mỗi tuần", "สัปดาห์ละ {count} ครั้ง", "{count}× seminggu"],
    "reminderCardCount": ["{count}枚", "{count}张", "{count, plural, =1{1 tarjeta} other{{count} tarjetas}}", "{count, plural, =1{1 carte} other{{count} cartes}}", "{count, plural, =1{1 Karte} other{{count} Karten}}", "{count, plural, =1{1 cartão} other{{count} cartões}}", "{count} thẻ", "{count} ใบ", "{count} kartu"],
    "settingsPronunciationSection": ["発音", "发音", "Pronunciación", "Prononciation", "Aussprache", "Pronúncia", "Phát âm", "การออกเสียง", "Pelafalan"],
    "settingsAccent": ["アクセント", "口音", "Acento", "Accent", "Akzent", "Sotaque", "Giọng", "สำเนียง", "Aksen"],
    "settingsVoice": ["声", "声音", "Voz", "Voix", "Stimme", "Voz", "Giọng đọc", "เสียง", "Suara"],
    "settingsVoiceDefault": ["標準", "默认", "Predeterminada", "Par défaut", "Standard", "Padrão", "Mặc định", "ค่าเริ่มต้น", "Bawaan"],
    "settingsSpeed": ["速さ", "速度", "Velocidad", "Vitesse", "Tempo", "Velocidade", "Tốc độ", "ความเร็ว", "Kecepatan"],
    "settingsSpeedSlow": ["ゆっくり", "慢", "Lenta", "Lente", "Langsam", "Lenta", "Chậm", "ช้า", "Lambat"],
    "settingsSpeedNormal": ["ふつう", "正常", "Normal", "Normale", "Normal", "Normal", "Vừa", "ปกติ", "Normal"],
    "settingsSpeedFast": ["速く", "快", "Rápida", "Rapide", "Schnell", "Rápida", "Nhanh", "เร็ว", "Cepat"],
    "settingsRecorded": ["単語は人の録音で", "单词用真人录音", "Grabaciones humanas para palabras", "Enregistrements humains pour les mots", "Menschliche Aufnahmen für Wörter", "Gravações humanas para palavras", "Dùng giọng người thật cho từ", "ใช้เสียงคนจริงสำหรับคำ", "Rekaman manusia untuk kata"],
    "settingsRecordedHelp": ["録音がなければ声で読む", "没有录音时用语音朗读", "Si no hay, usa la voz", "Sinon, utilise la voix", "Sonst liest die Stimme", "Se não houver, usa a voz", "Không có thì dùng giọng đọc", "ถ้าไม่มีจะใช้เสียงอ่าน", "Jika tidak ada, pakai suara"],
    "settingsAbout": ["情報 · 出典", "信息 · 来源", "Acerca de · fuentes", "À propos · sources", "Info · Quellen", "Sobre · fontes", "Thông tin · nguồn", "ข้อมูล · แหล่งที่มา", "Tentang · sumber"],
    "aboutDataSources": ["データの出典", "数据来源", "Fuentes de datos", "Sources des données", "Datenquellen", "Fontes de dados", "Nguồn dữ liệu", "แหล่งข้อมูล", "Sumber data"],
    "aboutUseMeanings": ["意味 · 辞書の例文", "词义 · 词典例句", "Significados · ejemplos del diccionario", "Sens · exemples du dictionnaire", "Bedeutungen · Wörterbuchbeispiele", "Significados · exemplos do dicionário", "Nghĩa · ví dụ từ điển", "ความหมาย · ตัวอย่างจากพจนานุกรม", "Arti · contoh kamus"],
    "aboutUseOnline": ["オンライン辞書", "在线词典", "Diccionario en línea", "Dictionnaire en ligne", "Online-Wörterbuch", "Dicionário online", "Từ điển trực tuyến", "พจนานุกรมออนไลน์", "Kamus daring"],
    "aboutUseExamples": ["訳付きの例文", "带翻译的例句", "Ejemplos traducidos", "Exemples traduits", "Übersetzte Beispiele", "Exemplos traduzidos", "Ví dụ có bản dịch", "ตัวอย่างพร้อมคำแปล", "Contoh terjemahan"],
    "aboutUseRecordings": ["単語の発音録音", "单词发音录音", "Grabaciones de palabras", "Enregistrements des mots", "Wortaufnahmen", "Gravações de palavras", "Bản ghi phát âm từ", "เสียงอ่านคำ", "Rekaman kata"],
    "aboutApp": ["アプリ", "应用", "App", "Appli", "App", "App", "Ứng dụng", "แอป", "Aplikasi"],
    "aboutVersion": ["バージョン", "版本", "Versión", "Version", "Version", "Versão", "Phiên bản", "เวอร์ชัน", "Versi"],
    "aboutLicenses": ["オープンソースライセンス", "开源许可", "Licencias de código abierto", "Licences open source", "Open-Source-Lizenzen", "Licenças de código aberto", "Giấy phép mã nguồn mở", "สัญญาอนุญาตโอเพนซอร์ส", "Lisensi sumber terbuka"],
    "reminderPerDayTotal": ["1日{times}回 · {cards}枚", "每天{times}次 · {cards}张", "{times} al día · {cards} tarjetas", "{times} par jour · {cards} cartes", "{times}× täglich · {cards} Karten", "{times} por dia · {cards} cartões", "{times} lần/ngày · {cards} thẻ", "วันละ {times} ครั้ง · {cards} ใบ", "{times}× sehari · {cards} kartu"],
    "reminderWordsPerAlert": ["1回に", "每次", "Por aviso", "Par rappel", "Pro Erinnerung", "Por lembrete", "Mỗi lần", "ต่อครั้ง", "Per pengingat"],
}

for key, values in T.items():
    assert len(values) == len(LANGS), key

messages = {key: dict(zip(LANGS, values)) for key, values in T.items()}
tmp = pathlib.Path(tempfile.gettempdir()) / "l10n_cards.json"
tmp.write_text(json.dumps(messages, ensure_ascii=False), encoding="utf-8")
root = pathlib.Path(__file__).resolve().parent
subprocess.run([sys.executable, "-X", "utf8", str(root / "l10n_add.py"), str(tmp)], check=True)
