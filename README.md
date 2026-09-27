# Cloudflare Test Server

Astro 정적 사이트와 Cloudflare Pages Functions의 Hono API를 한 Pages 프로젝트로 배포하는 예제입니다. Hono API는 Drizzle ORM을 통해 Cloudflare D1에 접근합니다.

## 로컬 실행

Node.js 22 이상이 필요합니다.

```sh
npm install
npm run db:generate
npm run db:migrate:local
npm run dev
```

`npm run dev`는 Astro 페이지를 빌드하고 Hono Pages Function과 D1 로컬 에뮬레이터를 시작합니다. 브라우저에서 `http://localhost:8788`을 열고 `/api/health` 또는 `/api/notes`를 확인할 수 있습니다. 화면 코드를 수정한 뒤에는 별도 터미널에서 `npm run build`를 실행해 정적 파일을 갱신합니다. Wrangler는 로컬 D1 데이터를 `.wrangler/`에 저장합니다. `npm run dev:astro`는 Astro 화면만 빠르게 볼 때 사용하며 Hono API는 제공하지 않습니다.

## D1 마이그레이션

스키마를 바꾼 뒤 마이그레이션 SQL을 생성하고 로컬 DB에 적용합니다.

```sh
npm run db:generate
npm run db:migrate:local
```

원격 D1 DB에 적용하려면 Cloudflare 인증 후 다음 명령을 실행합니다.

```sh
npm run db:migrate:remote
```

## 배포

`wrangler.jsonc`에 Cloudflare Pages 프로젝트와 D1 데이터베이스가 설정되어 있습니다.

```sh
npm run deploy
```

GitHub 자동 배포를 사용하려면 Cloudflare 대시보드에서 **Workers & Pages → Create application → Pages → Connect to Git**을 선택하고 이 저장소를 연결합니다. 빌드 명령은 `npm run build`, 출력 디렉터리는 `dist`입니다. `wrangler.jsonc`가 배포 설정의 기준이므로 Cloudflare 대시보드의 D1 바인딩도 `DB` 이름으로 맞춰야 합니다.

## API

- `GET /api/health` — Pages Function과 D1 연결 확인
- `GET /api/notes` — 메모 목록
- `POST /api/notes` — `{ "content": "메모 내용" }` 저장 (1~240자)
