<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="path" value="${empty mode ? 'heat' : mode}" />

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>대상 선택</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <link href="/css/childSelect.css" rel="stylesheet">
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
                        onclick="deleteChild(event, ${c.childId}, '${c.childName}');">
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

<script src="/js/childSelect.js"></script>

</body>
</html>