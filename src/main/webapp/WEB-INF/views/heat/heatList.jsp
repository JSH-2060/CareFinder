<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>체온 관리</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/material_blue.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <link href="/css/heatList.css" rel="stylesheet">
</head>
<body>

<div class="container mt-4" style="max-width: 900px;">

    <div class="card-box p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div class="d-flex align-items-center gap-3">
                <div class="avatar-circle">
                    <c:choose>
                        <c:when test="${not empty childName}">${fn:substring(childName, 0, 1)}</c:when>
                        <c:otherwise>Me</c:otherwise>
                    </c:choose>
                </div>
                <div>
                    <h4 class="mb-0 fw-bold" style="color:#1e293b;">${childName}</h4>
                    <small class="text-muted">건강 기록 대시보드</small>
                </div>
            </div>
            <a href="/" class="btn btn-light btn-sm fw-bold text-secondary">홈으로</a>
        </div>

        <div class="d-flex justify-content-between align-items-end border-top pt-4">
            <ul class="nav nav-pills gap-2">
                <li class="nav-item"><a class="nav-link active" href="#">체온</a></li>
                <li class="nav-item">
                    <c:url value="/vaccine/list" var="vUrl"><c:param name="childId" value="${childId}"/><c:param name="childName" value="${childName}"/></c:url>
                    <a class="nav-link" href="${vUrl}">백신</a>
                </li>
                <li class="nav-item">
                    <c:url value="/bmi/list" var="bUrl"><c:param name="childId" value="${childId}"/><c:param name="childName" value="${childName}"/></c:url>
                    <a class="nav-link" href="${bUrl}">BMI</a>
                </li>
                <li class="nav-item">
                    <c:url value="/height/list" var="heightUrl">
                        <c:param name="childId" value="${childId}"/>
                        <c:param name="childName" value="${childName}"/>
                    </c:url>
                    <a class="nav-link" href="${heightUrl}">키성장</a>
                </li>
            </ul>

            <div class="d-flex gap-1 align-items-center">
                <a href="/heat/list?childId=0&childName=${sessionScope.userName}" class="profile-sm-btn ${childId == 0 ? 'active' : ''}">나</a>
                <c:forEach var="c" items="${childList}">
                    <a href="/heat/list?childId=${c.childId}&childName=${c.childName}" class="profile-sm-btn ${childId == c.childId ? 'active' : ''}">${c.childName}</a>
                </c:forEach>
                <a href="/child/add" class="profile-sm-btn" style="padding: 6px 10px;">+</a>
            </div>
        </div>
    </div>

    <div class="card-box p-4">
        <h6 class="fw-bold mb-3 text-secondary">최근 체온 변화</h6>
        <div style="height: 300px; width: 100%;">
            <canvas id="tempChart"></canvas>
        </div>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-3 px-2">
        <h5 class="fw-bold m-0" style="color:#334155;">상세 기록</h5>
        <button class="btn btn-primary fw-bold px-4 rounded-pill shadow-sm" data-bs-toggle="modal" data-bs-target="#addModal">
            + 기록하기
        </button>
    </div>

    <div class="card-box p-0 overflow-hidden">
        <table class="table mb-0 text-center align-middle">
            <thead>
            <tr>
                <th class="py-3">측정 일시</th>
                <th class="py-3">체온</th>
                <th class="py-3">상태</th>
                <th class="py-3">메모</th>
                <th class="py-3">관리</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty list}">
                    <tr><td colspan="5" class="py-5 text-muted">아직 기록이 없습니다.</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="h" items="${list}">
                        <tr class="record-row"
                            onclick="openEditModal(this)"
                            data-no="${h.heatNo}"
                            data-temp="${h.temperature}"
                            data-date="${h.measureDate} ${h.measureTime}"
                            data-memo="${fn:escapeXml(h.memo)}">

                            <td class="text-secondary">
                                    ${h.measureDate} <span class="fw-bold text-dark">${h.measureTime}</span>
                            </td>

                            <td class="fw-normal fs-5" style="font-family: monospace; letter-spacing: -0.5px;">${h.temperature}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${h.temperature >= 39.0}"><span class="badge-custom bg-danger-super">초고열</span></c:when>
                                    <c:when test="${h.temperature >= 38.0}"><span class="badge-custom bg-danger-high">고열</span></c:when>
                                    <c:when test="${h.temperature >= 37.3}"><span class="badge-custom bg-warning-mild">미열</span></c:when>
                                    <c:when test="${h.temperature >= 36.0}"><span class="badge-custom bg-success-ok">정상</span></c:when>
                                    <c:otherwise><span class="badge-custom bg-info-low">저체온</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-start text-muted text-truncate" style="max-width: 150px;">${h.memo}</td>
                            <td>
                                <a href="/heat/delete?heatNo=${h.heatNo}&childId=${childId}&childName=${childName}"
                                   class="btn btn-sm btn-outline-danger"
                                   style="border-radius: 8px;"
                                   onclick="event.stopPropagation(); return confirm('정말 삭제하시겠습니까?')">삭제</a>
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
        <form action="/heat/add" method="post" class="modal-content border-0 shadow" onsubmit="return validateForm(this)">
            <input type="hidden" name="childId" value="${childId}">
            <input type="hidden" name="childName" value="${childName}">
            <div class="modal-header border-0 pb-0"><h5 class="modal-title fw-bold">체온 기록하기</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label fw-bold">체온 (℃)</label>
                    <input type="number" step="0.1" name="temperature" class="form-control form-control-lg"
                           placeholder="36.5" min="34.0" max="43.0" required>
                    <div class="form-text text-danger">※ 34.0℃ ~ 43.0℃ 사이만 입력 가능합니다.</div>
                </div>
                <div class="mb-3"><label class="form-label fw-bold">측정 일시</label><input type="text" name="measureDateTime" class="form-control datepicker" required style="background:white;"></div>
                <div class="mb-3"><label class="form-label fw-bold">메모</label><textarea name="memo" class="form-control" rows="3"></textarea></div>
            </div>
            <div class="modal-footer border-0 pt-0"><button type="submit" class="btn btn-primary w-100 py-2 fw-bold rounded-3">저장하기</button></div>
        </form>
    </div>
