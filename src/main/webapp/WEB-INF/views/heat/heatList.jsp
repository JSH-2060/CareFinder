<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>체온 기록</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/material_orange.css">

    <style>
        body { background: #f0f2f5; font-family: 'Pretendard', sans-serif; }
        .card-box { background: white; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); margin-bottom: 20px; }
        .avatar-circle { width: 44px; height: 44px; border-radius: 50%; background: linear-gradient(135deg, #fbbf24, #d97706); color: white; display: flex; align-items: center; justify-content: center; font-weight: bold; }

        /* 배지 기준 */
        .badge-high   { background: #fee2e2; color: #ef4444; } /* 38.0 이상 */
        .badge-mid    { background: #ffedd5; color: #f97316; } /* 36.8 ~ 37.9 */
        .badge-normal { background: #dcfce7; color: #16a34a; } /* 36.8 미만 */

        .nav-pills .nav-link.active { background-color: #f59e0b; color: white; }
        .nav-pills .nav-link { color: #555; font-weight: 600; }

        .profile-btn { font-size: 0.85rem; padding: 5px 12px; border-radius: 20px; border: 1px solid #ddd; background: white; text-decoration: none; color: #555; }
        .profile-btn.active { background: #fff7ed; border-color: #f59e0b; color: #d97706; font-weight: bold; }
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
                <div><h5 class="mb-0 fw-bold">${childName}</h5><small class="text-muted">체온 기록장</small></div>
            </div>
            <a href="/" class="btn btn-sm btn-outline-secondary">홈으로</a>
        </div>

        <div class="d-flex justify-content-between align-items-end border-top pt-3">
            <ul class="nav nav-pills">
                <li class="nav-item"><a class="nav-link active" href="#">체온</a></li>
                <li class="nav-item">
                    <c:url value="/vaccine/list" var="vUrl"><c:param name="childId" value="${childId}"/><c:param name="childName" value="${childName}"/></c:url>
                    <a class="nav-link" href="${vUrl}">백신</a>
                </li>
                <li class="nav-item">
                    <c:url value="/bmi/list" var="bUrl"><c:param name="childId" value="${childId}"/><c:param name="childName" value="${childName}"/></c:url>
                    <a class="nav-link" href="${bUrl}">BMI</a>
                </li>
            </ul>
            <div class="d-flex gap-1">
                <c:url value="/heat/list" var="meUrl">
                    <c:param name="childId" value="0"/>
                    <c:param name="childName" value="${sessionScope.userName}"/>
                </c:url>
                <a href="${meUrl}" class="profile-sm-btn ${empty param.childId or param.childId eq '0' ? 'active' : ''}">나</a>

                <c:forEach var="c" items="${childList}">
                    <c:url value="/heat/list" var="childUrl">
                        <c:param name="childId" value="${c.childId}"/>
                        <c:param name="childName" value="${c.childName}"/>
                    </c:url>
                    <a href="${childUrl}" class="profile-sm-btn ${param.childId eq c.childId ? 'active' : ''}">${c.childName}</a>
                </c:forEach>

                <a href="/child/add" class="profile-sm-btn">+</a>
            </div>
        </div>
    </div>

    <div class="d-flex justify-content-end mb-3">
        <button class="btn btn-warning text-white fw-bold" data-bs-toggle="modal" data-bs-target="#addModal">기록하기</button>
    </div>

    <div class="card-box p-3">
        <h6 class="fw-bold mb-3">체온 변화</h6>
        <canvas id="heatChart" height="100"></canvas>
    </div>

    <div class="card-box p-3">
        <h6 class="fw-bold mb-3">상세 기록</h6>
        <table class="table table-hover text-center align-middle">
            <thead class="table-light"><tr><th>날짜</th><th>시간</th><th>체온</th><th>상태</th><th>관리</th></tr></thead>
            <tbody>
            <c:forEach var="h" items="${list}">
                <tr>
                    <td>${h.measureDate}</td>
                    <td>${h.measureTime}</td>
                    <td class="fw-bold">${h.temperature} °C</td>
                    <td>
                        <c:choose>
                            <c:when test="${h.temperature >= 38.0}"><span class="badge-status badge-high">고열</span></c:when>
                            <c:when test="${h.temperature >= 36.8}"><span class="badge-status badge-mid">미열</span></c:when>
                            <c:otherwise><span class="badge-status badge-normal">정상</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <a href="/heat/delete?heatNo=${h.heatNo}&childId=${childId}&childName=${childName}" class="btn btn-sm btn-outline-danger" onclick="return confirm('삭제할까요?')">삭제</a>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty list}"><tr><td colspan="5" class="py-4 text-muted">기록이 없습니다.</td></tr></c:if>
            </tbody>
        </table>
    </div>
</div>

<div class="modal fade" id="addModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <form action="/heat/add" method="post" class="w-100">
            <div class="modal-content">
                <div class="modal-header fw-bold">체온 입력</div>
                <div class="modal-body">
                    <input type="hidden" name="childId" value="${childId}">
                    <input type="hidden" name="childName" value="${childName}">

                    <div class="mb-3">
                        <label class="form-label">체온 (°C)</label>
                        <input type="number" step="0.1" name="temperature" class="form-control"
                               placeholder="36.5" min="30.0" max="45.0" required>
                        <div class="form-text text-danger" style="font-size: 0.8rem;">* 30.0 ~ 45.0 사이만 입력 가능</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">일시</label>
                        <input type="text" name="measureDateTime" class="form-control datetimepicker" required style="background:white;">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">메모 (선택)</label>
                        <input type="text" name="memo" class="form-control" placeholder="예: 해열제 복용, 컨디션 좋음 등">
                    </div>
                </div>
                <div class="modal-footer"><button type="submit" class="btn btn-warning w-100 text-white fw-bold">저장</button></div>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://npmcdn.com/flatpickr/dist/l10n/ko.js"></script>
<script>
    flatpickr(".datetimepicker", { locale: "ko", enableTime: true, dateFormat: "Y-m-d H:i", time_24hr: true, defaultDate: new Date() });

    <c:if test="${not empty list}">
    const ctx = document.getElementById('heatChart').getContext('2d');
    const labels = []; const data = [];
    <c:forEach var="h" items="${list}" begin="0" end="9">
    labels.unshift("${h.measureDate} ${h.measureTime}"); data.unshift(${h.temperature});
    </c:forEach>
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{ label: '체온', data: data, borderColor: '#f59e0b', tension: 0, fill: false }]
        },
        options: { scales: { y: { suggestedMin: 35, suggestedMax: 40 } }, plugins: { legend: { display: false } } }
    });
    </c:if>
</script>
</body>
</html>