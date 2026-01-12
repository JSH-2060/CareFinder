<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="path" value="${empty mode ? 'heat' : mode}" />

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>대상 선택</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f8f9fa; display: flex; align-items: center; justify-content: center; min-height: 100vh; font-family: 'Pretendard', sans-serif; }
        .card-container { display: flex; gap: 20px; flex-wrap: wrap; justify-content: center; max-width: 900px; }

        /* 카드 기본 스타일 */
        .select-card {
            width: 180px; height: 200px; background: white; border-radius: 20px;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            box-shadow: 0 10px 20px rgba(0,0,0,0.05); cursor: pointer; text-decoration: none; color: #333; transition: 0.2s; border: 2px solid transparent;
            position: relative; /* 삭제 버튼 위치 잡기 위해 필수 */
        }
        .select-card:hover { transform: translateY(-5px); border-color: #0d6efd; }

        .card-me { background: #e0f2fe; border: 2px solid #0ea5e9; }
        .card-add { border: 2px dashed #adb5bd; background: transparent; color: #adb5bd; }
        .card-add:hover { border-color: #6c757d; color: #6c757d; background: rgba(0,0,0,0.03); }

        .profile-img { width: 70px; height: 70px; border-radius: 50%; background: #eee; display: flex; align-items: center; justify-content: center; font-size: 28px; margin-bottom: 15px; font-weight: bold; }
        .name { font-weight: bold; font-size: 1.2rem; }

        /* ★ 삭제 버튼 스타일 추가 ★ */
        .btn-delete {
            position: absolute;
            top: 10px;
            right: 10px;
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background-color: #dee2e6;
            color: #666;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            font-weight: bold;
            border: none;
            cursor: pointer;
            transition: 0.2s;
            z-index: 10; /* 카드 클릭보다 위에 오도록 */
        }
        .btn-delete:hover {
            background-color: #ef4444; /* 빨간색 */
            color: white;
        }
    </style>
</head>
<body>

<div class="text-center w-100">
    <h3 class="fw-bold mb-2">누구의 기록을 관리할까요?</h3>
    <p class="text-muted mb-5">본인 또는 등록된 가족을 선택하세요</p>

    <div class="card-container mx-auto">
        <a href="/${path}/list?childId=0&childName=${sessionScope.userName}" class="select-card card-me">
            <div class="profile-img bg-primary text-white">Me</div>
            <div class="name">나 (본인)</div>
        </a>

        <c:forEach var="c" items="${childList}">
            <div style="position: relative;">
                <a href="/${path}/list?childId=${c.childId}&childName=${c.childName}" class="select-card">
                    <div class="profile-img bg-warning text-white">${c.childName.substring(0,1)}</div>
                    <div class="name">${c.childName}</div>
                </a>

                <button type="button" class="btn-delete"
                        onclick="deleteChild(${c.childId}, '${c.childName}');">
                    ✕
                </button>
            </div>
        </c:forEach>

        <a href="/child/add" class="select-card card-add">
            <div style="font-size: 50px; line-height: 1;">+</div>
            <div class="name mt-2">가족 추가</div>
        </a>
    </div>

    <div class="mt-5">
        <a href="/" class="btn btn-outline-secondary rounded-pill px-4">메인으로 돌아가기</a>
    </div>
</div>

<script>
    function deleteChild(childId, childName) {
        // 카드 클릭 이벤트로 전파되는 것 방지 (중요!)
        event.preventDefault();

        if (confirm("정말 '" + childName + "' 프로필을 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.")) {
            // 삭제 컨트롤러로 이동
            location.href = '/child/delete?childId=' + childId;
        }
    }
</script>

</body>
</html>