<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인</title>

    <style>
        body {
            margin: 0;
            height: 100vh;
            background: #F8FAFC;
            font-family: 'Pretendard', 'Apple SD Gothic Neo', Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .login-box {
            width: 420px;
            background: white;
            border-radius: 20px;
            padding: 40px 36px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
        }

        .login-box h2 {
            margin: 0 0 8px 0;
            font-size: 26px;
            text-align: center;
        }

        .login-box p.desc {
            text-align: center;
            color: #64748B;
            margin-bottom: 30px;
            font-size: 14px;
        }

        .error-msg {
            color: #DC2626;
            font-weight: 600;
            text-align: center;
            margin-bottom: 14px;
        }

        .form-group {
            margin-bottom: 18px;
        }

        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-size: 14px;
            font-weight: 600;
        }

        .form-group input {
            width: 100%;
            height: 46px;
            border-radius: 10px;
            border: 1px solid #CBD5E1;
            padding: 0 14px;
            font-size: 14px;
            box-sizing: border-box; /* ⭐ 이 줄 추가 */
        }


        .form-group input:focus {
            outline: none;
            border-color: #2563EB;
        }

        .login-btn {
            width: 100%;
            height: 48px;
            border-radius: 12px;
            border: none;
            background: #1E3A8A;
            color: white;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 10px;
        }

        .join-link {
            margin-top: 16px;
            text-align: center;
            font-size: 14px;
        }

        .join-link a {
            color: #2563EB;
            text-decoration: none;
            font-weight: 600;
        }

        .divider {
            display: flex;
            align-items: center;
            margin: 28px 0 20px;
            color: #94A3B8;
            font-size: 13px;
        }

        .divider::before,
        .divider::after {
            content: "";
            flex: 1;
            height: 1px;
            background: #E2E8F0;
        }

        .divider span {
            margin: 0 10px;
        }

        .social-btn {
            width: 100%;
            height: 48px;
            border-radius: 12px;
            border: none;
            cursor: pointer;
            font-size: 15px;
            font-weight: 600;
            margin-bottom: 12px;
        }

        .kakao {
            background: #FEE500;
        }

        .naver {
            background: #03C75A;
            color: white;
        }

        .google {
            background: white;
            border: 1px solid #CBD5E1;
        }
    </style>
</head>

<body>

<div class="login-box">

    <h2>로그인</h2>
    <p class="desc">증상을 입력하고 가까운 병원을 추천받으세요</p>

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
    <button class="social-btn kakao" onclick="location.href='${pageContext.request.contextPath}/klogin'">
        카카오 로그인
    </button>

    <button class="social-btn naver" onclick="location.href='${pageContext.request.contextPath}/nlogin'">
        네이버 로그인
    </button>

    <button class="social-btn google" onclick="location.href='${pageContext.request.contextPath}/google/glogin'">
        구글 로그인
    </button>

</div>

</body>
</html>
