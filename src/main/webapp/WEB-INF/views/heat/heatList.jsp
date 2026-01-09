<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<% request.setCharacterEncoding("utf-8"); %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${targetName} 열 관리</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { background: #f0f2f5; font-family: 'Pretendard', sans-serif; color: #333; }
        .main-container { max-width: 650px; margin: 0 auto; padding: 20px 10px; }
        .card-box { background: white; border-radius: 20px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); border: none; margin-bottom: 20px; overflow: hidden; }
        .profile-header { background: white; padding: 20px; border-radius: 20px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); display: flex; align-items: center; justify-content: space-between; margin-bottom: 25px; }
        .profile-img { width: 50px; height: 50px; background: linear-gradient(135deg, #FF9966, #FF5E62); border-radius: 50%; color: white; display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: bold; box-shadow: 0 4px 10px rgba(255, 94, 98, 0.3); }
        .badge-custom { padding: 5px 10px; border-radius: 8px; font-size: 0.8rem; font-weight: 600; }
        .badge-danger { background: #fee2e2; color: #ef4444; }
        .badge-warning { background: #ffedd5; color: #f97316; }
        .badge-success { background: #dcfce7; color: #16a34a; }
        .badge-primary { background: #dbeafe; color: #2563eb; }
        .table-custom th { background: #f8f9fa; font-size: 0.85rem; color: #666; font-weight: 600; border: none; }
        .table-custom td { font-size: 0.95rem; vertical-align: middle; border-bottom: 1px solid #f0f0f0; }
        .table-custom tr:hover { background-color: #fcfcfc; cursor: pointer; }
    </style>
</head>
<body>

<div class="main-container">
    <div class="profile-header">
        <div class="profile-info">
            <div class="profile-img">
                <c:out value="${fn:substring(targetName, 0, 1)}" default="?" />
            </div>
            <div>
                <h5 style="margin:0; font-weight: 800; font-size: 1.2rem;">${targetName}</h5>
                <span style="font-size: 0.85rem; color: #888;">열 관리 기록</span>
            </div>
        </div>
        <div>
            <button class="btn btn-sm btn-outline-secondary rounded-pill px-3" onclick="location.href='/heat/select'">뒤로</button>
            <button class="btn btn-sm btn-dark rounded-pill px-3 ms-1" onclick="openUpload()">+ 기록</button>
        </div>
    </div>

    <div class="card-box p-3">
        <h6 class="fw-bold mb-3 p-2">📈 체온 변화</h6>
        <div style="height: 250px;">
            <c:if test="${empty graphList}">
                <div class="text-center py-5 text-muted" style="font-size: 0.9rem;">데이터가 없습니다.</div>
            </c:if>
            <canvas id="tempChart" style="display: ${empty graphList ? 'none' : 'block'};"></canvas>
        </div>
    </div>

    <div class="card-box">
        <h6 class="fw-bold p-3 border-bottom m-0">📋 상세 기록</h6>
        <div class="table-responsive">
            <table class="table table-custom m-0 text-center">
                <thead>
                <tr>
                    <th>날짜</th>
                    <th>시간</th>
                    <th>체온</th>
                    <th class="text-start">메모</th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty heatList}">
                        <tr><td colspan="4" class="py-4 text-muted">기록이 없습니다.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="h" items="${heatList}">
                            <tr onclick="openEdit('${h.heatNo}')">

                                <td class="text-secondary" style="font-size: 0.85rem;">
                                        ${h.dayStr} </td>
                                <td class="fw-bold">
                                        ${h.timeStr} </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${h.temperature >= 38.0}"><span class="badge-custom badge-danger">${h.temperature}℃</span></c:when>
                                        <c:when test="${h.temperature >= 37.0}"><span class="badge-custom badge-warning">${h.temperature}℃</span></c:when>
                                        <c:when test="${h.temperature >= 36.0}"><span class="badge-custom badge-success">${h.temperature}℃</span></c:when>
                                        <c:otherwise><span class="badge-custom badge-primary">${h.temperature}℃</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-start text-truncate" style="max-width: 120px; font-size: 0.9rem; color:#555;">${h.memo}</td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    function openUpload() {
        // childId를 꼭 넘겨야 404 에러 안 남
        window.open('/heat/heatupload?childId=${childId}&childName=${targetName}', 'pop', 'width=450,height=600');
    }
    function openEdit(heatNo) {
        window.open('/heat/heatedit?heatNo=' + heatNo, 'editPop', 'width=450,height=600');
    }

    /* 차트 스크립트 */
    const labels = [];
    const tempData = [];

    // 그래프 데이터 (DTO의 날짜 변환 활용)
    <c:forEach var="h" items="${graphList}">
    labels.push("${h.dayStr} ${h.timeStr}"); // 날짜 시간 조합
    tempData.push(${h.temperature});
    </c:forEach>

    // 데이터 역순 정렬 (과거 -> 현재)
    if (tempData.length > 0) {
        labels.reverse();
        tempData.reverse();

        const ctx = document.getElementById('tempChart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: '체온', data: tempData, borderColor: '#FF5E62', tension: 0.3, fill: false
                }]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                scales: { y: { min: 35, max: 41 } },
                plugins: { legend: { display: false } }
            }
        });
    }
</script>
</body>
</html>