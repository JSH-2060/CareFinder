<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>기록 수정/삭제</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f8f9fa; padding: 20px; font-family: 'Pretendard', sans-serif; }
        .edit-card { background: white; padding: 25px; border-radius: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .btn-delete { background: #dc3545; border: none; color: white; font-weight: bold; }
        .btn-delete:hover { background: #bb2d3b; color: white; }
    </style>
</head>
<body>

<div class="edit-card">
    <h5 class="fw-bold mb-4 text-center">기록 수정 / 삭제</h5>

    <form action="/heat/update" method="post">
        <input type="hidden" name="heatNo" value="${dto.heatNo}">
        <input type="hidden" name="childId" value="${dto.childId}">

        <div class="mb-3">
            <label class="form-label fw-bold">체온</label>
            <input type="number" name="temperature" class="form-control form-control-lg"
                   step="0.1" min="35.0" max="42.0"
                   value="${dto.temperature}" required>
        </div>

        <div class="mb-4">
            <label class="form-label fw-bold">메모</label>
            <textarea name="memo" class="form-control" rows="3">${dto.memo}</textarea>
        </div>

        <div class="d-grid gap-2">
            <button type="submit" class="btn btn-primary btn-lg">수정 완료</button>

            <button type="button" class="btn btn-delete btn-lg" onclick="deleteHeat()">삭제하기</button>

            <button type="button" class="btn btn-light" onclick="window.close()">닫기</button>
        </div>
    </form>
</div>

<script>
    function deleteHeat() {
        if (confirm("정말 이 기록을 삭제하시겠습니까?")) {
            // 삭제 컨트롤러 호출
            location.href = '/heat/deleteFromPopup?heatNo=${dto.heatNo}';
        }
    }
</script>

</body>
</html>