<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>백신 관리</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/material_blue.css">

    <style>
        body { background: #f0f2f5; font-family: 'Pretendard', sans-serif; }

        .avatar-circle {
            width: 44px; height: 44px; border-radius: 50%;
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            color: white; display: flex; align-items: center; justify-content: center;
            font-size: 16px; font-weight: 700;
            box-shadow: 0 4px 10px rgba(37, 99, 235, 0.35);
        }

        .card-box { background: white; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); margin-bottom: 20px; }

        .nav-pills .nav-link { color: #555; font-weight: 600; border-radius: 12px; padding: 10px 20px; }
        .nav-pills .nav-link.active { background-color: #3b82f6; color: white; }

        .badge-status { padding: 6px 12px; border-radius: 999px; font-size: 0.85rem; font-weight: 600; }
        .badge-done   { background: #dcfce7; color: #16a34a; }
        .badge-yet    { background: #fee2e2; color: #ef4444; }
        .badge-dday   { background: #eff6ff; color: #2563eb; }

        .profile-sm-btn {
            font-size: 0.8rem; padding: 4px 12px; border-radius: 20px;
            border: 1px solid #ddd; background: white; text-decoration: none; color: #555; transition: 0.2s;
        }
        .profile-sm-btn:hover { background: #f8f9fa; }
        .profile-sm-btn.active { background: #eff6ff; border-color: #3b82f6; color: #1d4ed8; font-weight: bold; }
    </style>
</head>

<body>

<div class="container mt-4" style="max-width: 900px;">

    <div class="card-box p-3">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div class="d-flex align-items-center gap-3">
                <div class="avatar-circle">
                    <c:choose>
                        <c:when test="${not empty childName}">${fn:substring(childName, 0, 1)}</c:when>
                        <c:otherwise>Me</c:otherwise>
                    </c:choose>
                </div>
                <div>
                    <h5 class="mb-0 fw-bold">${childName}</h5>
                    <small class="text-muted">백신 접종 내역</small>
                </div>
            </div>
            <a href="/" class="btn btn-sm btn-outline-secondary">홈으로</a>
        </div>

        <div class="d-flex justify-content-between align-items-end border-top pt-3">
            <ul class="nav nav-pills">
                <li class="nav-item">
                    <c:url value="/heat/list" var="heatUrl">
                        <c:param name="childId" value="${childId}"/>
                        <c:param name="childName" value="${childName}"/>
                    </c:url>
                    <a class="nav-link" href="${heatUrl}">체온</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link active" href="#">백신</a>
                </li>
                <li class="nav-item">
                    <c:url value="/bmi/list" var="bmiUrl">
                        <c:param name="childId" value="${childId}"/>
                        <c:param name="childName" value="${childName}"/>
                    </c:url>
                    <a class="nav-link" href="${bmiUrl}">BMI</a>
                </li>
            </ul>

            <div class="d-flex gap-1">
                <c:url value="/vaccine/list" var="meUrl">
                    <c:param name="childId" value="0"/>
                    <c:param name="childName" value="${sessionScope.userName}"/>
                </c:url>
                <a href="${meUrl}" class="profile-sm-btn ${empty param.childId or param.childId eq '0' ? 'active' : ''}">나</a>

                <c:forEach var="c" items="${childList}">
                    <c:url value="/vaccine/list" var="childUrl">
                        <c:param name="childId" value="${c.childId}"/>
                        <c:param name="childName" value="${c.childName}"/>
                    </c:url>
                    <a href="${childUrl}" class="profile-sm-btn ${param.childId eq c.childId ? 'active' : ''}">${c.childName}</a>
                </c:forEach>
                <a href="/child/add" class="profile-sm-btn">+</a>
            </div>
        </div>
    </div>

    <div class="d-flex justify-content-end gap-2 my-3">
        <button class="btn btn-primary btn-sm fw-bold" data-bs-toggle="modal" data-bs-target="#addModal">
            접종 일정 추가
        </button>
    </div>

    <div class="card-box p-3">
        <h6 class="fw-bold mb-3">접종 상세 내역</h6>
        <table class="table table-hover text-center align-middle">
            <thead class="table-light">
            <tr>
                <th>백신명</th>
                <th>차수</th>
                <th>예정일 / 상태</th>
                <th>판정</th>
                <th>관리</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty list}">
                    <tr><td colspan="5" class="text-muted py-4">접종 내역이 없습니다.</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="v" items="${list}">
                        <tr>
                            <td class="fw-bold text-start ps-5">${v.vaccineName}</td>
                            <td>${v.chasu}차</td>
                            <td>
                                    ${v.inoculationDate}
                                <c:if test="${v.status ne 'Y'}">
                                    <span class="badge-status badge-dday ms-1">D-${v.dayDiff}</span>
                                </c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${v.status eq 'Y'}"><span class="badge-status badge-done">완료</span></c:when>
                                    <c:otherwise><span class="badge-status badge-yet">미접종</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:if test="${v.status ne 'Y'}">
                                    <a href="/vaccine/complete?vaccineNo=${v.vaccineNo}&childId=${childId}&childName=${childName}" class="btn btn-sm btn-outline-success me-1">접종</a>
                                </c:if>
                                <a href="/vaccine/delete?vaccineNo=${v.vaccineNo}&childId=${childId}&childName=${childName}" class="btn btn-sm btn-outline-danger" onclick="return confirm('삭제하시겠습니까?')">삭제</a>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>
</div>

<div class="modal fade" id="addModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <form action="/vaccine/add" method="post" class="w-100">
            <div class="modal-content">
                <div class="modal-header fw-bold">접종 일정 추가</div>
                <div class="modal-body">
                    <input type="hidden" name="childId" value="${childId}">
                    <input type="hidden" name="childName" value="${childName}">
                    <div class="mb-3"><label class="form-label">백신명</label><input type="text" name="vaccineName" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label">차수</label><input type="number" name="chasu" value="1" class="form-control"></div>
                    <div class="mb-3"><label class="form-label">예정일</label><input type="text" name="inoculationDate" class="form-control datepicker" required style="background:white;"></div>
                </div>
                <div class="modal-footer"><button type="submit" class="btn btn-primary w-100 fw-bold">저장하기</button></div>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://npmcdn.com/flatpickr/dist/l10n/ko.js"></script>
<script>
    flatpickr(".datepicker", { locale: "ko", dateFormat: "Y-m-d", defaultDate: new Date() });
</script>
</body>
</html>