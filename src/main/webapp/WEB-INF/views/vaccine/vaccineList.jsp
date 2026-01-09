<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>${childName} 백신 관리</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f0f2f5; font-family: 'Pretendard', sans-serif; color: #333; }
        .main-container { max-width: 700px; margin: 0 auto; padding: 20px 10px; }
        .card-box { background: white; border-radius: 20px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); border: none; margin-bottom: 20px; overflow: hidden; }
        .profile-header { background: white; padding: 20px; border-radius: 20px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); display: flex; align-items: center; justify-content: space-between; margin-bottom: 25px; }
        .profile-img { width: 50px; height: 50px; background: linear-gradient(135deg, #4facfe, #00f2fe); border-radius: 50%; color: white; display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: bold; }
        .status-badge { display: inline-block; padding: 8px 12px; border-radius: 12px; font-weight: 700; font-size: 0.9rem; min-width: 80px; text-align: center; }
        .status-done { background-color: #d1fae5; color: #059669; border: 1px solid #10b981; }
        .status-yet { background-color: #f3f4f6; color: #6b7280; border: 1px solid #d1d5db; }
        .d-day-text { font-size: 0.85rem; font-weight: bold; margin-top: 4px; display: block; }
        .text-danger-custom { color: #e11d48; }
        .text-blue-custom { color: #2563eb; }
        .table-custom th { background: #f9fafb; font-size: 0.9rem; color: #4b5563; font-weight: 700; border: none; padding: 15px; }
        .table-custom td { font-size: 1rem; vertical-align: middle; border-bottom: 1px solid #f3f4f6; padding: 15px; }
        .table-custom tr:hover { background-color: #f8fafc; }
        .btn-action { padding: 6px 16px; border-radius: 8px; font-weight: 600; font-size: 0.9rem; transition: 0.2s; }
        .btn-complete { background-color: #3b82f6; color: white; border: none; }
        .btn-complete:hover { background-color: #2563eb; transform: translateY(-2px); }
        .btn-cancel { background-color: white; color: #ef4444; border: 1px solid #ef4444; }
        .btn-cancel:hover { background-color: #fef2f2; }
    </style>
</head>
<body>

<div class="main-container">
    <div class="profile-header">
        <div class="d-flex align-items-center gap-3">
            <div class="profile-img">
                <c:choose>
                    <c:when test="${not empty childName}">${childName.substring(0,1)}</c:when>
                    <c:otherwise>?</c:otherwise>
                </c:choose>
            </div>
            <div>
                <h5 style="margin:0; font-weight: 800; font-size: 1.2rem;">${childName}</h5>
                <span style="font-size: 0.85rem; color: #888;">백신 접종 기록</span>
            </div>
        </div>
        <div>
            <button class="btn btn-sm btn-outline-secondary rounded-pill px-3" onclick="location.href='/heat/select'">뒤로</button>
            <button class="btn btn-sm btn-primary rounded-pill px-3 ms-1" data-bs-toggle="modal" data-bs-target="#addModal">+ 일정 추가</button>
        </div>
    </div>

    <div class="card-box">
        <div class="table-responsive">
            <table class="table table-custom m-0 text-center">
                <thead>
                <tr>
                    <th width="40%" class="text-start ps-4">백신명 / 날짜</th>
                    <th width="25%">상태</th>
                    <th width="35%">관리</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="v" items="${list}">
                    <tr>
                        <td class="text-start ps-4">
                            <div class="fw-bold text-dark" style="font-size: 1.05rem;">
                                    ${v.vaccineName} <span class="badge bg-light text-dark border">${v.chasu}차</span>
                            </div>
                            <div class="mt-1">
                                <span class="text-muted" style="font-size: 0.9rem;">${v.inoculationDate}</span>

                                <c:if test="${v.status ne 'Y'}">
                                    <c:choose>
                                        <c:when test="${v.dayDiff eq 0}">
                                            <span class="d-day-text text-danger-custom">🔥 오늘 접종일!</span>
                                        </c:when>
                                        <c:when test="${v.dayDiff gt 0}">
                                            <span class="d-day-text text-blue-custom">D-${v.dayDiff}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="d-day-text text-danger-custom">⚠️ ${-v.dayDiff}일 지남</span>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                            </div>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${v.status eq 'Y'}">
                                    <span class="status-badge status-done">접종완료</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-badge status-yet">미접종</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <div class="d-flex justify-content-center gap-2">
                                <c:choose>
                                    <c:when test="${v.status eq 'Y'}">
                                        <a href="/vaccine/cancel?vaccineNo=${v.vaccineNo}&childName=${childName}&childId=${childId}"
                                           class="btn-action btn-cancel text-decoration-none"
                                           onclick="return confirm('미접종 상태로 되돌리시겠습니까?')">취소</a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="/vaccine/complete?vaccineNo=${v.vaccineNo}&childName=${childName}&childId=${childId}"
                                           class="btn-action btn-complete text-decoration-none">접종하기</a>
                                    </c:otherwise>
                                </c:choose>

                                <div class="dropdown">
                                    <button class="btn btn-light btn-sm rounded-circle" type="button" data-bs-toggle="dropdown">⋮</button>
                                    <ul class="dropdown-menu">
                                        <li><a class="dropdown-item" href="#" onclick="openEditModal('${v.vaccineNo}', '${v.vaccineName}', '${v.chasu}', '${v.inoculationDate}')">수정</a></li>
                                        <li><a class="dropdown-item text-danger" href="/vaccine/delete?vaccineNo=${v.vaccineNo}&childName=${childName}&childId=${childId}" onclick="return confirm('삭제하시겠습니까?')">삭제</a></li>
                                    </ul>
                                </div>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty list}">
                    <tr><td colspan="3" class="py-5 text-muted">등록된 접종 일정이 없습니다.</td></tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <form action="/vaccine/update" method="post" class="w-100">
            <div class="modal-content" style="border-radius: 20px;">
                <div class="modal-header border-0"><h5 class="modal-title fw-bold">일정 수정</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                <div class="modal-body">
                    <input type="hidden" name="childId" value="${childId}">

                    <input type="hidden" name="childName" value="${childName}">

                    <input type="hidden" name="vaccineNo" id="editVaccineNo">
                    <div class="mb-3"><label class="form-label text-muted">백신 이름</label><input type="text" name="vaccineName" id="editVaccineName" class="form-control rounded-3"></div>
                    <div class="mb-3"><label class="form-label text-muted">차수</label><input type="number" name="chasu" id="editChasu" class="form-control rounded-3"></div>
                    <div class="mb-3"><label class="form-label text-muted">예정일</label><input type="date" name="inoculationDate" id="editInoculationDate" class="form-control rounded-3"></div>
                </div>
                <div class="modal-footer border-0"><button type="submit" class="btn btn-primary w-100 rounded-3">수정하기</button></div>
            </div>
        </form>
    </div>
</div>

<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <form action="/vaccine/update" method="post" class="w-100">
            <div class="modal-content" style="border-radius: 20px;">
                <div class="modal-header border-0"><h5 class="modal-title fw-bold">일정 수정</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                <div class="modal-body">
                    <input type="hidden" name="childId" value="${childId}">
                    <input type="hidden" name="vaccineNo" id="editVaccineNo">
                    <div class="mb-3"><label class="form-label text-muted">백신 이름</label><input type="text" name="vaccineName" id="editVaccineName" class="form-control rounded-3"></div>
                    <div class="mb-3"><label class="form-label text-muted">차수</label><input type="number" name="chasu" id="editChasu" class="form-control rounded-3"></div>
                    <div class="mb-3"><label class="form-label text-muted">예정일</label><input type="date" name="inoculationDate" id="editInoculationDate" class="form-control rounded-3"></div>
                </div>
                <div class="modal-footer border-0"><button type="submit" class="btn btn-primary w-100 rounded-3">수정하기</button></div>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function openEditModal(no, name, degree, date) {
        document.getElementById('editVaccineNo').value = no;
        document.getElementById('editVaccineName').value = name;
        document.getElementById('editChasu').value = degree;
        document.getElementById('editInoculationDate').value = date;
        new bootstrap.Modal(document.getElementById('editModal')).show();
    }
</script>
</body>
</html>