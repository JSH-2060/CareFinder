<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>CareFinder</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="stylesheet" href="<c:url value='/css/chatbot.css'/>">
    <link rel="stylesheet" href="<c:url value='/css/toast.css'/>">
    <link rel="stylesheet" href="<c:url value='/css/index.css'/>">
</head>
<body>

<div class="header">
    <div class="logo" onclick="location.href='/'">
        <i class="fa-solid fa-laptop-medical logo-icon"></i>
        <span class="logo-text">CareFinder</span>
    </div>

    <div class="header-right">
        <c:choose>
            <c:when test="${empty userPk}">
                <button type="button" class="login-btn" onclick="location.href='/Nologin'">로그인</button>
            </c:when>
            <c:otherwise>
                <div class="user-menu">
                    <span class="user-name" onclick="toggleUserMenu()">
                        ${userName}님 (${loginType}) <i class="fa-solid fa-chevron-down" style="font-size: 12px; margin-left: 5px;"></i>
                    </span>
                    <div id="userDropdown" class="user-dropdown">
                        <button onclick="location.href='/mypage'"><i class="fa-regular fa-user"></i> 마이페이지</button>
                        <button onclick="location.href='/nlogout'"><i class="fa-solid fa-arrow-right-from-bracket"></i> 로그아웃</button>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<div class="hero-section">
    <div class="hero-content">
        <h2>AI 기반 스마트 병원 추천</h2>
        <p>증상을 자연스럽게 입력하면 가장 가까운 병원을 추천합니다</p>

        <div class="search-box">
            <input type="text" id="aiSearchInput" placeholder="예: 숨 쉴 때 옆구리가 아픈데 어디 병원을 가야 하나요?" autocomplete="off">
            <button id="aiSearchBtn">검색</button>
        </div>
    </div>
</div>

<div class="icon-menu-container">
    <div class="icon-menu">
        <button class="icon-item" onclick="openModal('hospitalModal')">
            <i class="fa-solid fa-stethoscope icon-img" style="color: #0ea5e9;"></i>
            <span>병원 찾기</span>
        </button>
        <button class="icon-item" onclick="location.href='/map?mode=emergency'">
            <i class="fa-solid fa-truck-medical icon-img" style="color: #ef4444;"></i>
            <span>응급실</span>
        </button>
        <button class="icon-item" onclick="location.href='/map?mode=pharmacy'">
            <i class="fa-solid fa-pills icon-img" style="color: #10b981;"></i>
            <span>약국</span>
        </button>
        <button class="icon-item" onclick="checkLoginAndOpenHealth()">
            <i class="fa-solid fa-calendar-check icon-img" style="color: #f59e0b;"></i>
            <span>건강 관리</span>
        </button>
        <button class="icon-item" onclick="location.href='/drug'">
            <i class="fa-solid fa-book-medical icon-img" style="color: #8b5cf6;"></i>
            <span>의약품 사전</span>
        </button>
    </div>
</div>

<div class="info-section section-gray clickable medicine-bg">
    <div class="info-container">
        <div class="info-text">
            <span class="info-tag">SMART DICTIONARY</span>
            <h3>처방받은 약,<br>정확히 알고 드시나요?</h3>
            <p>
                이 약이 어떤 효능이 있는지, 부작용은 없는지 궁금하셨죠?<br>
                약 이름, 혹은 모양을 검색해보세요. <br>
                복용 방법부터 효능, 주의사항까지 필요한 약 정보를 쉽게 확인할 수 있어요.
            </p>
            <button class="info-btn" onclick="location.href='/drug'">
                <i class="fa-solid fa-book-medical" style="margin-right:8px;"></i>
                의약품 사전 바로가기
            </button>
        </div>

        <div class="info-visual">
            <div class="feature-card card-drug" onclick="location.href='/drug'">
                <i class="fa-solid fa-tablets feature-icon" style="color: #8B5CF6;"  onclick="location.href='/drug'"></i>
                <h4>스마트 의약품 검색</h4>
                <p>4만여 개의 의약품 정보<br>실시간 데이터베이스 연동</p>
            </div>
        </div>
    </div>
</div>
<br>
<br>
<br>
<br>
<div class="info-section section-white clickable family-bg">
    <div class="info-container row-reverse">
        <div class="info-text">
            <span class="info-tag tag-green">FAMILY CARE</span>
            <h3>우리 가족 건강 기록,<br>이제 한 곳에서 관리하세요</h3>
            <p>
                아이의 체온 변화부터 예방접종 일정, 키 성장 기록까지.<br>
                흩어져 있던 가족들의 건강 데이터를 안전하게 보관하고<br>
                그래프로 변화를 한눈에 확인하세요.
            </p>
            <button class="info-btn" style="background-color: #10B981;" onclick="checkLoginAndOpenHealth()">
                <i class="fa-solid fa-heart-pulse" style="margin-right:8px;"></i> 내 건강기록 보기
            </button>
        </div>
        <div class="info-visual">
            <div class="feature-card card-health" onclick="checkLoginAndOpenHealth()">
                <i class="fa-solid fa-user-doctor feature-icon" style="color: #10B981;" ></i>
                <h4>통합 건강 관리</h4>
                <p>체온 · BMI · 예방접종 · 성장<br>맞춤형 헬스케어 대시보드</p>
            </div>
        </div>
    </div>
