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

    <style>
        body { background: #f0f2f5; font-family: 'Pretendard', sans-serif; }
        .card-box { background: white; border-radius: 20px; box-shadow: 0 10px 25px rgba(0,0,0,0.05); margin-bottom: 20px; border: none; }
        .avatar-circle { width: 48px; height: 48px; border-radius: 50%; background: linear-gradient(135deg, #3b82f6, #2563eb); color: white; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 18px; box-shadow: 0 4px 10px rgba(37, 99, 235, 0.3); }
        .nav-pills .nav-link { color: #64748b; font-weight: 600; padding: 10px 20px; border-radius: 12px; transition: 0.2s; }
        .nav-pills .nav-link:hover { background: #f1f5f9; color: #334155; }
        .nav-pills .nav-link.active { background-color: #3b82f6; color: white; box-shadow: 0 4px 6px rgba(59, 130, 246, 0.25); }
        .profile-sm-btn { font-size: 0.85rem; padding: 6px 14px; border-radius: 99px; border: 1px solid #e2e8f0; background: white; text-decoration: none; color: #475569; transition: all 0.2s; font-weight: 500; }
        .profile-sm-btn:hover { background: #f8fafc; transform: translateY(-1px); }
        .profile-sm-btn.active { background: #eff6ff; border-color: #3b82f6; color: #2563eb; font-weight: 700; box-shadow: 0 2px 4px rgba(37, 99, 235, 0.1); }
        .table th { font-weight: 600; color: #64748b; background: #f8fafc; border-bottom: 2px solid #e2e8f0; }
        .table td { vertical-align: middle; }
        tr.record-row { transition: 0.2s; }
        tr.record-row:hover { background-color: #f8fafc !important; cursor: pointer; transform: scale(1.005); }

        /* [해결 1] Flatpickr 달력이 모달 뒤로 숨는 문제 해결 */
        .flatpickr-calendar { z-index: 9999 !important; }

        /* 배지 스타일 */
        .badge-custom { padding: 6px 10px; border-radius: 8px; font-weight: 500; font-size: 0.8rem; }
        .bg-danger-super { background-color: #f3e8ff; color: #7e22ce; border: 1px solid #d8b4fe; }
        .bg-danger-high  { background-color: #fee2e2; color: #ef4444; border: 1px solid #fca5a5; }
        .bg-warning-mild { background-color: #fff7ed; color: #f97316; border: 1px solid #fdba74; }
        .bg-success-ok   { background-color: #dcfce7; color: #16a34a; border: 1px solid #86efac; }
        .bg-info-low     { background-color: #eff6ff; color: #3b82f6; border: 1px solid #93c5fd; }
    </style>
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
        <form action="/heat/add" method="post" class="modal-content border-0 shadow">
            <input type="hidden" name="childId" value="${childId}">
            <input type="hidden" name="childName" value="${childName}">
            <div class="modal-header border-0 pb-0"><h5 class="modal-title fw-bold">체온 기록하기</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <div class="mb-3"><label class="form-label fw-bold">체온 (℃)</label><input type="number" step="0.1" name="temperature" class="form-control form-control-lg" placeholder="36.5" required></div>
                <div class="mb-3"><label class="form-label fw-bold">측정 일시</label><input type="text" name="measureDateTime" class="form-control datepicker" required style="background:white;"></div>
                <div class="mb-3"><label class="form-label fw-bold">메모</label><textarea name="memo" class="form-control" rows="3"></textarea></div>
            </div>
            <div class="modal-footer border-0 pt-0"><button type="submit" class="btn btn-primary w-100 py-2 fw-bold rounded-3">저장하기</button></div>
        </form>
    </div>
</div>

<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <form action="/heat/update" method="post" class="modal-content border-0 shadow">
            <input type="hidden" name="heatNo" id="edit_heatNo">
            <input type="hidden" name="childId" value="${childId}">
            <input type="hidden" name="childName" value="${childName}">
            <div class="modal-header border-0 pb-0"><h5 class="modal-title fw-bold">기록 수정하기</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <div class="mb-3"><label class="form-label fw-bold">체온 (℃)</label><input type="number" step="0.1" name="temperature" id="edit_temperature" class="form-control form-control-lg" required></div>
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
<script>
    // 1. Flatpickr 초기화 (모달 z-index는 CSS로 해결됨)
    const fpConfig = {
        locale: "ko",
        dateFormat: "Y-m-d H:i",
        enableTime: true,
        time_24hr: true,
        defaultDate: new Date(),
        allowInput: true // 직접 입력 허용
    };

    // 추가/수정 모달 각각 인스턴스 저장
    const addPicker = flatpickr("#addModal .datepicker", fpConfig);
    const editPicker = flatpickr("#editModal .datepicker", fpConfig);


    // 2. 수정 모달 열기 함수 (data 속성 읽기 방식)
    function openEditModal(row) {
        // data-* 속성에서 값 가져오기
        const no = row.getAttribute('data-no');
        const temp = row.getAttribute('data-temp');
        const date = row.getAttribute('data-date');
        const memo = row.getAttribute('data-memo');

        document.getElementById('edit_heatNo').value = no;
        document.getElementById('edit_temperature').value = temp;
        document.getElementById('edit_memo').value = memo;

        // Flatpickr에 날짜 설정 (중요: 단순히 value만 넣으면 달력 UI랑 싱크가 안 맞을 수 있음)
        if (date) {
            editPicker.setDate(date);
        }

        const modal = new bootstrap.Modal(document.getElementById('editModal'));
        modal.show();
    }


    // 3. 차트 설정
    const ctx = document.getElementById('tempChart').getContext('2d');
    const labels = [];
    const dataPoints = [];

    // 데이터 파싱 (최신순 -> 과거순 데이터를 역순으로 삽입)
    <c:forEach var="h" items="${list}" end="14">
    labels.push('${h.measureDate} ${h.measureTime}');
    dataPoints.push(${h.temperature});
    </c:forEach>

    labels.reverse();
    dataPoints.reverse();

    // [해결 2] 동적 Y축 최대값 계산 (40도 넘으면 그래프 뚫고 나가는 문제 해결)
    let maxTemp = 40; // 기본 최대값
    if (dataPoints.length > 0) {
        const dataMax = Math.max(...dataPoints);
        if (dataMax >= 40) {
            maxTemp = dataMax + 1.0; // 데이터가 40 넘으면 여유있게 +1도
        }
    }

    const lastValue = dataPoints.length ? dataPoints[dataPoints.length - 1] : null;

    /* 배경 색상 밴드 플러그인 */
    const temperatureBands = {
        id: 'temperatureBands',
        beforeDraw(chart) {
            const { ctx, chartArea, scales } = chart;
            if (!chartArea) return;
            const y = scales.y;
            const left = chartArea.left;
            const right = chartArea.right;

            // 차트 최대값에 따라 밴드 그리기 (40.5 고정이 아니라 maxTemp 사용 가능하지만, 일단 구간은 고정)
            const bands = [
                { min: 35.0, max: 36.0, color: 'rgba(148,163,184,0.12)' },
                { min: 37.3, max: 38.0, color: 'rgba(253,186,116,0.14)' },
                { min: 38.0, max: 39.0, color: 'rgba(252,165,165,0.14)' },
                { min: 39.0, max: maxTemp + 2, color: 'rgba(216,180,254,0.14)' } // 초고열 구간은 끝까지
            ];

            ctx.save();
            bands.forEach(b => {
                // 현재 차트 범위 내에 있는 경우만 그리기
                const yMaxPixel = y.getPixelForValue(Math.min(b.max, y.max));
                const yMinPixel = y.getPixelForValue(Math.max(b.min, y.min));

                if (yMaxPixel < yMinPixel) { // 캔버스 좌표계는 위가 작고 아래가 큼 (반대 아님 주의, 픽셀값임)
                    ctx.fillStyle = b.color;
                    ctx.fillRect(left, y.getPixelForValue(b.max), right - left, y.getPixelForValue(b.min) - y.getPixelForValue(b.max));
                }
            });
            ctx.restore();
        }
    };

    /* 오른쪽 텍스트 플러그인 */
    const temperatureRightLabels = {
        id: 'temperatureRightLabels',
        afterDraw(chart) {
            const { ctx, chartArea, scales } = chart;
            if (!chartArea) return;
            const y = scales.y;
            const right = chartArea.right;

            ctx.save();
            ctx.textAlign = 'left';
            ctx.textBaseline = 'middle';
            ctx.font = '12px Pretendard, sans-serif';

            const lines = [
                { v: 37.3, text: '37.3℃ · 미열',  color: '#f97316' },
                { v: 38.0, text: '38.0℃ · 고열',  color: '#ef4444' },
                { v: 39.0, text: '39.0℃ · 초고열', color: '#7e22ce' }
            ];

            lines.forEach(l => {
                // 차트 보이는 범위 안에 있을 때만 그리기
                if (l.v <= scales.y.max && l.v >= scales.y.min) {
                    const py = y.getPixelForValue(l.v);
                    ctx.fillStyle = 'rgba(255,255,255,0.85)';
                    ctx.fillRect(right + 4, py - 8, 95, 16);
                    ctx.fillStyle = l.color;
                    ctx.fillText(l.text, right + 6, py);
                }
            });
            ctx.restore();
        }
    };

    new Chart(ctx, {
        type: 'line',
        plugins: [temperatureBands, temperatureRightLabels], // pointValueLabels는 복잡해서 제외 (원하면 추가 가능)
        data: {
            labels,
            datasets: [
                {
                    data: dataPoints,
                    borderColor: '#7f1d1d',
                    borderWidth: 2,
                    tension: 0,
                    fill: false,
                    pointRadius: 4,
                    pointBackgroundColor: '#7f1d1d',
                    pointBorderWidth: 0
                },
                // 기준선 (차트 범위 넘어가도 상관없음)
                { data: labels.map(() => 37.3), borderColor: '#f97316', borderWidth: 1, pointRadius: 0, borderDash: [5,5] },
                { data: labels.map(() => 38.0), borderColor: '#ef4444', borderWidth: 1, pointRadius: 0, borderDash: [5,5] },
                { data: labels.map(() => 39.0), borderColor: '#7e22ce', borderWidth: 1, pointRadius: 0, borderDash: [5,5] }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            layout: { padding: { right: 110 } },
            scales: {
                y: {
                    min: 35,
                    max: maxTemp, // [중요] 계산된 최대값 적용
                    ticks: { stepSize: 0.5 }
                },
                x: {
                    ticks: { autoSkip: true, maxTicksLimit: 6 }
                }
            },
            plugins: {
                legend: { display: false }
            }
        }
    });
</script>
</body>
</html>