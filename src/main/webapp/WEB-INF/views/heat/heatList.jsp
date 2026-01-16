<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>체온 관리 - CareFinder</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/material_blue.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <link href="/css/heatList.css" rel="stylesheet">
</head>
<body>

<div class="header">
    <div class="logo" onclick="location.href='/'">
        <i class="fa-solid fa-laptop-medical logo-icon"></i>
        <span class="logo-text">CareFinder</span>
    </div>

    <div class="header-right">
        <div class="user-menu">
            <span class="user-name">
                <i class="fa-regular fa-user"></i> ${sessionScope.userName}님
            </span>
            <button class="logout-btn-header" onclick="location.href='/nlogout'">
                <i class="fa-solid fa-arrow-right-from-bracket"></i> 로그아웃
            </button>
        </div>
    </div>
</div>

<div class="container heat-page" style="max-width: 900px;">

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
                    <small class="text-secondary">체온 기록장</small>
                </div>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-end border-top pt-3">
            <ul class="nav nav-pills">
                <li class="nav-item"><a class="nav-link active" href="#">체온</a></li>
                <li class="nav-item"><a class="nav-link" href="/vaccine/list?childId=${childId}&childName=${childName}">백신</a></li>
                <li class="nav-item"><a class="nav-link" href="/bmi/list?childId=${childId}&childName=${childName}">BMI</a></li>
                <li class="nav-item"><a class="nav-link" href="/height/list?childId=${childId}&childName=${childName}">키성장</a></li>
            </ul>

            <div class="profile-wrap d-flex gap-1">
                <a href="/heat/list?childId=0&childName=${sessionScope.userName}" class="profile-sm-btn ${childId == 0 ? 'active' : ''}">나</a>
                <c:forEach var="c" items="${childList}">
                    <a href="/heat/list?childId=${c.childId}&childName=${c.childName}" class="profile-sm-btn ${childId == c.childId ? 'active' : ''}">${c.childName}</a>
                </c:forEach>
                <a href="/child/add" class="profile-sm-btn">+</a>
            </div>
        </div>
    </div>

    <div class="d-flex justify-content-end gap-2 my-3">
        <a href="/" class="btn btn-outline-secondary btn-sm">
            <i class="fa-solid fa-house"></i> 홈으로
        </a>
        <button class="btn btn-heat" data-bs-toggle="modal" data-bs-target="#addModal">
            <i class="fa-solid fa-plus"></i> 체온 기록 추가
        </button>
    </div>

    <div class="card-box white p-3">
        <h6 class="fw-bold mb-3 d-flex align-items-center gap-2">
            <i class="fa-solid fa-temperature-three-quarters icon-red"></i>
            최근 체온 변화 (귀 체온계 기준)
        </h6>
        <div style="height: 300px; width: 100%;">
            <canvas id="tempChart"></canvas>
        </div>
    </div>

    <div class="card-box p-3">
        <h6 class="fw-bold mb-3 d-flex align-items-center gap-2">
            <i class="fa-solid fa-clipboard-list icon-red"></i>
            상세 기록
        </h6>
        <table class="table table-hover text-center align-middle">
            <thead class="table-light">
            <tr>
                <th>측정 일시</th>
                <th>체온</th>
                <th>상태</th>
                <th>메모</th>
                <th>관리</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty list}">
                    <tr><td colspan="5" class="py-5 text-secondary">아직 기록이 없습니다.</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="h" items="${list}">
                        <tr class="record-row"
                            onclick="openEditModal(this)"
                            data-no="${h.heatNo}"
                            data-temp="${h.temperature}"
                            data-date="${h.measureDate} ${h.measureTime}"
                            data-memo="${fn:escapeXml(h.memo)}">

                            <td>
                                    ${h.measureDate} <span class="fw-bold text-secondary small">${h.measureTime}</span>
                            </td>

                            <td class="fw-bold fs-5">${h.temperature}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${h.temperature >= 39.0}"><span class="badge-custom bg-danger-super">초고열</span></c:when>
                                    <c:when test="${h.temperature >= 38.0}"><span class="badge-custom bg-danger-high">고열</span></c:when>
                                    <c:when test="${h.temperature >= 37.5}"><span class="badge-custom bg-warning-mild">미열</span></c:when>
                                    <c:when test="${h.temperature >= 36.0}"><span class="badge-custom bg-success-ok">정상</span></c:when>
                                    <c:otherwise><span class="badge-custom bg-info-low">저체온</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-start text-secondary text-truncate" style="max-width: 150px;">${h.memo}</td>
                            <td>
                                <a href="/heat/delete?heatNo=${h.heatNo}&childId=${childId}&childName=${childName}"
                                   class="btn-delete-row text-decoration-none"
                                   onclick="event.stopPropagation(); return confirm('정말 삭제하시겠습니까?')">
                                    삭제
                                </a>
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
        <form action="/heat/add" method="post" class="modal-content shadow" onsubmit="return validateForm(this)">
            <input type="hidden" name="childId" value="${childId}">
            <input type="hidden" name="childName" value="${childName}">
            <div class="modal-header border-0 pb-0"><h5 class="modal-title fw-bold">체온 기록하기</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label fw-bold">체온 (℃)</label>
                    <input type="number" step="0.1" name="temperature" class="form-control"
                           placeholder="36.5" min="34.0" max="43.0" required>
                    <div class="form-text text-danger">※ 34.0℃ ~ 43.0℃ 사이만 입력 가능합니다.</div>
                </div>
                <div class="mb-3"><label class="form-label fw-bold">측정 일시</label><input type="text" name="measureDateTime" class="form-control datepicker" required></div>
                <div class="mb-3"><label class="form-label fw-bold">메모</label><textarea name="memo" class="form-control" rows="3"></textarea></div>
            </div>
            <div class="modal-footer border-0 pt-0"><button type="submit" class="btn btn-heat">저장하기</button></div>
        </form>
    </div>
</div>

<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <form action="/heat/update" method="post" class="modal-content shadow" onsubmit="return validateForm(this)">
            <input type="hidden" name="heatNo" id="edit_heatNo">
            <input type="hidden" name="childId" value="${childId}">
            <input type="hidden" name="childName" value="${childName}">
            <div class="modal-header border-0 pb-0"><h5 class="modal-title fw-bold">기록 수정하기</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label fw-bold">체온 (℃)</label>
                    <input type="number" step="0.1" name="temperature" id="edit_temperature" class="form-control"
                           min="34.0" max="43.0" required>
                    <div class="form-text text-danger">※ 34.0℃ ~ 43.0℃ 사이만 입력 가능합니다.</div>
                </div>
                <div class="mb-3"><label class="form-label fw-bold">측정 일시</label><input type="text" name="measureDateTime" id="edit_measureDate" class="form-control datepicker" required></div>
                <div class="mb-3"><label class="form-label fw-bold">메모</label><textarea name="memo" id="edit_memo" class="form-control" rows="3"></textarea></div>
            </div>
            <div class="modal-footer border-0 pt-0"><button type="submit" class="btn btn-heat">수정 완료</button></div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://npmcdn.com/flatpickr/dist/l10n/ko.js"></script>

<script src="/js/heatList.js"></script>

<script>
    const labels = [];
    const dataPoints = [];

    <c:forEach var="h" items="${list}" end="14">
    labels.push('${h.measureDate} ${h.measureTime}');
    dataPoints.push(${h.temperature});
    </c:forEach>

    labels.reverse();
    dataPoints.reverse();

    renderHeatChart(labels, dataPoints);
</script>

</body>
</html>