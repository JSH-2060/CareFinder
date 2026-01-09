<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인 - 체온 관리 서비스</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; height: 100vh; display: flex; align-items: center; justify-content: center; }
        .login-card { width: 100%; max-width: 400px; padding: 40px; border-radius: 20px; background: white; box-shadow: 0 10px 25px rgba(0,0,0,0.05); }
        .naver-btn img { width: 100%; border-radius: 6px; }
    </style>
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
<script>
    window.onload = function() {
        const urlParams = new URLSearchParams(window.location.search);
        const message = urlParams.get('message');

        if (message === 'canceled') {
            alert("네이버 로그인 동의가 취소되었습니다.");
        } else if (message === 'error') {
            alert("로그인 처리 중 오류가 발생했습니다.");
        }
    };
</script>
</body>
</html>