</div>
<%----------------------------------------------짭봇 -------------------------------------%>
<button class="chatbot-toggle-btn" id="floatingChatbotBtn" onclick="connectChatbotToggle()">
    <i class="fa-solid fa-robot"></i>
</button>

<div id="hospitalModal" class="modal">
    <div class="modal-content">
        <h3 style="margin-top:0; color:white; margin-bottom: 20px;">어떤 병원을 찾으세요?</h3>
        <div style="display: flex; flex-direction: column; gap: 10px;">
            <button type="button" class="main-btn" onclick="openDeptModal()"> 일반 병원 (진료과 선택)</button>
            <button type="button" class="main-btn" style="background: #059669;" onclick="location.href='/map?mode=vet'"> 동물 병원</button>
        </div>
        <button type="button" class="modal-close" onclick="closeModal('hospitalModal')">닫기</button>
    </div>
</div>

<div id="departmentModal" class="modal">
    <div class="modal-content">
        <h3 style="margin-top:0; color:whitesmoke; margin-bottom: 20px;">진료과를 선택해주세요</h3>
        <div class="dept-grid">
            <button type="button" class="dept-btn" onclick="goMap('내과')">내과</button>
            <button type="button" class="dept-btn" onclick="goMap('이비인후과')">이비인후과</button>
            <button type="button" class="dept-btn" onclick="goMap('정형외과')">정형외과</button>
            <button type="button" class="dept-btn" onclick="goMap('성형외과')">성형외과</button>
            <button type="button" class="dept-btn" onclick="goMap('소아청소년과')">소아과</button>
            <button type="button" class="dept-btn" onclick="goMap('피부과')">피부과</button>
            <button type="button" class="dept-btn" onclick="goMap('안과')">안과</button>
            <button type="button" class="dept-btn" onclick="goMap('치과')">치과</button>
            <button type="button" class="dept-btn" onclick="goMap('산부인과')">산부인과</button>
            <button type="button" class="dept-btn" onclick="goMap('비뇨의학과')">비뇨기과</button>
            <button type="button" class="dept-btn" onclick="goMap('신경과')">신경과</button>
            <button type="button" class="dept-btn" onclick="goMap('정신건강의학과')">정신건강의학과</button>
        </div>
        <button type="button" class="main-btn" style="padding: 10px; font-size: 14px; background: #64748b;" onclick="goMap('')">전체 병원 보기</button>
        <button type="button" class="modal-close" onclick="closeModal('departmentModal')">취소</button>
    </div>
</div>

<div id="healthModal" class="modal">
    <div class="modal-content">
        <h3 style="margin-top:0; color:#fff; margin-bottom: 20px;">어떤 기록을 관리할까요?</h3>
        <button type="button" class="health-btn" style="background: #e0f2fe; color: #0284c7;" onclick="location.href='/heat/select'">
            <i class="fa-solid fa-temperature-half"></i> 체온 관리
        </button>
        <button type="button" class="health-btn" style="background: #f0fdf4; color: #16a34a;" onclick="location.href='/vaccine/select'">
            <i class="fa-solid fa-syringe"></i> 백신 접종
        </button>
        <button type="button" class="health-btn" style="background: #fff7ed; color: #ea580c;" onclick="location.href='/bmi/select'">
            <i class="fa-solid fa-weight-scale"></i> BMI (비만도)
        </button>
        <button type="button" class="health-btn" style="background: #f0fdfa; color: #0d9488;" onclick="location.href='/height/select'">
            <i class="fa-solid fa-ruler-vertical"></i> 키 성장 기록
        </button>
        <button type="button" class="modal-close" onclick="closeModal('healthModal')">닫기</button>
    </div>
</div>

<script>
    // JSP 변수는 여기서 전역 변수로 선언해야 외부 JS파일에서 사용 가능
    const isLoggedIn = ${not empty userPk ? 'true' : 'false'};
</script>

<jsp:include page="common/chatbot.jsp"/>
<script src="/js/chatbot.js"></script>
<script src="/js/index-ai-search.js"></script>
<script src="/js/map-chatbot-init.js"></script>
<script src="/js/index.js"></script> <div id="toast" class="toast"></div>

</body>
</html>