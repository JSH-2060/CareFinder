<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>백신 관리</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/material_blue.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <link href="/css/vaccineList.css" rel="stylesheet">
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
                <div>
                    <h5 class="mb-0 fw-bold">${childName}</h5>
                    <small class="text-muted">백신 접종 내역</small>
                </div>
            </div>
            <a href="/" class="btn btn-sm btn-outline-secondary">홈으로</a>
        </div>

        <div class="d-flex justify-content-between align-items-end border-top pt-3">
            <ul class="nav nav-pills">
                <li class="nav-item">
                    <c:url value="/heat/list" var="heatUrl">
                        <c:param name="childId" value="${childId}"/>
                        <c:param name="childName" value="${childName}"/>
                    </c:url>
                    <a class="nav-link" href="${heatUrl}">체온</a>
                </li>
                <li class="nav-item"><a class="nav-link active" href="#">백신</a></li>
                <li class="nav-item">
                    <c:url value="/bmi/list" var="bmiUrl">
                        <c:param name="childId" value="${childId}"/>
                        <c:param name="childName" value="${childName}"/>
                    </c:url>
                    <a class="nav-link" href="${bmiUrl}">BMI</a>
                </li>
                <li class="nav-item">
                    <c:url value="/height/list" var="heightUrl">
                        <c:param name="childId" value="${childId}"/>
                        <c:param name="childName" value="${childName}"/>
                    </c:url>
                    <a class="nav-link" href="${heightUrl}">키성장</a>
                </li>
            </ul>

            <div class="d-flex gap-1">
                <c:url value="/vaccine/list" var="meUrl">
                    <c:param name="childId" value="0"/>
                    <c:param name="childName" value="${sessionScope.userName}"/>
                </c:url>
                <a href="${meUrl}" class="profile-sm-btn ${empty param.childId or param.childId eq '0' ? 'active' : ''}">나</a>

                <c:forEach var="c" items="${childList}">
                    <c:url value="/vaccine/list" var="childUrl">
                        <c:param name="childId" value="${c.childId}"/>
                        <c:param name="childName" value="${c.childName}"/>
                    </c:url>
                    <a href="${childUrl}" class="profile-sm-btn ${param.childId eq c.childId ? 'active' : ''}">${c.childName}</a>
                </c:forEach>
                <a href="/child/add" class="profile-sm-btn">+</a>
            </div>
        </div>
    </div>

    <div class="d-flex justify-content-end gap-2 my-3">
        <button class="btn btn-primary btn-sm fw-bold" data-bs-toggle="modal" data-bs-target="#addModal">
            접종 일정 추가
        </button>
    </div>

    <c:set var="totalCount" value="${fn:length(list)}" />
    <c:set var="doneCount" value="0" />
    <c:forEach var="v" items="${list}">
        <c:if test="${v.status eq 'Y'}">
            <c:set var="doneCount" value="${doneCount + 1}" />
        </c:if>
    </c:forEach>

    <c:if test="${totalCount > 0}">
        <div class="row mb-4">
            <div class="col-md-6">
                <div class="card-box p-3 h-100 d-flex flex-column align-items-center justify-content-center">
                    <h6 class="fw-bold mb-3">접종 달성률</h6>
                    <div style="width: 200px; height: 200px; position: relative;">
                        <canvas id="vaccineChart"></canvas>
                        <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center;">
                            <span class="fs-4 fw-bold text-primary">
                                <fmt:formatNumber value="${doneCount / totalCount * 100}" maxFractionDigits="0"/>%
                            </span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card-box p-3 h-100 d-flex flex-column justify-content-center">
                    <h6 class="fw-bold mb-3">접종 현황 요약</h6>
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            전체 일정 <span class="badge bg-secondary rounded-pill">${totalCount}건</span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            접종 완료 <span class="badge bg-success rounded-pill">${doneCount}건</span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            미접종 / 예정 <span class="badge bg-danger rounded-pill">${totalCount - doneCount}건</span>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </c:if>

    <div class="card-box p-3">
        <h6 class="fw-bold mb-3">접종 상세 내역</h6>
        <table class="table table-hover text-center align-middle">
            <thead class="table-light">
            <tr>
                <th>백신명</th>
                <th>차수</th>
                <th>예정일 / 상태</th>
                <th>판정</th>
                <th>관리</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty list}">
                    <tr><td colspan="5" class="text-muted py-4">접종 내역이 없습니다.</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="v" items="${list}">
                        <tr class="record-row"
                            onclick="openEditModal(this)"
                            data-no="${v.vaccineNo}"
                            data-name="${v.vaccineName}"
                            data-chasu="${v.chasu}"
                            data-date="${v.inoculationDate}"
                            data-status="${v.status}">

                            <td class="fw-bold text-start ps-5">${v.vaccineName}</td>
                            <td>${v.chasu}차</td>
                            <td>
                                    ${v.inoculationDate}
                                <c:if test="${v.status ne 'Y' and not empty v.dayDiff}">
                                    <span class="badge-status badge-dday ms-1">D-${v.dayDiff}</span>
                                </c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${v.status eq 'Y'}"><span class="badge-status badge-done">접종완료</span></c:when>
                                    <c:otherwise><span class="badge-status badge-yet">미접종</span></c:otherwise>
                                </c:choose>
                            </td>

                            <td onclick="event.stopPropagation();">
                                <c:choose>
                                    <c:when test="${v.status ne 'Y'}">
                                        <a href="/vaccine/complete?vaccineNo=${v.vaccineNo}&childId=${childId}&childName=${childName}"
                                           class="btn btn-sm btn-outline-success me-1 fw-bold">접종</a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="/vaccine/complete?vaccineNo=${v.vaccineNo}&childId=${childId}&childName=${childName}"
                                           class="btn btn-sm btn-outline-warning me-1 fw-bold">미접종</a>
                                    </c:otherwise>
                                </c:choose>

                                <a href="/vaccine/delete?vaccineNo=${v.vaccineNo}&childId=${childId}&childName=${childName}"
                                   class="btn btn-sm btn-outline-danger"
                                   onclick="return confirm('정말 삭제하시겠습니까?')">삭제</a>
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
        <form action="/vaccine/add" method="post" class="w-100">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold">접종 일정 추가</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="childId" value="${childId}">
                    <input type="hidden" name="childName" value="${childName}">
                    <div class="mb-3"><label class="form-label">백신명</label><input type="text" name="vaccineName" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label">차수</label><input type="number" name="chasu" value="1" class="form-control"></div>
                    <div class="mb-3"><label class="form-label">예정일</label><input type="text" name="inoculationDate" class="form-control datepicker" required style="background:white;"></div>
                </div>
                <div class="modal-footer"><button type="submit" class="btn btn-primary w-100 fw-bold">저장하기</button></div>
            </div>
        </form>
    </div>
</div>

<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <form action="/vaccine/update" method="post" class="w-100">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold">접종 정보 수정</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="vaccineNo" id="edit_vaccineNo">
                    <input type="hidden" name="childId" value="${childId}">
                    <input type="hidden" name="childName" value="${childName}">

                    <div class="mb-3"><label class="form-label">백신명</label><input type="text" name="vaccineName" id="edit_vaccineName" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label">차수</label><input type="number" name="chasu" id="edit_chasu" class="form-control"></div>
                    <div class="mb-3"><label class="form-label">예정일</label><input type="text" name="inoculationDate" id="edit_date" class="form-control datepicker" required style="background:white;"></div>
                </div>
                <div class="modal-footer"><button type="submit" class="btn btn-primary w-100 fw-bold">수정 완료</button></div>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://npmcdn.com/flatpickr/dist/l10n/ko.js"></script>

<script src="/js/vaccineList.js"></script>

<script>
    // 데이터가 있을 때만 차트 그리기 함수 호출
    <c:if test="${totalCount > 0}">
    // JS 파일에 정의된 함수 호출 (접종완료 수, 미접종 수 전달)
    renderVaccineChart(${doneCount}, ${totalCount - doneCount});
    </c:if>
</script>

</body>
</html>