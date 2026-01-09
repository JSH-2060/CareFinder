<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
</head>
<body>

<h2>로그인 페이지</h2>

<button
        onclick="location.href='https://kauth.kakao.com/oauth/authorize?client_id=${kakaoApiKey}&redirect_uri=${kakaoRedirectUri}&response_type=code'">
    카카오 로그인
</button>

<br><br>
<button onclick="location.href='/'">뒤로가기</button>

</body>
</html>
