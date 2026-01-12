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
        body { background:#f0f2f5; }

        /* ===== 아바타 ===== */
        .avatar-circle-bmi{
            width: 44px;
            height: 44px;
            border-radius: 50%;
            background: linear-gradient(135deg, #34d399, #059669);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
        }

        /* ===== BMI 탭 ===== */
        .nav-pills .nav-link.bmi-active{
            background: linear-gradient(135deg, #34d399, #059669);
            color: white;
        }

        /* ===== BMI 계산 버튼 ===== */
        .btn-bmi{
            background: linear-gradient(135deg, #34d399, #059669);
            border: none;
            color: white;
            font-weight: bold;
        }
        .btn-bmi:hover{
            filter: brightness(0.95);
            color: white;
        }

        /* ===== 카드 ===== */
        .card-box{
            background:#fff;
            border-radius:16px;
            box-shadow:0 4px 20px rgba(0,0,0,.05);
            margin-bottom:20px;
        }

        /* ===== 판정 뱃지 ===== */
        .badge-status{ padding:6px 12px;border-radius:999px;font-size:.85rem;font-weight:600; }
        .badge-under  { background:#dbeafe;color:#2563eb; }
        .badge-normal { background:#dcfce7;color:#16a34a; }
        .badge-over   { background:#ffedd5;color:#f97316; }
        .badge-obese  { background:#fee2e2;color:#ef4444; }
        .badge-severe { background:#fecaca;color:#b91c1c; }
        .badge-none   { background:#f1f5f9;color:#64748b; }

        /* ===== BMI 기준바 ===== */
        .bmi-wrapper{ position:relative; margin-top:12px; }
        .bmi-track{
            display:flex;
            height:38px;
            border-radius:999px;
            overflow:hidden;
        }
        .bmi-seg{
            flex:0 0 auto;
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:.85rem;
            font-weight:600;
            color:#fff;
        }
        /* 성인 5등분 / 청소년 4등분 */
        .bmi-track[data-type="adult"] .bmi-seg{ width:20%; }
        .bmi-track[data-type="child"] .bmi-seg{ width:25%; }

        .seg-1{background:#93c5fd;}
        .seg-2{background:#60a5fa;}
        .seg-3{background:#fbbf24;}
        .seg-4{background:#f87171;}
        .seg-5{background:#fb7185;}

        /* 화살표(overflow 잘림 방지: track 밖, wrapper 안) */
        .bmi-pointer{
            position:absolute;
            top:-22px;
            transform:translateX(-50%);
            pointer-events:none;
            z-index:10;
        }
        .bmi-pointer::after{
            content:"▼";
            display:block;
            text-align:center;
            font-size:12px;
            color:#111827;
            line-height:12px;
        }
        .bmi-pointer-label{
            background:#111827;
            color:#fff;
            padding:2px 6px;
            border-radius:8px;
            font-size:11px;
            font-weight:600;
            display:inline-block;
            margin-bottom:2px;
        }

        /* 경계 숫자 */
        .bmi-cuts{
            position:relative;
            height:20px;
            margin-top:6px;
        }
        .bmi-cuts .cut{
            position:absolute;
            transform:translateX(-50%);
            font-size:11px;
            color:#374151;
            white-space:nowrap;
        }
        .bmi-desc{ font-size:12px;color:#6b7280;margin-top:4px; }

        /* 비활성 탭 색상 통일 */
        .nav-pills .nav-link {
            color: #555 !important;
            font-weight: 600;
        }
        .nav-pills .nav-link.bmi-active{
            background: linear-gradient(135deg, #34d399, #059669);
            color: #fff !important;
            font-weight: 700;
        }



    </style>

    <script>
        /* ===== BMI 계산 팝업 (가운데 고정) ===== */
        function openPopup(url) {
            const width = 900;
            const height = 750;

            const left = Math.round((window.screenX || window.screenLeft) + (window.outerWidth - width) / 2);
            const top  = Math.round((window.screenY || window.screenTop) + (window.outerHeight - height) / 2);

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

        function openEdit(bmiNo) {
            const width = 500;
            const height = 600;

            const left = Math.round((window.screenX || window.screenLeft) + (window.outerWidth - width) / 2);
            const top  = Math.round((window.screenY || window.screenTop) + (window.outerHeight - height) / 2);

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
<div class="container mt-4" style="max-width:900px;">

    <!-- ===== 헤더 ===== -->
    <div class="card-box p-3">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div class="d-flex align-items-center gap-3">
                <div class="avatar-circle-bmi">
                    <c:choose>
                        <c:when test="${not empty childName}">
                            ${fn:substring(childName,0,1)}
                        </c:when>
                        <c:otherwise>Me</c:otherwise>
                    </c:choose>
                </div>
                <div>
                    <h5 class="mb-0 fw-bold">${childName}</h5>
                    <small class="text-muted">BMI 기록장</small>
                </div>
            </div>
            <a href="/" class="btn btn-sm btn-outline-secondary">홈으로</a>
        </div>

        <!-- ===== 탭 + 프로필 ===== -->
        <div class="d-flex justify-content-between align-items-end border-top pt-3">

            <!-- ✅ 탭 : 체온 → 백신 → BMI -->
            <ul class="nav nav-pills">
                <li class="nav-item">
                    <c:url value="/heat/list" var="heatUrl">
                        <c:param name="childId" value="${childId}"/>
                        <c:param name="childName" value="${childName}"/>
                    </c:url>
                    <a class="nav-link" href="${heatUrl}">체온</a>
                </li>

                <li class="nav-item">
                    <c:url value="/vaccine/list" var="vacUrl">
                        <c:param name="childId" value="${childId}"/>
                        <c:param name="childName" value="${childName}"/>
                    </c:url>
                    <a class="nav-link" href="${vacUrl}">백신</a>
                </li>

                <li class="nav-item">
                    <a class="nav-link bmi-active" href="#">BMI</a>
                </li>

                <li class="nav-item">
                    <c:url value="/height/list" var="heightUrl">
                        <c:param name="childId" value="${childId}"/>
                        <c:param name="childName" value="${childName}"/>
                    </c:url>
                    <a class="nav-link" href="${heightUrl}">키성장</a>
                </li>

            </ul>

            <!-- ✅ 프로필 : 나 → 자녀 → + -->
            <div class="d-flex gap-1">

                <!-- 나 -->
                <c:url value="/bmi/list" var="meUrl">
                    <c:param name="childId" value="0"/>
                    <c:param name="childName" value="${sessionScope.userName}"/>
                </c:url>
                <a href="${meUrl}"
                   class="profile-sm-btn ${empty param.childId or param.childId eq '0' ? 'active' : ''}">
                    나
                </a>

                <!-- 자녀 -->
                <c:forEach var="c" items="${childList}">
                    <c:url value="/bmi/list" var="childUrl">
                        <c:param name="childId" value="${c.childId}"/>
                        <c:param name="childName" value="${c.childName}"/>
                    </c:url>
                    <a href="${childUrl}"
                       class="profile-sm-btn ${param.childId eq c.childId ? 'active' : ''}">
                            ${c.childName}
                    </a>
                </c:forEach>

                <!-- 추가 -->
                <a href="/child/add" class="profile-sm-btn">+</a>
            </div>
        </div>
    </div>

    <!-- ===== 버튼 (기존 BMI 기능 그대로) ===== -->
    <div class="d-flex justify-content-end gap-2 my-3">
        <button class="btn btn-outline-secondary btn-sm" onclick="toggleDateSearch()">날짜 검색</button>
        <button class="btn btn-bmi"
                onclick="openPopup('/bmi/form?childId=${childId}&childName=${childName}')">
            BMI 계산
        </button>
    </div>

    <!-- ===== 날짜 검색 박스 ===== -->
    <div id="dateSearchBox" style="display:none;">
        <div class="card-box p-3 mb-3">
            <form action="/bmi/list" method="get" class="row g-2 align-items-end">

                <!-- child 유지 -->
                <input type="hidden" name="childId" value="${childId}">
                <input type="hidden" name="childName" value="${childName}">

                <div class="col">
                    <label class="form-label mb-1">시작 날짜</label>
                    <input type="date"
                           name="startDate"
                           class="form-control"
                           value="${param.startDate}">
                </div>

                <div class="col">
                    <label class="form-label mb-1">종료 날짜</label>
                    <input type="date"
                           name="endDate"
                           class="form-control"
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
    </div>

    <!-- ===== 그래프 ===== -->
    <div class="card-box p-3">
        <h6 class="fw-bold mb-3">📈 BMI 변화</h6>

        <c:choose>
            <c:when test="${empty graphList}">
                <div class="text-center text-muted py-5">데이터가 없습니다.</div>
            </c:when>
            <c:otherwise>
                <canvas id="bmiChart" height="120"></canvas>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- ===== BMI 기준바 + 경계 숫자 + 화살표 ===== -->
    <c:if test="${latestBmi ne null}">
        <div class="card-box p-3">
            <h6 class="fw-bold mb-2">📊 BMI 기준</h6>

            <!-- 성인 -->
            <c:if test="${latestBmi.adult}">
                <div class="bmi-wrapper">
                    <div class="bmi-track" data-type="adult">
                        <div class="bmi-seg seg-1">저체중</div>
                        <div class="bmi-seg seg-2">정상</div>
                        <div class="bmi-seg seg-3">과체중</div>
                        <div class="bmi-seg seg-4">비만</div>
                        <div class="bmi-seg seg-5">고도비만</div>
                    </div>

                    <!-- 화살표: Service에서 계산한 bmiPercent 사용 -->
                    <div class="bmi-pointer" style="left:${latestBmi.bmiPercent}%;">
                        <span class="bmi-pointer-label">
                            <fmt:formatNumber value="${latestBmi.bmiValue}" pattern="0.00"/>
                        </span>
                    </div>
                </div>

                <div class="bmi-cuts">
                    <span class="cut" style="left:20%">${latestBmi.cut1}</span>
                    <span class="cut" style="left:40%">${latestBmi.cut2}</span>
                    <span class="cut" style="left:60%">${latestBmi.cut3}</span>
                    <span class="cut" style="left:80%">${latestBmi.cut4}</span>
                </div>
                <div class="bmi-desc">WHO BMI 기준</div>
            </c:if>

            <!-- 청소년 -->
            <c:if test="${!latestBmi.adult}">
                <div class="bmi-wrapper">
                    <div class="bmi-track" data-type="child">
                        <div class="bmi-seg seg-1">저체중</div>
                        <div class="bmi-seg seg-2">정상</div>
                        <div class="bmi-seg seg-3">과체중</div>
                        <div class="bmi-seg seg-4">비만</div>
                    </div>

                    <div class="bmi-pointer" style="left:${latestBmi.bmiPercent}%;">
                        <span class="bmi-pointer-label">
                            <fmt:formatNumber value="${latestBmi.bmiValue}" pattern="0.00"/>
                        </span>
                    </div>
                </div>

                <div class="bmi-cuts">
                    <span class="cut" style="left:25%">${latestBmi.cut1}</span>
                    <span class="cut" style="left:50%">${latestBmi.cut2}</span>
                    <span class="cut" style="left:75%">${latestBmi.cut3}</span>
                </div>
                <div class="bmi-desc">P5 / P85 / P95 기준</div>
            </c:if>
        </div>
    </c:if>

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
                        <td colspan="6" class="text-muted py-4">BMI 기록이 없습니다.</td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="bmi" items="${bmiList}">
                        <tr onclick="openEdit('${bmi.bmiNo}')" style="cursor:pointer;">
                            <td>${bmi.dateStr}</td>
                            <td><fmt:formatNumber value="${bmi.bmiValue}" pattern="0.00"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${bmi.result == '저체중'}"><span class="badge-status badge-under">저체중</span></c:when>
                                    <c:when test="${bmi.result == '정상'}"><span class="badge-status badge-normal">정상</span></c:when>
                                    <c:when test="${bmi.result == '과체중'}"><span class="badge-status badge-over">과체중</span></c:when>
                                    <c:when test="${bmi.result == '비만'}"><span class="badge-status badge-obese">비만</span></c:when>
                                    <c:when test="${bmi.result == '고도비만'}"><span class="badge-status badge-severe">고도비만</span></c:when>
                                    <c:otherwise><span class="badge-status badge-none">기준 없음</span></c:otherwise>
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

<!-- ===== 차트 ===== -->
<c:if test="${not empty graphList}">
    <script>
        const labels = [
            <c:forEach var="b" items="${graphList}" varStatus="s">
            "${b.dateStr}"<c:if test="${!s.last}">,</c:if>
            </c:forEach>
        ];

        const values = [
            <c:forEach var="b" items="${graphList}" varStatus="s">
            ${b.bmiValue}<c:if test="${!s.last}">,</c:if>
            </c:forEach>
        ];

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
