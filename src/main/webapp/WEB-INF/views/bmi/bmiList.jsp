<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>BMI 기록</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- BMI CSS -->
    <link rel="stylesheet" href="/css/bmi.css">

    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
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
            <div class="profile-wrap d-flex gap-1">

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
                data-bs-toggle="modal"
                data-bs-target="#bmiModal">
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
        <h6 class="fw-bold mb-3"> BMI 변화</h6>

        <c:choose>
            <c:when test="${empty graphList}">
                <div class="text-center text-muted py-5">데이터가 없습니다.</div>
            </c:when>
            <c:otherwise>
                <canvas id="bmiChart" height="120"></canvas>
            </c:otherwise>
        </c:choose>
    </div>

    <c:if test="${not empty bmiList}">
        <!-- 사이드바 기준 BMI: 현재 화면(날짜검색 반영) 기준 최신 -->
        <c:set var="sidebarBmi" value="${bmiList[0]}" />

        <!-- 성인 -->
        <c:if test="${sidebarBmi.adult}">
            <div class="card-box p-3">
                <h6 class="fw-bold mb-2">📊 BMI 기준</h6>

                <div class="bmi-wrapper">
                    <div class="bmi-track" data-type="adult">
                        <div class="bmi-seg seg-1">저체중</div>
                        <div class="bmi-seg seg-2">정상</div>
                        <div class="bmi-seg seg-3">과체중</div>
                        <div class="bmi-seg seg-4">비만</div>
                        <div class="bmi-seg seg-5">고도비만</div>
                    </div>

                    <!-- 화살표 -->
                    <div class="bmi-pointer" style="left:${sidebarBmi.bmiPercent}%;">
                    <span class="bmi-pointer-label">
                        <fmt:formatNumber value="${sidebarBmi.bmiValue}" pattern="0.00"/>
                    </span>
                    </div>
                </div>

                <div class="bmi-cuts">
                    <span class="cut" style="left:20%">${sidebarBmi.cut1}</span>
                    <span class="cut" style="left:40%">${sidebarBmi.cut2}</span>
                    <span class="cut" style="left:60%">${sidebarBmi.cut3}</span>
                    <span class="cut" style="left:80%">${sidebarBmi.cut4}</span>
                </div>
                <div class="bmi-desc">WHO BMI 기준</div>
            </div>
        </c:if>

        <!-- 청소년 -->
        <c:if test="${!sidebarBmi.adult}">
            <div class="card-box p-3">
                <h6 class="fw-bold mb-2">📊 BMI 기준</h6>

                <div class="bmi-wrapper">
                    <div class="bmi-track" data-type="child">
                        <div class="bmi-seg seg-1">저체중</div>
                        <div class="bmi-seg seg-2">정상</div>
                        <div class="bmi-seg seg-3">과체중</div>
                        <div class="bmi-seg seg-4">비만</div>
                    </div>

                    <!-- 화살표 -->
                    <div class="bmi-pointer" style="left:${sidebarBmi.bmiPercent}%;">
                    <span class="bmi-pointer-label">
                        <fmt:formatNumber value="${sidebarBmi.bmiValue}" pattern="0.00"/>
                    </span>
                    </div>
                </div>

                <div class="bmi-cuts">
                    <span class="cut" style="left:25%">${sidebarBmi.cut1}</span>
                    <span class="cut" style="left:50%">${sidebarBmi.cut2}</span>
                    <span class="cut" style="left:75%">${sidebarBmi.cut3}</span>
                </div>
                <div class="bmi-desc">P5 / P85 / P95 기준</div>
            </div>
        </c:if>
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
                        <tr style="cursor:pointer;"
                            onclick="openBmiEditModal(
                                    '${bmi.bmiNo}',
                                    '${bmi.height}',
                                    '${bmi.weight}'
                                    )">
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
                                    <button class="btn btn-sm btn-outline-danger">삭제</button>
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

<!-- BMI JS -->
<script src="/js/bmi.js"></script>

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

        // 🔥 핵심: 시간 순서 뒤집기
        labels.reverse();
        values.reverse();

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
                scales: {
                    y: { suggestedMin: 15, suggestedMax: 35 }
                }
            }
        });
    </script>
</c:if>

<!-- ===== BMI 입력 모달 ===== -->
<div class="modal fade" id="bmiModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <form action="/bmi/insert" method="post" class="w-100">
            <div class="modal-content">

                <div class="modal-header fw-bold">
                    ${childName} BMI 계산
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">

                    <!-- 이전 기록 안내 -->
                    <c:if test="${not empty latestBmi}">
                        <div class="text-muted text-center mb-3" style="font-size:12px;">
                            이전 기록(${latestBmi.recordDate}) 기준으로 자동 입력되었습니다.
                        </div>
                    </c:if>

                    <!-- hidden -->
                    <input type="hidden" name="childId" value="${childId}">
                    <input type="hidden" name="childName" value="${childName}">

                    <!-- 키 -->
                    <div class="mb-3">
                        <label class="form-label">키 (cm)</label>
                        <input type="number"
                               name="height"
                               class="form-control"
                               step="0.1"
                               min="80"
                               max="250"
                               value="${latestBmi != null ? latestBmi.height : ''}"
                               required>
                    </div>

                    <!-- 몸무게 -->
                    <div class="mb-3">
                        <label class="form-label">몸무게 (kg)</label>
                        <input type="number"
                               name="weight"
                               class="form-control"
                               step="0.1"
                               min="9"
                               max="149.9"
                               value="${latestBmi != null ? latestBmi.weight : ''}"
                               required>
                    </div>

                </div>

                <div class="modal-footer">
                    <button type="submit" class="btn btn-bmi w-100">
                        계산 & 저장
                    </button>
                </div>

            </div>
        </form>
    </div>
</div>

<!-- ===== BMI 수정 모달 ===== -->
<div class="modal fade" id="bmiEditModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <form action="/bmi/update" method="post" class="w-100">
            <div class="modal-content">

                <div class="modal-header fw-bold">
                    BMI 수정
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">

                    <input type="hidden" name="bmiNo" id="editBmiNo">
                    <input type="hidden" name="childId" value="${childId}">
                    <input type="hidden" name="childName" value="${childName}">

                    <div class="mb-3">
                        <label class="form-label">키 (cm)</label>
                        <input type="number"
                               step="0.1"
                               name="height"
                               id="editHeight"
                               min="80"
                               max="250"
                               class="form-control"
                               required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">몸무게 (kg)</label>
                        <input type="number"
                               step="0.1"
                               name="weight"
                               id="editWeight"
                               min="9"
                               max="149.9"
                               class="form-control"
                               required>
                    </div>

                </div>

                <div class="modal-footer">
                    <button type="submit" class="btn btn-bmi w-100">
                        수정 저장
                    </button>
                </div>

            </div>
        </form>
    </div>
</div>


</body>
</html>
