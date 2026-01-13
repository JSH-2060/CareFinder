<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>키 성장 기록</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        body { background:#f0f2f5; font-family:'Pretendard',sans-serif; }

        .card-box{
            background:#fff;
            border-radius:16px;
            box-shadow:0 4px 20px rgba(0,0,0,.05);
            margin-bottom:20px;
        }

        /* ===== 키성장 메인 컬러 ===== */
        :root{
            --height-main:#14b8a6;
            --height-light:#e6fffa;
            --height-dark:#0d9488;
        }

        /* 아바타 */
        .avatar-circle{
            width:44px;height:44px;border-radius:50%;
            background:var(--height-main);
            color:#fff;font-weight:700;
            display:flex;align-items:center;justify-content:center;
            font-size:18px;
        }

        /* 탭 */
        .nav-pills .nav-link{ color:#555;font-weight:600; }
        .nav-pills .nav-link.active{
            background:var(--height-main);
            color:#fff;
        }

        /* 프로필 버튼 */
        .profile-sm-btn{
            font-size:.85rem;
            padding:5px 12px;
            border-radius:20px;
            border:1px solid #ddd;
            background:#fff;
            color:#555;
            text-decoration:none;
        }
        .profile-sm-btn.active{
            background:var(--height-light);
            border-color:var(--height-main);
            color:var(--height-dark);
            font-weight:700;
        }

        tr.data-row{ cursor:pointer; }
        tr.data-row:hover{ background:#f0fdfa; }
    </style>


    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</head>
<c:if test="${not empty msg}">
    <div class="alert alert-warning text-center mb-3">
            ${msg}
    </div>
</c:if>
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
                    <a class="nav-link active" href="#">키성장</a>
                </li>
            </ul>

            <div class="d-flex gap-1">
                <a href="/height/list?childId=0&childName=${sessionScope.userName}"
                   class="profile-sm-btn ${childId==0?'active':''}">
                    나
                </a>

                <c:forEach var="c" items="${childList}">
                    <a href="/height/list?childId=${c.childId}&childName=${c.childName}"
                       class="profile-sm-btn ${childId==c.childId?'active':''}">
                            ${c.childName}
                    </a>
                </c:forEach>

                <a href="/child/add" class="profile-sm-btn">+</a>
            </div>
        </div>
    </div>

    <!-- ===== 기록 버튼 (체온 페이지와 동일 위치) ===== -->
    <div class="d-flex justify-content-end gap-2 my-3">
        <button class="btn btn-outline-secondary btn-sm"
                onclick="toggleDateSearch()">
            날짜 검색
        </button>
        <button class="btn fw-bold text-white"
                style="background:var(--height-main);"
                data-bs-toggle="modal"
                data-bs-target="#heightModal">
            키 기록 추가
        </button>
    </div>

    <div id="dateSearchBox" style="display:none;">
        <div class="card-box p-3 mb-3">
            <form action="/height/list" method="get"
                  class="row g-2 align-items-end">

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
                    <a href="/height/list?childId=${childId}&childName=${childName}"
                       class="btn btn-outline-secondary">
                        전체
                    </a>
                </div>
            </form>
        </div>
    </div>

    <!-- ===== 그래프 ===== -->
    <div class="card-box p-3">
        <h6 class="fw-bold mb-3">키 성장 변화</h6>
        <canvas id="heightChart" height="100"></canvas>
    </div>

    <!-- ===== 테이블 ===== -->
    <div class="card-box p-3">
        <h6 class="fw-bold mb-3">상세 기록</h6>

        <table class="table table-hover text-center align-middle">
            <thead class="table-light">
            <tr>
                <th>날짜</th>
                <th>키 (cm)</th>
                <th>관리</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="h" items="${list}">
                <tr class="data-row"
                    onclick="openHeightEditModal(
                            '${h.heightId}',
                            '${h.height}',
                            '${h.recordDate}'
                            )">
                    <td>${h.recordDate}</td>
                    <td class="fw-bold">${h.height}</td>
                    <td>
                        <form action="/height/delete" method="post"
                              onclick="event.stopPropagation();"
                              onsubmit="return confirm('삭제할까요?');">
                            <input type="hidden" name="heightId" value="${h.heightId}">
                            <input type="hidden" name="childId" value="${childId}">
                            <input type="hidden" name="childName" value="${childName}">
                            <button class="btn btn-sm btn-outline-danger">삭제</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>

            <c:if test="${empty list}">
                <tr><td colspan="3" class="py-4 text-muted">기록이 없습니다.</td></tr>
            </c:if>
            </tbody>
        </table>
    </div>
</div>

<!-- ===== 그래프 스크립트 ===== -->
<c:if test="${not empty list}">
    <script>
        const labels = [];
        const data = [];
        <c:forEach var="h" items="${list}">
        labels.unshift("${h.recordDate}");
        data.unshift(${h.height});
        </c:forEach>

        new Chart(document.getElementById('heightChart'), {
            type:'line',
            data:{
                labels:labels,
                datasets:[{
                    data:data,
                    borderColor:'#14b8a6',
                    tension:0,
                    fill:false
                }]
            },
            options:{
                plugins:{ legend:{ display:false } },
                scales:{ y:{ ticks:{ callback:v=>v+' cm' } } }
            }
        });
    </script>
</c:if>

<input type="hidden"
       id="latestHeightValue"
       value="${latestHeight != null ? latestHeight.height : ''}">


<!-- ===== 키 입력 모달 ===== -->
<div class="modal fade" id="heightModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <form action="/height/insert" method="post" class="w-100">
            <div class="modal-content">
                <div class="modal-header fw-bold">
                    키 입력
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <input type="hidden" name="childId" value="${childId}">
                    <input type="hidden" name="childName" value="${childName}">

                    <div class="mb-3">
                        <label class="form-label">측정 날짜</label>
                        <input type="date"
                               name="recordDate"
                               class="form-control"
                               value="<%= java.time.LocalDate.now() %>"
                               readonly>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">키 (cm)</label>
                        <input type="number"
                               step="0.1"
                               min="80"
                               max="250"
                               name="height"
                               id="heightInput"
                               class="form-control"
                               placeholder="80 ~ 250 cm"
                               required>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="submit"
                            class="btn w-100 text-white fw-bold"
                            style="background:var(--height-main);">
                        저장
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- ===== 키 수정 모달 ===== -->
<div class="modal fade" id="heightEditModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <form action="/height/update" method="post" class="w-100">
            <div class="modal-content">

                <div class="modal-header">
                    <h5 class="modal-title fw-bold">키 수정</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <!-- PK -->
                    <input type="hidden" name="heightId" id="editHeightId">

                    <!-- 키 -->
                    <div class="mb-3">
                        <label class="form-label">키 (cm)</label>
                        <input type="number"
                               step="0.1"
                               min="80"
                               max="250"
                               name="height"
                               id="editHeight"
                               class="form-control"
                               placeholder="80 ~ 250 cm"
                               required>
                    </div>

                    <!-- 날짜 (고정) -->
                    <div class="mb-3">
                        <label class="form-label">측정 날짜</label>
                        <input type="date"
                               name="recordDate"
                               id="editRecordDate"
                               class="form-control"
                               readonly>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="submit"
                            class="btn w-100 text-white fw-bold"
                            style="background:var(--height-main);">
                        수정 저장
                    </button>
                </div>

            </div>
        </form>
    </div>
</div>

<script>
    function openHeightEditModal(id, height, date) {
        document.getElementById('editHeightId').value = id;
        document.getElementById('editHeight').value = height;
        document.getElementById('editRecordDate').value = date;

        const modal = new bootstrap.Modal(
            document.getElementById('heightEditModal')
        );
        modal.show();
    }
</script>

<script>
    const heightModal = document.getElementById('heightModal');

    heightModal.addEventListener('show.bs.modal', function () {
        const last = document.getElementById('latestHeightValue').value;
        const input = document.getElementById('heightInput');

        if (last && !input.value) {
            input.value = last;
        }
    });
</script>

<script>
    function toggleDateSearch() {
        const box = document.getElementById('dateSearchBox');
        box.style.display = (box.style.display === 'none') ? 'block' : 'none';
    }
</script>

</body>
</html>
