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
    </style>

    <script>
        function openHeightForm() {
            const url =
                '/height/form?childId=${childId}&childName=${childName}';

            window.open(
                url,
                'heightForm',
                'width=500,height=450,scrollbars=no'
            );
        }
    </script>
</head>
<body>

<div class="container">

    <!-- 제목 -->
    <div class="text-center mb-4">
        <h2 class="title">${childName} 키 성장 기록</h2>
        <p class="text-muted">아이의 키 변화를 한눈에 확인하세요</p>
    </div>

    <!-- 키 성장 그래프 -->
    <div class="card mb-4">
        <div class="card-body">
            <h5 class="fw-bold mb-3 text-center">키 성장 그래프</h5>
            <canvas id="heightChart" height="120"></canvas>
        </div>
    </div>

    <!-- 상단 버튼 -->
    <div class="d-flex justify-content-end mb-3">
        <button class="btn btn-primary"
                onclick="openHeightForm()">
            키 추가
        </button>
    </div>

    <!-- 키 기록 목록 -->
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
                            <tr>
                                <td>${h.recordDate}</td>
                                <td><strong>${h.height}</strong></td>
                                <td>
                                    <form action="/height/delete" method="post" style="display:inline;">
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

    <!-- 하단 버튼 -->
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

    // 날짜 오름차순
    heightLabels.reverse();
    heightData.reverse();
</script>

<!-- Chart.js -->
<script>
    const ctx = document.getElementById('heightChart').getContext('2d');

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: heightLabels,
            datasets: [{
                label: '키 (cm)',
                data: heightData,
                tension: 0.3,
                fill: true,
                backgroundColor: 'rgba(13,110,253,0.15)',
                borderColor: '#0d6efd',
                borderWidth: 3,
                pointRadius: 4,
                pointBackgroundColor: '#0d6efd'
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: true }
            },
            scales: {
                y: {
                    beginAtZero: false,
                    ticks: {
                        callback: value => value + ' cm'
                    }
                }
            }
        }
    });
</script>

</body>
</html>
