# Supabase 설정 가이드

이 앱은 **Supabase 설정 없이도 로컬 모드로 즉시 실행**됩니다.
아래 단계를 완료하면 **로그인 + 기기 간 클라우드 동기화**가 활성화됩니다.

---

## 현재 동작 방식
- `SUPABASE_URL` / `SUPABASE_ANON_KEY` 가 주입되면 → `Supabase.initialize()` 성공 → **클라우드 모드** (로그인 시 동기화)
- 미설정이면 → **로컬 모드** (SharedPreferences 저장, 앱은 정상 동작)

즉, 지금 상태로도 단어장·예문 복습·알람·TTS가 모두 동작합니다.
클라우드 동기화만 아래 설정 후 켜집니다.

---

## 1. Supabase 프로젝트 생성
1. https://supabase.com 접속 → **New project**
2. 프로젝트 이름(예: `wordcloud-vocab`)·DB 비밀번호·리전 선택
3. 생성 후 **Project Settings → API** 에서 다음을 복사:
   - **Project URL** (`https://xxxx.supabase.co`)
   - **anon / publishable key** (`eyJhbGciOi...`)

## 2. 앱에 키 주입
두 가지 방법 중 하나 (키를 소스에 남기지 않으려면 1번 권장):

**방법 A — 실행 시 --dart-define (권장)**
```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
```
빌드 시에도 동일하게 전달:
```powershell
flutter build apk --release `
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
```

**방법 B — 소스에 직접 입력 (간편)**
`lib/supabase_config.dart` 의 `defaultValue` 에 값을 채워 넣습니다.

## 3. 데이터베이스 테이블 + 보안 규칙(RLS)
Supabase 대시보드 → **SQL Editor** 에 아래를 실행하세요.
전체 객체는 jsonb `data` 컬럼에 저장하고, 인덱스·RLS용 키만 별도 컬럼으로 둡니다.

```sql
-- 단어장
create table public.wordbooks (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

-- 단어
create table public.words (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  wordbook_id text not null,
  data jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index words_wordbook_idx on public.words (wordbook_id);

-- 학습 기록 (복습 1문제당 1건, 일일 통계용)
create table public.study_logs (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  data jsonb not null,
  studied_at timestamptz not null default now()
);

create index study_logs_studied_idx on public.study_logs (owner_id, studied_at);

-- RLS 활성화
alter table public.wordbooks enable row level security;
alter table public.words enable row level security;
alter table public.study_logs enable row level security;

-- 본인 소유 행만 접근
create policy "own wordbooks" on public.wordbooks
  for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy "own words" on public.words
  for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy "own study_logs" on public.study_logs
  for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

-- 공유·탐색 (3단계): shared/public 단어장과 그 단어는 다른 로그인 사용자도 읽기 가능
-- (앱의 탐색 탭·공유 코드 가져오기에 필요. 쓰기는 여전히 소유자만.)
create policy "read shared wordbooks" on public.wordbooks
  for select using (data->>'visibility' in ('shared', 'public'));

create policy "read shared words" on public.words
  for select using (
    exists (
      select 1 from public.wordbooks b
      where b.id = words.wordbook_id
        and b.data->>'visibility' in ('shared', 'public')
    )
  );
```

> 이미 테이블을 만들어 둔 프로젝트라면 `study_logs` 블록과
> "공유·탐색" 정책 2개만 추가로 실행하면 됩니다.

## 4. 인증(Authentication) 설정
대시보드 → **Authentication → Providers**:
- **Email**: 기본 활성. 테스트 편의를 위해 **Confirm email** 을 꺼두면 가입 즉시 로그인됩니다.
- **Google** (선택): 활성화 후 Google Cloud OAuth 클라이언트의 Client ID/Secret 입력.
  - 대시보드 → **Authentication → URL Configuration → Redirect URLs** 에
    `io.supabase.wordcloud://login-callback/` 를 추가하세요.
  - 이 스킴은 `android/app/src/main/AndroidManifest.xml` 의 intent-filter,
    `lib/supabase_config.dart` 의 `oauthRedirect` 와 일치해야 합니다.

## 5. 실행 확인
키를 주입해 실행하면 홈 상단 배지가 **☁ 동기화** 로 바뀌고,
설정 → 계정에서 로그인하면 기기 간 동기화가 켜집니다.
(미주입 시 **📴 로컬** 배지로 로컬 모드 동작.)

---

## 데이터 구조 (논리 모델)
```
wordbooks/{id}            ← data: Wordbook.toMap()
words/{id}                ← data: Word.toMap(), wordbook_id 로 묶임
study_logs/{id}           ← data: StudyLog.toMap(), studied_at 으로 조회
```
앱의 `Wordbook.toMap()` / `Word.toMap()` / `StudyLog.toMap()` 결과가
그대로 `data` jsonb 에 저장됩니다.

## 공유·탐색 동작 방식
- 단어장 메뉴 → **공유·공개 설정**에서 `비공개 / 코드 공유 / 공개`를 고릅니다.
- **코드 공유**: 공유 코드(단어장 id)를 아는 사람만 탐색 탭에서 가져올 수 있음
- **공개**: 탐색 탭의 공개 단어장 목록에 노출, 누구나 복제 가능
- 가져오기는 **복제**(새 id, 학습 상태 초기화) 방식 — 원본과 분리되며 공동 편집은 아님

## 다음 단계 (로드맵 3단계 이후)
- 서버발 복습 리마인드 → Supabase Edge Functions + `pg_cron`
- 단어장 공동 편집 → `members(역할: editor/viewer)` 테이블 + 초대 정책
- 고품질 클라우드 TTS 옵션
