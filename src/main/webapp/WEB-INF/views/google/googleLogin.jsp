<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>로그인</title>
</head>
<body>

<%--<button onclick="location.href='https://accounts.google.com/o/oauth2/v2/auth?client_id=752178699258-runigl7jm4vmoimffkovbvul39lqg0bq.apps.googleusercontent.com&redirect_uri=http://localhost:8080/google/callback&response_type=code&scope=email%20profile'">--%>
<%--    구글 로그인--%>
<%--</button>--%>

<button onclick="location.href='https://accounts.google.com/o/oauth2/v2/auth?client_id=752178699258-runigl7jm4vmoimffkovbvul39lqg0bq.apps.googleusercontent.com&redirect_uri=http://localhost:8080/google/gcallback&response_type=code&scope=email profile&prompt=select_account'">
    구글 로그인
</button>


<br><br>
<button onclick="location.href='/'">뒤로가기</button>

</body>
</html>