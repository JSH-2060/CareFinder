<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>AI 병원 추천</title>
    <style>
        body { margin: 0; font-family: 'Pretendard', sans-serif; background: #F0F4F8; height: 100vh; }

        /* 헤더 스타일 */
        .header { height: 70px; background: #E0F2FE; display: flex; justify-content: flex-end; align-items: center; padding: 0 24px; }
        .header span { margin-right: 12px; font-weight: 600; color: #1E3A8A; }
        .header button { padding: 8px 18px; border-radius: 10px; border: none; background: #1E3A8A; color: #fff; cursor: pointer; font-weight: bold; }

        .main { position: relative; height: calc(100vh - 70px); }
        .center-box { position: absolute; top: 30%; left: 50%; transform: translate(-50%, -50%); text-align: center; width: 60%; }
        .center-box h2 { font-size: 32px; margin-bottom: 10px; color: #1e293b; }
        .search-box input { width: 100%; height: 78px; border-radius: 999px; border: none; padding: 0 36px; font-size: 18px; background: linear-gradient(135deg, #2563EB, #1E40AF); color: white; box-shadow: 0 10px 25px rgba(37, 99, 235, 0.3); }

        /* 좌측 하단 메뉴바 */
        .left-bottom { position: absolute; left: 24px; bottom: 24px; width: 240px; display: flex; flex-direction: column; gap: 10px; }
        .main-btn { width: 100%; padding: 16px 0; border-radius: 14px; border: none; background: #1E3A8A; color: white; font-size: 15px; font-weight: bold; cursor: pointer; box-shadow: 0 4px 6px rgba(0,0,0,0.1); transition: 0.2s; }
        .main-btn:hover { background: #1e40af; transform: translateY(-2px); }

        /* 모달 공통 스타일 */
        .modal { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.5); justify-content: center; align-items: center; z-index: 1000; }
        .modal-content { background: white; padding: 24px; border-radius: 16px; width: 400px; text-align: center; }
        .modal-close { background: #f1f5f9; color: #334155; margin-top: 15px; width: 100%; padding: 12px; border: none; border-radius: 10px; cursor: pointer; font-weight: bold; font-size: 1rem; }
        .modal-close:hover { background: #e2e8f0; }

        /* 진료과 그리드 레이아웃 (2열) */
        .dept-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 10px; }
        .dept-btn {
            padding: 12px; border-radius: 10px; border: 1px solid #e2e8f0;
            background: white; color: #1e293b; font-weight: 600; cursor: pointer; transition: 0.2s;
        }
        .dept-btn:hover { background: #eff6ff; border-color: #2563EB; color: #2563EB; }
    </style>
</head>
<body>

<div class="header">
    <c:choose>
        <c:when test="${empty userPk}">
            <button type="button" onclick="location.href='/Nologin'">로그인</button>
        </c:when>
        <c:otherwise>
            <span>${userName}님 (${loginType})</span>
            <button type="button" onclick="location.href='/nlogout'">로그아웃</button>
        </c:otherwise>
    </c:choose>
</div>

<div class="main">
    <div class="center-box">
        <h2>AI 기반 실시간 병원 추천</h2>
        <p style="color:#64748b;">
            증상을 자연스럽게 입력하면 가장 가까운 병원을 추천합니다
        </p>
        <div class="search-box" style="position: relative;">
            <input
                    type="text"
                    id="aiSearchInput"
                    placeholder="예: 스키 타다 넘어져서 갈비뼈가 아파요"
                    autocomplete="off"
            >
            <button
                    type="button"
                    id="aiSearchBtn"
                    style="
            position:absolute;
            right:12px;
            top:50%;
            transform:translateY(-50%);
            padding:12px 20px;
            border:none;
            border-radius:999px;
            background:#1E40AF;
            color:white;
            font-weight:bold;
            cursor:pointer;
        "
            >
                검색
            </button>
        </div>


    </div>

    <!-- 공통 챗봇 -->
    <div id="chatbot-container"></div>

    <script src="/js/chatbot.js"></script>
    <script src="/js/index-ai-search.js"></script>


    <div class="left-bottom">
        <button type="button" class="main-btn" onclick="openModal('hospitalModal')">🏥 병원 찾기</button>
        <button type="button" class="main-btn" onclick="location.href='/map?mode=emergency'">🚨 응급실 찾기</button>
        <button type="button" class="main-btn" onclick="location.href='/map?mode=pharmacy'">💊 약국 찾기</button>
        <button type="button" class="main-btn" onclick="location.href='/drug'">📖 의약품 사전</button>
        <button type="button" id="goMyRecordBtn" class="main-btn" style="background: #2563EB;">📋 건강 관리 (열/백신/BMI)</button>
    </div>
</div>

<div id="hospitalModal" class="modal">
    <div class="modal-content">
        <h3 style="margin-top:0; color:#1e293b; margin-bottom: 20px;">어떤 병원을 찾으세요?</h3>
        <div style="display: flex; flex-direction: column; gap: 10px;">
            <button type="button" class="main-btn" onclick="openDeptModal()"> 일반 병원 (진료과 선택)</button>
            <button type="button" class="main-btn" style="background: #059669;" onclick="location.href='/map?mode=vet'"> 동물 병원</button>
        </div>
        <button type="button" class="modal-close" onclick="closeModal('hospitalModal')">닫기</button>
    </div>
</div>

<div id="departmentModal" class="modal">
    <div class="modal-content">
        <h3 style="margin-top:0; color:#1e293b; margin-bottom: 20px;">진료과를 선택해주세요</h3>

        <div class="dept-grid">
            <button type="button" class="dept-btn" onclick="goMap('내과')">내과</button>
            <button type="button" class="dept-btn" onclick="goMap('이비인후과')">이비인후과</button>
            <button type="button" class="dept-btn" onclick="goMap('정형외과')">정형외과</button>
            <button type="button" class="dept-btn" onclick="goMap('소아청소년과')">소아과</button>
            <button type="button" class="dept-btn" onclick="goMap('피부과')">피부과</button>
            <button type="button" class="dept-btn" onclick="goMap('안과')">안과</button>
            <button type="button" class="dept-btn" onclick="goMap('치과')">치과</button>
            <button type="button" class="dept-btn" onclick="goMap('산부인과')">산부인과</button>
            <button type="button" class="dept-btn" onclick="goMap('비뇨의학과')">비뇨기과</button>
            <button type="button" class="dept-btn" onclick="goMap('정신건강의학과')">정신과</button>
        </div>

        <button type="button" class="main-btn" style="padding: 10px; font-size: 14px;" onclick="goMap('')">전체 병원 보기</button>
        <button type="button" class="modal-close" onclick="closeModal('departmentModal')">취소</button>
    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const isLoggedIn = ${not empty userPk ? 'true' : 'false'};
        const recordBtn = document.getElementById("goMyRecordBtn");

        if(recordBtn) {
            recordBtn.onclick = function() {
                if(isLoggedIn) location.href = '/heat/select';
                else {
                    alert("로그인이 필요한 서비스입니다.");
                    location.href = '/Nologin';
                }
            };
        }

        window.onclick = function(e) {
            if(e.target.classList.contains('modal')) e.target.style.display = "none";
        }
    });

    function openModal(id) { document.getElementById(id).style.display = 'flex'; }
    function closeModal(id) { document.getElementById(id).style.display = 'none'; }

    function openDeptModal() {
        closeModal('hospitalModal');
        openModal('departmentModal');
    }

    // ★★★ [중요 수정] map.jsp가 'type'을 받으므로 파라미터 이름을 변경했습니다 ★★★
    function goMap(typeVal) {
        let url = '/map?mode=hospital';
        if(typeVal) {
            // keyword 대신 type으로 보내야 map.jsp가 인식합니다.
            url += '&type=' + encodeURIComponent(typeVal);
        }
        location.href = url;
    }
</script>
</body>
</html>