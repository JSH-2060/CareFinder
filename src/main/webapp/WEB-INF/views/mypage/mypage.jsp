<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>마이페이지</title>

    <style>
        body {
            margin: 0;
            font-family: 'Pretendard', sans-serif;
            background: linear-gradient(180deg, #f0f4f8, #e2e8f0);
        }

        .container {
            max-width: 720px;
            margin: 60px auto;
            display: flex;
            flex-direction: column;
            gap: 28px;
        }

        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .home-btn {
            background: #1E3A8A;
            color: white;
            border: none;
            border-radius: 10px;
            padding: 10px 16px;
            font-weight: bold;
            cursor: pointer;
        }

        .home-btn:hover {
            background: #1e40af;
        }

        .card {
            background: white;
            border-radius: 18px;
            padding: 32px;
            box-shadow: 0 18px 35px rgba(0,0,0,0.08);
        }

        .section-title {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 20px;
            color: #1e40af;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 14px 0;
            border-bottom: 1px solid #e5e7eb;
        }

        .info-row:last-child { border-bottom: none; }

        .info-row span { color: #64748b; }

        .info-row input {
            padding: 8px 10px;
            border-radius: 8px;
            border: 1px solid #cbd5e1;
            width: 220px;
        }

        .btn {
            padding: 8px 14px;
            border-radius: 8px;
            border: none;
            font-weight: bold;
            cursor: pointer;
        }

        .btn-save {
            background: #1E3A8A;
            color: white;
        }

        .readonly {
            color: #334155;
            font-weight: 600;
        }
    </style>
</head>
<body>

<div class="container">

    <!-- 상단 바 -->
    <div class="top-bar">
        <h2>👤 마이페이지</h2>
        <button class="home-btn" onclick="location.href='/'">홈</button>
    </div>

    <!-- 내 정보 -->
    <div class="card">
        <div class="section-title">내 정보</div>

        <!-- 이름 수정 -->
        <form action="/mypage/update" method="post">
            <div class="info-row">
                <span>이름</span>
                <input type="text" name="userName" value="${userName}" required>
            </div>

            <!-- 이메일 (읽기 전용) -->
            <div class="info-row">
                <span>이메일</span>
                <span class="readonly">${email}</span>
            </div>

            <!-- 휴대폰 번호 수정 -->
            <div class="info-row">
                <span>휴대폰 번호</span>
                <input type="text" name="phone" value="${phone}" placeholder="010-1234-5678">
            </div>

            <div style="margin-top:20px; text-align:right;">
                <button class="btn btn-save" type="submit">정보 저장</button>
            </div>
        </form>
    </div>

</div>

</body>
</html>
