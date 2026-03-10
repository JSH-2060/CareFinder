# CareFinder

CareFinder는 사용자가 자신의 건강 상태와 상황에 맞는 의료·건강 정보를 더 쉽고 빠르게 찾을 수 있도록 돕기 위해 만든 웹 서비스입니다.  
병원 및 약국 탐색, 건강 정보 확인, BMI 및 성장 관리, 예방접종 정보 확인 등 여러 기능을 한곳에서 제공하여  
사용자 중심의 헬스케어 플랫폼을 만드는 것을 목표로 합니다.

---

## 1. 프로젝트 개요

기존의 의료 정보 서비스는 필요한 정보를 찾기까지 과정이 복잡하거나, 정보가 분산되어 있어 사용성이 떨어지는 경우가 많았습니다.  
CareFinder는 이러한 불편함을 줄이고, 사용자가 건강과 관련된 다양한 정보를 한 번에 탐색할 수 있도록 만들었습니다.

이 프로젝트는 다음과 같은 목적을 가지고 개발되었습니다.

- 병원, 약국, 건강 정보를 한곳에서 통합 제공
- 위치 기반 탐색 기능을 통해 사용자 편의성 향상
- BMI, 성장, 예방접종 등 건강 관리 기능 제공
- 소셜 로그인과 마이페이지를 통한 사용자 맞춤 서비스 제공
- 외부 API 및 AI 기능을 활용한 확장성 있는 서비스 구현

---

## 2. 기술 스택

### Frontend
- JSP
- HTML
- CSS
- JavaScript
- JSTL

### Backend
- Java 17
- Spring Boot
- Spring MVC
- MyBatis
- Lombok
- BCrypt

### Database
- MySQL

### External API
- Kakao Login API
- Naver Login API
- Google OAuth API
- Kakao Map API
- Google Map API
- TMAP API
- Drug Information API
- Naver News API
- OpenAI API

### Build / Tool
- Maven
- GitHub

### Deployment
- 로컬 환경 및 서버 배포를 고려한 Spring Boot 기반 구조
- 환경변수 기반 API Key 및 DB 설정 분리

---

## 3. 기능 요약

### 1) 회원가입 및 로그인
- 일반 로그인 및 회원가입 지원
- Kakao / Naver / Google 소셜 로그인 지원
- 세션 기반 사용자 인증 처리

### 2) 지도 기반 병원·약국 탐색
- 지도 API를 활용한 위치 기반 탐색
- 주변 병원 및 약국 검색 가능
- 사용자가 원하는 의료 정보를 직관적으로 확인 가능

### 3) 건강 정보 관리
- BMI 계산 및 관리 기능
- 키/성장 관련 정보 제공
- 아동 건강 관련 기능 지원

### 4) 예방접종 및 약 정보 조회
- 예방접종 관련 정보 확인
- 약 관련 정보 조회 가능
- 건강 관리에 필요한 기초 정보 제공

### 5) 마이페이지 및 사용자 맞춤 기능
- 사용자 정보 조회 및 관리
- 개인 건강 기록과 연계 가능한 구조
- 향후 AI 추천 기능 확장 가능

---

## 4. 설치 방법

### 1) 저장소 클론
```bash
git clone https://github.com/JSH-2060/CareFinder.git
cd CareFinder
