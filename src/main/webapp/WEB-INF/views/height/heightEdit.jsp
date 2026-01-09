<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>키 기록 수정</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background: #f8f9fa;
            padding: 20px;
        }
    </style>
</head>
<body>

<h4 class="text-center mb-4">${childName} 키 기록 수정</h4>

<form action="/height/update" method="post">

    <input type="hidden" name="heightId" value="${heightId}">
    <input type="hidden" name="childId" value="${childId}">
    <input type="hidden" name="childName" value="${childName}">

    <div class="mb-3">
        <label class="form-label">측정 날짜</label>
        <input type="date" name="recordDate"
               class="form-control"
               value="${recordDate}" required>
    </div>

    <div class="mb-4">
        <label class="form-label">키 (cm)</label>
        <input type="number" step="0.1"
               name="height"
               class="form-control"
               value="${height}" required>
    </div>

    <div class="d-grid">
        <button class="btn btn-primary">수정 저장</button>
    </div>
</form>

<script>
    if (window.opener) {
        window.opener.location.reload();
    }
</script>

</body>
</html>