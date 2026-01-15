<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>마이페이지 - CareFinder</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="stylesheet" href="/css/mypage.css">
</head>
<body>

<div class="header">
    <div class="logo" onclick="location.href='/'">
        <i class="fa-solid fa-laptop-medical logo-icon"></i>
        <span class="logo-text">CareFinder</span>
    </div>

    <div class="header-right">
        <div class="user-menu">
            <span class="user-name">
                <i class="fa-regular fa-user"></i> ${userName}님 (${loginType})
            </span>
            <button class="logout-btn-header" onclick="location.href='/nlogout'">
                <i class="fa-solid fa-arrow-right-from-bracket"></i> 로그아웃
            </button>
        </div>
    </div>
</div>

<div class="container">

    <div class="page-header">
        <h2>내 정보 관리</h2>
    </div>

    <div class="card">
        <div class="section-title">기본 정보</div>

        <form action="/mypage/update" method="post">
            <div class="info-row">
                <span>이름</span>
                <input type="text" name="name" value="${name}" required>
            </div>

            <div class="info-row">
                <span>이메일</span>
                <div class="readonly">
                    <i class="fa-regular fa-envelope" style="margin-right:8px; opacity:0.6;"></i> ${email}
                </div>
            </div>

            <div class="info-row">
                <span>휴대폰 번호</span>
                <input type="text"
                       name="phonenumber"
                       value="${empty phonenumber ? '' : phonenumber}"
                       placeholder="010-0000-0000"
                       autocomplete="off">
            </div>

            <c:if test="${param.error == 'phone'}">
                <p class="error-msg">
                    휴대폰 번호는 숫자 11자리여야 합니다.
                </p>
            </c:if>

            <div class="btn-area">
                <button class="btn btn-save" type="submit">수정 완료</button>
            </div>
        </form>

        <div class="withdraw-area">
            <a href="/mypage/withdraw" onclick="return confirmWithdraw();">
                회원탈퇴
            </a>
        </div>
    </div>

</div>

<script src="/js/mypage.js"></script>

</body>
</html>