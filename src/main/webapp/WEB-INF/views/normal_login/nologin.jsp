<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인</title>

    <!-- 외부 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/nologin.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>

<body>

    <div class="header">
        <div class="logo" onclick="location.href='/'">
            <i class="fa-solid fa-laptop-medical logo-icon"></i>
            <span class="logo-text">CareFinder</span>
        </div>


    </div>



<div class="login-box">

    <h2>로그인</h2>
    <p class="desc">로그인을 하시면 여러 추가 기능을 이용하실 수 있습니다.</p>

    <!-- 로그인 실패 메시지 -->
    <c:if test="${param.error != null}">
        <div class="error-msg">
            아이디 또는 비밀번호가 틀렸습니다.
        </div>
    </c:if>

    <!-- 일반 로그인 -->
    <form action="${pageContext.request.contextPath}/Nologin" method="post">
        <div class="form-group">
            <label>아이디</label>
            <input type="text" name="id" required>
        </div>

        <div class="form-group">
            <label>비밀번호</label>
            <input type="password" name="pw" required>
        </div>

        <button type="submit" class="login-btn">로그인</button>
    </form>

    <div class="join-link">
        아직 회원이 아니신가요?
        <a href="${pageContext.request.contextPath}/member/join">회원가입</a>
    </div>

    <!-- 구분선 -->
    <div class="divider">
        <span>또는</span>
    </div>

    <!-- 소셜 로그인 -->
    <button class="social-btn kakao" data-url="${pageContext.request.contextPath}/klogin">
        카카오 로그인
    </button>

    <button class="social-btn naver" data-url="${pageContext.request.contextPath}/nlogin">
        네이버 로그인
    </button>

    <button class="social-btn google" data-url="${pageContext.request.contextPath}/google/glogin">
        구글 로그인
    </button>

</div>

<!-- 외부 JS -->
<script src="${pageContext.request.contextPath}/js/nologin.js" defer></script>
</body>
</html>
