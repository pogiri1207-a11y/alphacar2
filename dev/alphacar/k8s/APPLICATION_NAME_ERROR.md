# Application Name 에러 해결

## 에러 메시지
```
Application.argoproj.io " alphacar-main-backend" is invalid: 
metadata.name: Invalid value: " alphacar-main-backend": 
a lowercase RFC 1123 subdomain must consist of lower case alphanumeric characters, 
'-' or '.', and must start and end with an alphanumeric character
```

## 원인
**Application Name에 공백이 포함되어 있습니다!**

에러 메시지를 보면:
- ❌ `" alphacar-main-backend"` (앞에 공백)
- ✅ `"alphacar-main-backend"` (공백 없음)

## Kubernetes 리소스 이름 규칙

Application Name은 Kubernetes 리소스 이름 규칙을 따라야 합니다:

### 허용되는 문자
- 소문자 알파벳: `a-z`
- 숫자: `0-9`
- 하이픈: `-`
- 점: `.`

### 허용되지 않는 문자
- ❌ 공백 (스페이스)
- ❌ 대문자
- ❌ 특수문자 (`_`, `@`, `#` 등)

### 규칙
- 알파벳 또는 숫자로 시작해야 함
- 알파벳 또는 숫자로 끝나야 함
- 중간에 하이픈(`-`) 또는 점(`.`) 사용 가능

## 해결 방법

### 올바른 Application Name
```
alphacar-main-backend
```

### 주의사항
1. **앞뒤 공백 제거**
   - 입력 필드에 붙여넣기 시 공백이 포함되지 않도록 주의
   - 수동으로 입력하는 것이 더 안전

2. **대문자 사용 안 함**
   - `Alphacar-Main-Backend` ❌
   - `alphacar-main-backend` ✅

3. **특수문자 사용 안 함**
   - `alphacar_main_backend` ❌ (언더스코어)
   - `alphacar-main-backend` ✅ (하이픈)

## Application 다시 생성

### 1단계: Application Name 입력
- **Application Name**: `alphacar-main-backend`
- 앞뒤 공백 없이 정확히 입력
- 복사-붙여넣기 시 공백 확인

### 2단계: 나머지 정보 입력
- Repository URL: `https://github.com/pogiri1207-a11y/alphacar.git`
- Revision: `main`
- Path: `k8s/services/main-backend`
- Namespace: `alphacar`

### 3단계: CREATE 버튼 클릭

## 올바른 Application Name 예시

### ✅ 올바른 이름
```
alphacar-main-backend
alphacar-backend
alphacar-frontend
alphacar-main
backend-service
frontend-app
```

### ❌ 잘못된 이름
```
 alphacar-main-backend    (앞에 공백)
alphacar-main-backend     (뒤에 공백)
Alphacar-Main-Backend    (대문자)
alphacar_main_backend    (언더스코어)
alphacar@main-backend    (특수문자)
-alphacar-main-backend   (하이픈으로 시작)
alphacar-main-backend-   (하이픈으로 끝남)
```

## 체크리스트

Application 생성 시:
- [ ] Application Name에 공백 없음
- [ ] 소문자만 사용
- [ ] 하이픈(`-`)만 사용 (언더스코어 `_` 사용 안 함)
- [ ] 알파벳 또는 숫자로 시작
- [ ] 알파벳 또는 숫자로 끝남

## 빠른 참조

### 올바른 입력값
```
Application Name: alphacar-main-backend
Repository URL: https://github.com/pogiri1207-a11y/alphacar.git
Revision: main
Path: k8s/services/main-backend
Namespace: alphacar
```

### 복사-붙여넣기 시 주의
- 텍스트를 복사할 때 앞뒤 공백이 포함되지 않도록 주의
- 입력 필드에 붙여넣은 후 앞뒤 공백 확인
- 수동으로 입력하는 것이 가장 안전

