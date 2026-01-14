<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>

    <!-- 라이브러리 -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/material_blue.css">
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
    <script src="https://npmcdn.com/flatpickr/dist/l10n/ko.js"></script>

    <!-- 외부 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/join.css">
</head>

<body>

<div class="register-box">

    <h2>회원가입</h2>
    <p class="desc">간단한 정보 입력으로 회원가입을 진행하세요</p>

    <form action="/member/join" method="post" id="joinForm">

        <div class="form-group">
            <label>아이디</label>
            <input type="text" name="id" id="id" required placeholder="아이디를 입력하세요">
            <div id="msg"></div>
        </div>

        <div class="form-group">
            <label>비밀번호</label>
            <input type="password" name="pw" required>
        </div>

        <div class="form-group">
            <label>이름</label>
            <input type="text" name="name" id="name" required>
            <div id="nameMsg"></div>
        </div>

        <div class="form-group">
            <label>생년월일</label>
            <input type="text" name="birth" class="datepicker" placeholder="날짜를 선택하세요" required>
        </div>

        <div class="form-group">
            <label>이메일</label>
            <div class="inline-group">
                <input type="text" name="emailId" placeholder="이메일 아이디" required>
                <select name="emailDomain">
                    <option value="@naver.com">@naver.com</option>
                    <option value="@gmail.com">@gmail.com</option>
                    <option value="@daum.net">@daum.net</option>
                </select>
            </div>
        </div>

        <div class="form-group">
            <label>성별</label>
            <select name="gender" required>
                <option value="male">남</option>
                <option value="female">여</option>
            </select>
        </div>

        <div class="form-group">
            <label>전화번호</label>
            <input type="text" name="phonenumber" placeholder="'-' 없이 입력해주세요." required>
        </div>

        <button type="submit" class="submit-btn" disabled>회원가입</button>

    </form>
</div>

<!-- 외부 JS -->
<script src="${pageContext.request.contextPath}/js/join.js" defer></script>
</body>
</html>
