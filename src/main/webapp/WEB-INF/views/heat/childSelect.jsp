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

        .select-card {
            width: 180px; height: 200px; background: white; border-radius: 20px;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            box-shadow: 0 10px 20px rgba(0,0,0,0.05); cursor: pointer; text-decoration: none; color: #333; transition: 0.2s; border: 2px solid transparent;
        }
        .select-card:hover { transform: translateY(-5px); border-color: #0d6efd; }

        .card-me { background: #e0f2fe; border: 2px solid #0ea5e9; }
        .card-add { border: 2px dashed #adb5bd; background: transparent; color: #adb5bd; }
        .card-add:hover { border-color: #6c757d; color: #6c757d; background: rgba(0,0,0,0.03); }

        .profile-img { width: 70px; height: 70px; border-radius: 50%; background: #eee; display: flex; align-items: center; justify-content: center; font-size: 28px; margin-bottom: 15px; font-weight: bold; }
        .name { font-weight: bold; font-size: 1.2rem; }
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
            <a href="/${path}/list?childId=${c.childId}&childName=${c.childName}" class="select-card">
                <div class="profile-img bg-warning text-white">${c.childName.substring(0,1)}</div>
                <div class="name">${c.childName}</div>
            </a>
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

</body>
</html>