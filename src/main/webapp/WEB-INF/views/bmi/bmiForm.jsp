<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>BMI 계산</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background-color: #f8f9fa;
        }
        .popup-card {
            max-width: 480px;
            margin: 40px auto;
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.12);
            padding: 30px;
        }
        .hint-text {
            font-size: 12px;
            color: #6c757d;
            text-align: center;
            margin-bottom: 16px;
        }
    </style>
</head>

<body>

<div class="popup-card">

    <h4 class="mb-3 fw-bold text-center">
        ${childName} BMI 계산
    </h4>

    <!-- 🔹 이전 기록 안내 -->
    <c:if test="${not empty latestBmi}">
        <div class="hint-text">
            이전 기록(${latestBmi.recordDate}) 기준으로 자동 입력되었습니다.
        </div>
    </c:if>

    <!-- ==========================
         BMI 계산 / 저장 폼
    ========================== -->
    <form action="/bmi/insert" method="post">

        <!-- 🔥 필수 hidden -->
        <input type="hidden" name="childId" value="${childId}">
        <input type="hidden" name="childName" value="${childName}">

        <!-- 키 -->
        <div class="mb-3">
            <label class="form-label">키 (cm)</label>
            <input type="number"
                   name="height"
                   class="form-control"
                   step="0.1"
                   min="80"
                   max="250"
                   placeholder="예) 120.5 (80cm 이상)"
                   value="${latestBmi != null ? latestBmi.height : ''}"
                   required>
        </div>

        <!-- 몸무게 -->
        <div class="mb-4">
            <label class="form-label">몸무게 (kg)</label>
            <input type="number"
                   name="weight"
                   class="form-control"
                   step="0.1"
                   min="9"
                   max="149.9"
                   placeholder="예) 25.3 (9kg 이상 150kg 미만)"
                   value="${latestBmi != null ? latestBmi.weight : ''}"
                   required>
        </div>

        <!-- 버튼 -->
        <div class="d-flex justify-content-center gap-2">
            <button type="submit" class="btn btn-primary px-4">
                계산 & 저장
            </button>
            <button type="button"
                    class="btn btn-outline-secondary px-4"
                    onclick="window.close();">
                취소
            </button>
        </div>

    </form>

    <!-- 서버 메시지 -->
    <c:if test="${not empty msg}">
        <div class="alert alert-warning mt-3 text-center">
                ${msg}
        </div>
    </c:if>

</div>

</body>
</html>
