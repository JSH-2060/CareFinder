<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>키 성장 기록</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        body {
            background: #f5f7fb;
            padding-top: 40px;
        }
        .card {
            border-radius: 16px;
            box-shadow: 0 6px 20px rgba(0,0,0,0.08);
        }
        .title {
            font-weight: 800;
        }
        table th {
            background: #f1f3f8;
        }
        tr.data-row {
            cursor: pointer;
        }
        tr.data-row:hover {
            background-color: #f1f5ff;
        }
    </style>

    <script>
        function openHeightForm() {
            const url =
                '/height/form?childId=${childId}&childName=${childName}';
            window.open(url, 'heightForm', 'width=500,height=450');
        }

        function openHeightEdit(heightId, recordDate, height) {
            const url =
                '/height/edit'
                + '?heightId=' + heightId
                + '&childId=${childId}'
                + '&childName=${childName}'
                + '&recordDate=' + recordDate
                + '&height=' + height;

            window.open(url, 'heightEdit', 'width=500,height=450');
        }
    </script>
</head>
<body>

<div class="container">

    <!-- 제목 -->
    <div class="text-center mb-4">
        <h2 class="title">${childName} 키 성장 기록</h2>
        <p class="text-muted">기록을 클릭하면 수정할 수 있습니다</p>
    </div>

    <!-- 그래프 -->
    <div class="card mb-4">
        <div class="card-body">
            <h5 class="fw-bold mb-3 text-center">키 성장 그래프</h5>
            <canvas id="heightChart" height="120"></canvas>
        </div>
    </div>

    <!-- 상단 버튼 -->
    <div class="d-flex justify-content-end mb-3">
        <button class="btn btn-primary" onclick="openHeightForm()">키 추가</button>
    </div>

    <!-- 리스트 -->
    <div class="card">
        <div class="card-body p-0">
            <table class="table table-hover mb-0 text-center">
                <thead>
                <tr>
                    <th>측정 날짜</th>
                    <th>키 (cm)</th>
                    <th>관리</th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty list}">
                        <tr>
                            <td colspan="3" class="py-4 text-muted">
                                아직 등록된 키 기록이 없습니다.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="h" items="${list}">
                            <tr class="data-row"
                                onclick="openHeightEdit(
                                        '${h.heightId}',
                                        '${h.recordDate}',
                                        '${h.height}'
                                        )">
                                <td>${h.recordDate}</td>
                                <td><strong>${h.height}</strong></td>
                                <td>
                                    <form action="/height/delete" method="post"
                                          style="display:inline;"
                                          onclick="event.stopPropagation();">
                                        <input type="hidden" name="heightId" value="${h.heightId}">
                                        <input type="hidden" name="childId" value="${childId}">
                                        <input type="hidden" name="childName" value="${childName}">
                                        <button class="btn btn-sm btn-outline-danger"
                                                onclick="return confirm('삭제하시겠습니까?')">
                                            삭제
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </div>

    <div class="text-center mt-4">
        <a href="/heat/childSelect" class="btn btn-secondary rounded-pill px-4">
            대상 선택으로
        </a>
    </div>
</div>

<!-- 그래프 데이터 -->
<script>
    const heightLabels = [];
    const heightData = [];

    <c:forEach var="h" items="${list}">
    heightLabels.push("${h.recordDate}");
    heightData.push(${h.height});
    </c:forEach>

    heightLabels.reverse();
    heightData.reverse();
</script>

<script>
    new Chart(document.getElementById('heightChart'), {
        type: 'line',
        data: {
            labels: heightLabels,
            datasets: [{
                label: '키 (cm)',
                data: heightData,
                tension: 0.3,
                fill: true,
                borderWidth: 3
            }]
        },
        options: {
            responsive: true,
            scales: {
                y: {
                    ticks: {
                        callback: v => v + ' cm'
                    }
                }
            }
        }
    });
</script>

</body>
</html>
