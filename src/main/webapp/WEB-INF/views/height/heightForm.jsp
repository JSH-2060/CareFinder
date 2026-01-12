<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>키 기록 추가</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background: #f8f9fa;
            padding: 20px;
        }
    </style>
</head>
<body>

<h4 class="text-center mb-4">${childName} 키 기록</h4>

<form action="/height/add" method="post">

    <input type="hidden" name="childId" value="${childId}">
    <input type="hidden" name="childName" value="${childName}">

    <div class="mb-3">
        <label class="form-label">측정 날짜</label>
        <input type="date" name="recordDate" class="form-control" required>
    </div>

    <div class="mb-4">
        <label class="form-label">키 (cm)</label>
        <input type="number" step="0.1" name="height"
               class="form-control" placeholder="예: 123.4" required>
    </div>

    <div class="d-grid">
        <button class="btn btn-primary">저장</button>
    </div>
</form>

<script>
    // 저장 후 부모창 새로고침 + 팝업 닫기
    if (window.opener) {
        window.opener.location.reload();
    }
</script>

</body>
</html>