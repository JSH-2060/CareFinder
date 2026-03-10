# CareFinder

CareFinder는 사용자가 자신의 건강 정보와 생활 상황에 맞춰 필요한 의료·건강 정보를 더 쉽게 찾을 수 있도록 돕는 웹 서비스입니다.  
병원/약국/건강 정보 탐색, 지도 기반 검색, 로그인 및 마이페이지, BMI 및 아동/예방접종 관련 기능 등을 하나의 서비스 안에서 제공하는 것을 목표로 합니다.

## Project Overview

- **Project Name**: CareFinder
- **Type**: Web Application
- **Backend**: Spring Boot
- **Frontend**: JSP, CSS, JavaScript
- **Database Access**: MyBatis
- **Build Tool**: Maven
- **Language**: Java 17

## Tech Stack

### Backend
- Java 17
- Spring Boot 3.4.12
- Spring MVC
- MyBatis 3.0.5
- Lombok
- BCrypt (`spring-security-crypto`)

### Frontend
- JSP
- JSTL
- HTML / CSS / JavaScript

### Database
- MySQL
- Oracle JDBC 지원 포함

### External APIs
- Kakao Login API
- Naver Login API
- Google OAuth API
- Google Maps API
- Kakao Maps API
- TMAP API
- Drug Information API
- Naver News API
- OpenAI API

## Main Features

### 1. 회원 관리 및 로그인
- 일반 회원가입 / 로그인
- 소셜 로그인
  - Google
  - Kakao
  - Naver
- 세션 기반 사용자 인증 처리
- 마이페이지 기능

### 2. 건강 정보 기능
- BMI 관련 기능
- 키/성장 관련 기능
- 아동 관련 기능
- 예방접종 관련 기능
- 약 정보 조회 기능
- 건강/질환 관련 정보 제공 기능

### 3. 지도 기반 의료 탐색
- 지도 API를 활용한 위치 기반 검색
- 병원 / 약국 등 주변 의료 정보 탐색
- 검색 결과를 지도와 함께 시각적으로 확인 가능

### 4. AI / 데이터 연계 기능
- OpenAI API 연동
- 프롬프트 기반 기능 확장 가능
- 뉴스 / 공공데이터 / 약품 정보 API 연동

## Project Structure

```bash
CareFinder
├─ src
│  ├─ main
│  │  ├─ java/com/carefinder
│  │  │  ├─ config
│  │  │  ├─ controller
│  │  │  │  ├─ chatbot
│  │  │  │  ├─ child
│  │  │  │  ├─ google
│  │  │  │  ├─ kakao
│  │  │  │  ├─ map
│  │  │  │  ├─ mypage
│  │  │  │  ├─ naver
│  │  │  │  ├─ record
│  │  │  │  ├─ register
│  │  │  │  ├─ MainContorller.java
│  │  │  │  └─ NormalLoginController.java
│  │  │  ├─ dao
│  │  │  ├─ dto
│  │  │  ├─ service
│  │  │  └─ CareFinderApplication.java
│  │  ├─ resources
│  │  │  ├─ mybatis
│  │  │  ├─ prompts
│  │  │  ├─ static
│  │  │  └─ application.properties
│  │  └─ webapp/WEB-INF/views
│  │     ├─ bmi
│  │     ├─ child
│  │     ├─ common
│  │     ├─ drug
│  │     ├─ heat
│  │     ├─ height
│  │     ├─ map
│  │     ├─ mypage
│  │     ├─ normal_login
│  │     ├─ register
│  │     ├─ vaccine
│  │     └─ index.jsp
├─ pom.xml
├─ mvnw
└─ mvnw.cmd
