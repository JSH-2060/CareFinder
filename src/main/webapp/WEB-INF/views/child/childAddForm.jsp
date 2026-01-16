<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>가족 추가</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/material_blue.css">

    <link href="/css/childAddForm.css" rel="stylesheet">
</head>
<body>

<div class="form-box">
    <h4 class="fw-bold text-center mb-4">새 가족 구성원 추가</h4>

    <form action="/child/add" method="post">
        <div class="mb-3">
            <label class="form-label fw-bold">이름</label>
            <input type="text" name="childName" class="form-control rounded-3" placeholder="이름을 입력하세요" required>
        </div>

        <div class="mb-3">
            <label class="form-label fw-bold">생년월일</label>
            <input type="text" name="birth" class="form-control rounded-3 datepicker" placeholder="날짜를 선택하세요" required style="background:white;">
        </div>

        <div class="mb-4">
            <label class="form-label fw-bold d-block">성별</label>
            <div class="btn-group w-100" role="group">
                <input type="radio" class="btn-check" name="gender" id="male" value="M" checked>
                <label class="btn btn-outline-primary py-2" for="male">남자</label>

                <input type="radio" class="btn-check" name="gender" id="female" value="F">
                <label class="btn btn-outline-danger py-2" for="female">여자</label>
            </div>
        </div>

        <button type="submit" class="btn btn-primary w-100 py-3 rounded-3 fw-bold">등록하기</button>
        <div class="text-center mt-3">
            <a href="/heat/select" class="text-decoration-none text-muted">취소</a>
        </div>
    </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://npmcdn.com/flatpickr/dist/l10n/ko.js"></script>

<script src="/js/childAddForm.js"></script>

</body>
</html>