</div>

<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <form action="/heat/update" method="post" class="modal-content border-0 shadow" onsubmit="return validateForm(this)">
            <input type="hidden" name="heatNo" id="edit_heatNo">
            <input type="hidden" name="childId" value="${childId}">
            <input type="hidden" name="childName" value="${childName}">
            <div class="modal-header border-0 pb-0"><h5 class="modal-title fw-bold">기록 수정하기</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label fw-bold">체온 (℃)</label>
                    <input type="number" step="0.1" name="temperature" id="edit_temperature" class="form-control form-control-lg"
                           min="34.0" max="43.0" required>
                    <div class="form-text text-danger">※ 34.0℃ ~ 43.0℃ 사이만 입력 가능합니다.</div>
                </div>
                <div class="mb-3"><label class="form-label fw-bold">측정 일시</label><input type="text" name="measureDateTime" id="edit_measureDate" class="form-control datepicker" required style="background:white;"></div>
                <div class="mb-3"><label class="form-label fw-bold">메모</label><textarea name="memo" id="edit_memo" class="form-control" rows="3"></textarea></div>
            </div>
            <div class="modal-footer border-0 pt-0"><button type="submit" class="btn btn-primary w-100 py-2 fw-bold rounded-3">수정 완료</button></div>
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

    /* 1. JSP(서버) 데이터를 JS 배열로 변환 */
    <c:forEach var="h" items="${list}" end="14">
    labels.push('${h.measureDate} ${h.measureTime}');
    dataPoints.push(${h.temperature});
    </c:forEach>

    /* 2. 최신순 데이터를 과거->현재 순으로 뒤집기 */
    labels.reverse();
    dataPoints.reverse();

    /* 3. 분리된 JS 파일에 있는 차트 그리기 함수 호출 */
    renderHeatChart(labels, dataPoints);
</script>

</body>
</html>