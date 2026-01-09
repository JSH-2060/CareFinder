<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>BMI 기록</title>

    <!-- Bootstrap & Chart.js -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        body {
            background: #f0f2f5;
        }

        /* ===== 아바타 ===== */
        .avatar-circle {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            background: linear-gradient(135deg, #34d399, #059669);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            font-weight: 700;
            box-shadow: 0 4px 10px rgba(5, 150, 105, 0.35);
        }

        /* ===== 카드 ===== */
        .card-box {
            background: white;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.05);
            margin-bottom: 20px;
        }

        /* ===== 판정 뱃지 ===== */
        .badge-status {
            padding: 6px 12px;
            border-radius: 999px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .badge-under  { background: #dbeafe; color: #2563eb; }
        .badge-normal { background: #dcfce7; color: #16a34a; }
        .badge-over   { background: #ffedd5; color: #f97316; }
        .badge-obese  { background: #fee2e2; color: #ef4444; }
        .badge-severe { background: #fecaca; color: #b91c1c; }
        .badge-none   { background: #f1f5f9; color: #64748b; }
    </style>

    <script>
        /* ===== BMI 계산 팝업 (가운데 고정) ===== */
        function openPopup(url) {
            const width = 900;
            const height = 750;

            const left = Math.round(
                (window.screenX || window.screenLeft) +
                (window.outerWidth - width) / 2
            );

            const top = Math.round(
                (window.screenY || window.screenTop) +
                (window.outerHeight - height) / 2
            );

            const options =
                "width=" + width +
                ",height=" + height +
                ",left=" + left +
                ",top=" + top +
                ",resizable=yes,scrollbars=yes";

            window.open(url, "bmiPopup", options);
        }

        function toggleDateSearch() {
            const box = document.getElementById('dateSearchBox');
            box.style.display = (box.style.display === 'none') ? 'block' : 'none';
        }
    </script>

    <script>
        function openEdit(bmiNo) {
            const width = 500;
            const height = 600;

            const left = Math.round(
                (window.screenX || window.screenLeft) +
                (window.outerWidth - width) / 2
            );

            const top = Math.round(
                (window.screenY || window.screenTop) +
                (window.outerHeight - height) / 2
            );

            const options =
                "width=" + width +
                ",height=" + height +
                ",left=" + left +
                ",top=" + top +
                ",resizable=yes,scrollbars=yes";

            window.open('/bmi/edit?bmiNo=' + bmiNo, 'bmiEdit', options);
        }
    </script>

</head>

<body>

<div class="container mt-4" style="max-width: 900px;">

    <!-- ===== 헤더 ===== -->
    <div class="card-box p-3 d-flex justify-content-between align-items-center">
        <div class="d-flex align-items-center gap-3">
            <div class="avatar-circle">
                ${fn:substring(childName, 0, 1)}
            </div>
            <div>
                <h5 class="mb-0 fw-bold">${childName}</h5>
                <small class="text-muted">BMI 기록</small>
            </div>
        </div>

        <a href="/heat/select" class="btn btn-sm btn-outline-secondary">
            뒤로
        </a>
    </div>

    <!-- ===== 버튼 ===== -->
    <div class="d-flex justify-content-end gap-2 my-3">
        <button class="btn btn-outline-secondary btn-sm"
                onclick="toggleDateSearch()">
            날짜 검색
        </button>

        <button class="btn btn-primary btn-sm"
                onclick="openPopup('/bmi/form?childId=${childId}&childName=${childName}')">
            BMI 계산
        </button>
    </div>

    <!-- ===== 날짜 검색 ===== -->
    <div id="dateSearchBox" style="display:none;">
        <form action="/bmi/list" method="get" class="row g-2 mb-3">
            <input type="hidden" name="childId" value="${childId}">
            <input type="hidden" name="childName" value="${childName}">

            <div class="col">
                <input type="date" name="startDate" class="form-control"
                       value="${param.startDate}">
            </div>
            <div class="col">
                <input type="date" name="endDate" class="form-control"
                       value="${param.endDate}">
            </div>
            <div class="col-auto">
                <button class="btn btn-secondary">검색</button>
                <a href="/bmi/list?childId=${childId}&childName=${childName}"
                   class="btn btn-outline-secondary">
                    전체
                </a>
            </div>
        </form>
    </div>

    <!-- ===== 그래프 ===== -->
    <div class="card-box p-3">
        <h6 class="fw-bold mb-3">📈 BMI 변화</h6>

        <c:choose>
            <c:when test="${empty graphList}">
                <div class="text-center text-muted py-5">
                    데이터가 없습니다.
                </div>
            </c:when>
            <c:otherwise>
                <canvas id="bmiChart" height="120"></canvas>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- ===== 테이블 ===== -->
    <div class="card-box p-3">
        <h6 class="fw-bold mb-3">📋 상세 기록</h6>

        <table class="table table-hover text-center align-middle">
            <thead class="table-light">
            <tr>
                <th>날짜</th>
                <th>BMI</th>
                <th>판정</th>
                <th>키(cm)</th>
                <th>몸무게(kg)</th>
                <th>관리</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty bmiList}">
                    <tr>
                        <td colspan="6" class="text-muted py-4">
                            BMI 기록이 없습니다.
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="bmi" items="${bmiList}">
                        <tr onclick="openEdit('${bmi.bmiNo}')"
                            style="cursor:pointer;">
                            <td>${bmi.dateStr}</td>
                            <td>
                                <fmt:formatNumber value="${bmi.bmiValue}" pattern="0.00"/>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${bmi.result == '저체중'}">
                                        <span class="badge-status badge-under">저체중</span>
                                    </c:when>
                                    <c:when test="${bmi.result == '정상'}">
                                        <span class="badge-status badge-normal">정상</span>
                                    </c:when>
                                    <c:when test="${bmi.result == '과체중'}">
                                        <span class="badge-status badge-over">과체중</span>
                                    </c:when>
                                    <c:when test="${bmi.result == '비만'}">
                                        <span class="badge-status badge-obese">비만</span>
                                    </c:when>
                                    <c:when test="${bmi.result == '고도비만'}">
                                        <span class="badge-status badge-severe">고도비만</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-status badge-none">기준 없음</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${bmi.height}</td>
                            <td>${bmi.weight}</td>
                            <td>
                                <form action="/bmi/delete" method="post"
                                      onclick="event.stopPropagation();"
                                      onsubmit="return confirm('삭제하시겠습니까?');">
                                    <input type="hidden" name="bmiNo" value="${bmi.bmiNo}">
                                    <input type="hidden" name="childId" value="${childId}">
                                    <input type="hidden" name="childName" value="${childName}">
                                    <button class="btn btn-danger btn-sm">
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

<!-- ===== 차트 ===== -->
<c:if test="${not empty graphList}">
    <script>
        const labels = [
            <c:forEach var="bmi" items="${graphList}" varStatus="s">
            "${bmi.dateStr}"<c:if test="${!s.last}">,</c:if>
            </c:forEach>
        ];

        const values = [
            <c:forEach var="bmi" items="${graphList}" varStatus="s">
            ${bmi.bmiValue}<c:if test="${!s.last}">,</c:if>
            </c:forEach>
        ];

        // labels.reverse();
        // values.reverse();

        new Chart(document.getElementById('bmiChart'), {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    data: values,
                    borderWidth: 2,
                    tension: 0.3,
                    fill: false
                }]
            },
            options: {
                plugins: { legend: { display: false } },
                scales: { y: { suggestedMin: 15, suggestedMax: 35 } }
            }
        });
    </script>
</c:if>

</body>
</html>
