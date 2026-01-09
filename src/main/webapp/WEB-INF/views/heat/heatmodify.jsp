<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>기록 수정</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container mt-4">
<h4>체온 기록 수정</h4>
<form action="${pageContext.request.contextPath}/heat/modify" method="post">
    <input type="hidden" name="heatId" value="${heat.heatId}">

    <div class="mb-3">
        <label class="form-label">체온 (℃)</label>
        <input type="number" step="0.1" name="temp" value="${heat.temp}" class="form-control" required>
    </div>
    <div class="mb-3">
        <label class="form-label">기록 시간</label>
        <input type="datetime-local" name="timeFormatted" value="${heat.timeFormatted}" class="form-control" required>
    </div>
    <div class="mb-3">
        <label class="form-label">메모</label>
        <textarea name="memo" class="form-control" rows="3">${heat.memo}</textarea>
    </div>
    <button type="submit" class="btn btn-primary w-100">수정 완료</button>
</form>
</body>
</html>