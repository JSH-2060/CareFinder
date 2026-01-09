<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BMI 수정</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container mt-4">

<h5 class="mb-4">BMI 기록 수정</h5>

<form action="/bmi/update" method="post">

    <input type="hidden" name="bmiNo" value="${dto.bmiNo}">
    <input type="hidden" name="childId" value="${dto.childId}">

    <!-- 키 (cm) -->
    <div class="mb-3">
        <label class="form-label">키 (cm)</label>
        <input type="number"
               name="height"
               class="form-control"
               value="${dto.height}"
               step="0.1"
               min="80"
               max="250"
               required>
    </div>

    <!-- 몸무게 (kg) -->
    <div class="mb-3">
        <label class="form-label">몸무게 (kg)</label>
        <input type="number"
               name="weight"
               class="form-control"
               value="${dto.weight}"
               step="0.1"
               min="9"
               max="149.9"
               required>
    </div>

    <button class="btn btn-primary">저장</button>
    <button type="button" class="btn btn-secondary"
            onclick="window.close()">취소</button>
</form>

</body>
</html>
