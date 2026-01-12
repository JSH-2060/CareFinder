<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>키 성장 기록</title>

    <!-- Bootstrap & Chart.js -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        body { background:#f0f2f5; }

        /* ===== 아바타 ===== */
        .avatar-circle{
            width:44px;height:44px;border-radius:50%;
            background:linear-gradient(135deg,#5eead4,#14b8a6);
            color:#fff;font-weight:700;
            display:flex;align-items:center;justify-content:center;
            font-size:18px;
        }

        /* ===== 카드 ===== */
        .card-box{
            background:#fff;
            border-radius:16px;
            box-shadow:0 4px 20px rgba(0,0,0,.05);
            margin-bottom:20px;
        }

        .nav-pills .nav-link {
            color:#555 !important;
            font-weight:600;
        }
        .nav-pills .nav-link.active {
            background:#14b8a6;
            color:#fff !important;
        }

        tr.data-row { cursor:pointer; }
        tr.data-row:hover { background:#f0fdfa; }
    </style>

    <script>
        function openHeightForm() {
            openCenter(
                '/height/form?childId=${childId}&childName=${childName}',
                500, 450
            );
        }

        function openHeightEdit(heightId) {
            openCenter('/height/edit?heightId=' + heightId, 500, 500);
        }

        function openCenter(url, w, h) {
            const left = (screen.width - w) / 2;
            const top  = (screen.height - h) / 2;
            window.open(url, 'popup',
                `width=${w},height=${h},left=${left},top=${top}`);
        }
    </script>
</head>

<body>
<div class="container mt-4" style="max-width:900px;">

    <!-- ===== 헤더 ===== -->
    <div class="card-box p-3">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div class="d-flex align-items-center gap-3">
                <div class="avatar-circle">
                    <c:choose>
                        <c:when test="${not empty childName}">
                            ${fn:substring(childName,0,1)}
                        </c:when>
                        <c:otherwise>Me</c:otherwise>
                    </c:choose>
                </div>
                <div>
                    <h5 class="mb-0 fw-bold">${childName}</h5>
                    <small class="text-muted">키 성장 기록</small>
                </div>
            </div>
            <a href="/" class="btn btn-sm btn-outline-secondary">홈으로</a>
        </div>

        <!-- ===== 탭 + 프로필 ===== -->
        <div class="d-flex justify-content-between align-items-end border-top pt-3">

            <!-- 탭 -->
            <ul class="nav nav-pills">
                <li class="nav-item">
                    <a class="nav-link"
                       href="/heat/list?childId=${childId}&childName=${childName}">
                        체온
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link"
                       href="/vaccine/list?childId=${childId}&childName=${childName}">
                        백신
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link"
                       href="/bmi/list?childId=${childId}&childName=${childName}">
                        BMI
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link active">키성장</a>
                </li>
            </ul>

            <!-- 프로필 -->
            <div class="d-flex gap-1">
                <a href="/height/list?childId=0&childName=${sessionScope.userName}"
                   class="profile-sm-btn ${childId == 0 ? 'active' : ''}">
                    나
                </a>

                <c:forEach var="c" items="${childList}">
                    <a href="/height/list?childId=${c.childId}&childName=${c.childName}"
                       class="profile-sm-btn ${childId == c.childId ? 'active' : ''}">
                            ${c.childName}
                    </a>
                </c:forEach>

                <a href="/child/add" class="profile-sm-btn">+</a>
            </div>
        </div>
    </div>

    <!-- ===== 버튼 ===== -->
    <div class="d-flex justify-content-end my-3">
        <button class="btn btn-primary btn-sm" onclick="openHeightForm()">
            키 기록 추가
        </button>
    </div>

    <!-- ===== 그래프 ===== -->
    <div class="card-box p-3">
        <h6 class="fw-bold mb-3">📈 키 성장 변화</h6>
        <c:choose>
            <c:when test="${empty list}">
                <div class="text-center text-muted py-5">데이터가 없습니다.</div>
            </c:when>
            <c:otherwise>
                <canvas id="heightChart" height="120"></canvas>
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
                <th>키 (cm)</th>
                <th>관리</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty list}">
                    <tr>
                        <td colspan="3" class="text-muted py-4">
                            키 기록이 없습니다.
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="h" items="${list}">
                        <tr class="data-row"
                            onclick="openHeightEdit('${h.heightId}')">
                            <td>${h.recordDate}</td>
                            <td>${h.height}</td>
                            <td>
                                <form action="/height/delete" method="post"
                                      onclick="event.stopPropagation();"
                                      onsubmit="return confirm('삭제하시겠습니까?');">
                                    <input type="hidden" name="heightId" value="${h.heightId}">
                                    <input type="hidden" name="childId" value="${childId}">
                                    <input type="hidden" name="childName" value="${childName}">
                                    <button class="btn btn-danger btn-sm">삭제</button>
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

<!-- ===== 그래프 스크립트 ===== -->
<c:if test="${not empty list}">
    <script>
        const labels = [
            <c:forEach var="h" items="${list}" varStatus="s">
            "${h.recordDate}"<c:if test="${!s.last}">,</c:if>
            </c:forEach>
        ].reverse();

        const values = [
            <c:forEach var="h" items="${list}" varStatus="s">
            ${h.height}<c:if test="${!s.last}">,</c:if>
            </c:forEach>
        ].reverse();

        new Chart(document.getElementById('heightChart'), {
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
                scales: {
                    y: { ticks: { callback:v=>v+' cm' } }
                }
            }
        });
    </script>
</c:if>

</body>
</html>
