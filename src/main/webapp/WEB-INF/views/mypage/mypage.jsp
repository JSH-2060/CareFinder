<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>마이페이지</title>

    <!-- CSS -->
    <link rel="stylesheet" href="/css/mypage.css">
</head>
<body>

<div class="container">

    <!-- 상단 바 -->
    <div class="top-bar">
        <h2>👤 마이페이지</h2>
        <button class="home-btn" onclick="goHome()">홈</button>
    </div>

    <!-- 내 정보 -->
    <div class="card">
        <div class="section-title">내 정보</div>

        <form action="/mypage/update" method="post">

            <div class="info-row">
                <span>이름</span>
                <input type="text" name="name" value="${name}" required>
            </div>

            <div class="info-row">
                <span>이메일</span>
                <span class="readonly">${email}</span>
            </div>

            <div class="info-row">
                <span>휴대폰 번호</span>
                <input type="text"
                       name="phonenumber"
                       value="${empty phonenumber ? '' : phonenumber}"
                       placeholder="01012345678 또는 010-1234-5678">
            </div>

            <c:if test="${param.error == 'phone'}">
                <p class="error-msg">
                    휴대폰 번호는 숫자 11자리여야 합니다.
                </p>
            </c:if>

            <div class="btn-area">
                <button class="btn btn-save" type="submit">정보 저장</button>
            </div>
        </form>

        <!-- 회원탈퇴 -->
        <div class="withdraw-area">
            <a href="/mypage/withdraw" onclick="return confirmWithdraw();">
                회원탈퇴
            </a>
        </div>
    </div>

</div>

<!-- JS -->
<script src="/js/mypage.js"></script>
</body>
</html>
