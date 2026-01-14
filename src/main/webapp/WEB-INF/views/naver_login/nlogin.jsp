<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인 - 체온 관리 서비스</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <link href="/css/login.css" rel="stylesheet">
</head>
<body>

<div class="login-card text-center">
    <h3 class="fw-bold mb-4">체온 관리 서비스</h3>
    <p class="text-muted mb-5">서비스 이용을 위해 로그인해주세요.</p>

    <a href="/nlogin/naver?auth_type=reprompt" class="naver-btn">
        <img src="https://static.nid.naver.com/oauth/big_g_in.PNG" alt="네이버 로그인">
    </a>

    <div style="display:none;">
        <input type="text" name="fake_id" autocomplete="off">
        <input type="password" name="fake_pw" autocomplete="new-password">
    </div>

    <div class="mt-4 small text-muted">
        처음 방문 시 자동으로 회원가입이 진행됩니다.
    </div>
</div>

<script src="/js/login.js"></script>

</body>
</html>