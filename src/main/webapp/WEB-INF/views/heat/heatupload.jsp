<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>체온 기록 추가</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f8f9fa; padding: 20px; font-family: 'Pretendard', sans-serif; }
        .upload-card { background: white; padding: 25px; border-radius: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .info-text { font-size: 0.8rem; color: #666; margin-bottom: 15px; }
    </style>
</head>
<body>

<div class="upload-card">
    <h5 class="fw-bold mb-3">${childName} 체온 기록 추가</h5>
    <p class="info-text">입력 가능 범위: 35.0도 - 42.0도</p>

    <form action="/heat/heatupload" method="post" onsubmit="return validateForm()">

        <input type="hidden" name="childId" value="${childId}">
        <input type="hidden" name="childName" value="${childName}">

        <div class="mb-4">
            <label class="form-label fw-bold">측정 체온</label>
            <input type="number" name="temperature" id="tempInput" class="form-control form-control-lg"
                   step="0.1" min="35.0" max="42.0" placeholder="36.5" required>
        </div>

        <div class="mb-4">
            <label class="form-label fw-bold">메모</label>
            <textarea name="memo" class="form-control" rows="3" placeholder="증상이나 복약 여부를 입력하세요"></textarea>
        </div>

        <div class="d-grid gap-2">
            <button type="submit" class="btn btn-primary btn-lg">저장하기</button>
            <button type="button" class="btn btn-light" onclick="window.close()">닫기</button>
        </div>
    </form>
</div>

<script>
    function validateForm() {
        const temp = document.getElementById('tempInput').value;
        if (temp < 35.0 || temp > 42.0) {
            alert("체온은 35.0도에서 42.0도 사이만 입력 가능합니다.");
            return false;
        }
        return true;
    }
</script>

</body>
</html>