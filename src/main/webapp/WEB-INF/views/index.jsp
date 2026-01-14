<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>AI 병원 추천 & 건강 관리</title>

    <!-- 페이지 전용 CSS -->
    <link rel="stylesheet" href="<c:url value='/css/index.css'/>">

    <!-- 공용 CSS -->
    <link rel="stylesheet" href="<c:url value='/css/chatbot.css'/>">
    <link rel="stylesheet" href="<c:url value='/css/toast.css'/>">
</head>
<body>

<!-- =========================
     헤더
========================= -->
<div class="header">
    <c:choose>
        <c:when test="${empty userPk}">
            <button type="button" onclick="location.href='/Nologin'">로그인</button>
        </c:when>
        <c:otherwise>
            <div class="user-menu">
                <span class="user-name" onclick="toggleUserMenu()">
                    ${userName}님 (${loginType}) ▾
                </span>
                <div id="userDropdown" class="user-dropdown">
                    <button type="button" onclick="location.href='/mypage'">마이페이지</button>
                    <button type="button" onclick="location.href='/nlogout'">로그아웃</button>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- =========================
     메인
========================= -->
<div class="main">

    <!-- 중앙 검색 -->
    <div class="center-box">
        <h2>AI 기반 실시간 병원 추천</h2>
        <p style="color:#64748b;">
            증상을 자연스럽게 입력하면 가장 가까운 병원을 추천합니다
        </p>

        <div class="search-box">
            <input
                    type="text"
                    id="aiSearchInput"
                    placeholder="예: 스키 타다 넘어져서 갈비뼈가 아파요"
                    autocomplete="off"
            >
            <button type="button" id="aiSearchBtn">검색</button>
        </div>
    </div>

    <!-- 좌측 하단 메뉴 -->
    <div class="left-bottom">
        <button type="button" class="main-btn" onclick="openModal('hospitalModal')">
            🏥 병원 찾기
        </button>
        <button type="button" class="main-btn" onclick="location.href='/map?mode=emergency'">
            🚨 응급실 찾기
        </button>
        <button type="button" class="main-btn" onclick="location.href='/map?mode=pharmacy'">
            💊 약국 찾기
        </button>
        <button type="button" class="main-btn" onclick="location.href='/drug'">
            📖 의약품 사전
        </button>
        <button type="button"
                class="main-btn"
                style="background:#2563EB"
                onclick="checkLoginAndOpenHealth()">
            📋 가족 건강 관리
        </button>
    </div>
</div>

<!-- =========================
     병원 선택 모달
========================= -->
<div id="hospitalModal" class="modal">
    <div class="modal-content">
        <h3>어떤 병원을 찾으세요?</h3>

        <div style="display:flex; flex-direction:column; gap:10px;">
            <button type="button" class="main-btn" onclick="openDeptModal()">
                일반 병원 (진료과 선택)
            </button>
            <button type="button"
                    class="main-btn"
                    style="background:#059669"
                    onclick="location.href='/map?mode=vet'">
                동물 병원
            </button>
        </div>

        <button type="button" class="modal-close" onclick="closeModal('hospitalModal')">
            닫기
        </button>
    </div>
</div>

<!-- =========================
     진료과 모달
========================= -->
<div id="departmentModal" class="modal">
    <div class="modal-content">
        <h3>진료과를 선택해주세요</h3>

        <div class="dept-grid">
            <button class="dept-btn" onclick="goMap('내과')">내과</button>
            <button class="dept-btn" onclick="goMap('이비인후과')">이비인후과</button>
            <button class="dept-btn" onclick="goMap('정형외과')">정형외과</button>
            <button class="dept-btn" onclick="goMap('소아청소년과')">소아과</button>
            <button class="dept-btn" onclick="goMap('피부과')">피부과</button>
            <button class="dept-btn" onclick="goMap('안과')">안과</button>
            <button class="dept-btn" onclick="goMap('치과')">치과</button>
            <button class="dept-btn" onclick="goMap('산부인과')">산부인과</button>
            <button class="dept-btn" onclick="goMap('비뇨의학과')">비뇨기과</button>
            <button class="dept-btn" onclick="goMap('정신건강의학과')">정신과</button>
        </div>

        <button type="button"
                class="main-btn"
                style="padding:10px; font-size:14px"
                onclick="goMap('')">
            전체 병원 보기
        </button>

        <button type="button" class="modal-close" onclick="closeModal('departmentModal')">
            취소
        </button>
    </div>
</div>

<!-- =========================
     건강 관리 모달
========================= -->
<div id="healthModal" class="modal">
    <div class="modal-content">
        <h3>어떤 기록을 관리할까요?</h3>

        <button class="health-btn"
                style="background:#e0f2fe; color:#0284c7"
                onclick="location.href='/heat/select'">
            체온 관리
        </button>

        <button class="health-btn"
                style="background:#f0fdf4; color:#16a34a"
                onclick="location.href='/vaccine/select'">
            백신 접종
        </button>

        <button class="health-btn"
                style="background:#fff7ed; color:#ea580c"
                onclick="location.href='/bmi/select'">
            BMI (비만도)
        </button>

        <button class="health-btn"
                style="background:#e6fffa; color:#0f766e"
                onclick="location.href='/height/select'">
            키 성장 기록
        </button>

        <button type="button" class="modal-close" onclick="closeModal('healthModal')">
            닫기
        </button>
    </div>
</div>

<!-- =========================
     JS 영역
========================= -->
<script>
    // 로그인 여부 (JSP → JS 전달)
    const isLoggedIn = ${not empty userPk ? 'true' : 'false'};
</script>

<script src="<c:url value='/js/index.js'/>"></script>
<script src="<c:url value='/js/chatbot.js'/>"></script>
<script src="<c:url value='/js/index-ai-search.js'/>"></script>
<script src="<c:url value='/js/map-chatbot-init.js'/>"></script>

<!-- 챗봇 -->
<jsp:include page="common/chatbot.jsp"/>

<div id="toast" class="toast"></div>

</body>
</html>
