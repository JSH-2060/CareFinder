<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>대상 선택</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        /* [글래스 모피즘 정석 배경] 은은한 파스텔 오로라 */
        body {
            background-color: #f0f4f8;
            background-image:
                    radial-gradient(at 0% 0%, hsla(253,16%,7%,0) 0, transparent 50%),
                    radial-gradient(at 50% 0%, hsla(225,39%,30%,0) 0, transparent 50%),
                    radial-gradient(at 100% 0%, hsla(339,49%,30%,0) 0, transparent 50%);
            background: linear-gradient(120deg, #e0c3fc 0%, #8ec5fc 100%); /* 밝고 깨끗한 블루+연보라 톤 */
            min-height: 100vh;
            font-family: 'Pretendard', sans-serif;
            padding-top: 50px;
        }

        .page-title { font-weight: 800; color: white; text-shadow: 0 2px 5px rgba(0,0,0,0.1); margin-bottom: 30px; }

        /* [유리 카드] */
        .glass-card {
            background: rgba(255, 255, 255, 0.6); /* 더 투명하고 밝게 */
            backdrop-filter: blur(12px);          /* 블러 효과 */
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.8);
            border-radius: 20px;
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.1);
            transition: 0.3s;
            overflow: hidden; /* 버튼이 튀어나가지 않게 */
        }
        .glass-card:hover {
            transform: translateY(-5px);
            background: rgba(255, 255, 255, 0.8);
            box-shadow: 0 12px 40px 0 rgba(31, 38, 135, 0.15);
        }

        /* 탭 버튼 스타일 */
        .nav-pills .nav-link {
            background: rgba(255, 255, 255, 0.3);
            color: #555;
            margin: 0 5px;
            border-radius: 20px;
            font-weight: 600;
        }
        .nav-pills .nav-link.active {
            background: white;
            color: #0d6efd;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }

        .instruction { color: rgba(255,255,255,0.9); font-weight: 500; margin-bottom: 30px; }

        /* 카드 내부 레이아웃 */
        .card-body-click { padding: 30px 20px; cursor: pointer; text-align: center; }
        .card-footer-btn {
            border-top: 1px solid rgba(0,0,0,0.05);
            padding: 0;
            background: rgba(255,255,255,0.3);
        }
        .btn-edit {
            width: 100%;
            padding: 10px;
            border: none;
            background: transparent;
            color: #666;
            font-size: 0.9rem;
            font-weight: 600;
            transition: 0.2s;
        }
        .btn-edit:hover { background: rgba(0,0,0,0.05); color: #333; }

        .add-card {
            border: 2px dashed rgba(255,255,255,0.6);
            background: rgba(255,255,255,0.2);
            display: flex; align-items: center; justify-content: center;
            min-height: 180px;
            cursor: pointer;
            color: white;
            font-weight: bold;
        }
        .add-card:hover { background: rgba(255,255,255,0.4); color: white; border-color: white; }
    </style>
    <script>
        let currentMode = 'heat';

        function setMode(mode) {
            currentMode = mode;
            document.querySelectorAll('.nav-link').forEach(el => el.classList.remove('active'));
            document.getElementById('tab-' + mode).classList.add('active');

            let title = '';
            if(mode === 'heat') title = '체온을 기록할 대상을 선택하세요';
            else if(mode === 'vaccine') title = '백신 기록을 확인할 대상을 선택하세요';
            else if(mode === 'bmi') title = 'BMI를 측정할 대상을 선택하세요';
            document.getElementById('instruction-text').innerText = title;
        }

        function goManage(childId, childName) {
            let url = '';
            const params = '?childId=' + childId + '&childName=' + encodeURIComponent(childName);

            if (currentMode === 'heat') url = '/heat/list' + params;
            else if (currentMode === 'vaccine') url = '/vaccine/list' + params;
            else if (currentMode === 'bmi') url = '/bmi/list' + params;

            location.href = url;
        }
    </script>
</head>
<body>

<div class="container">
    <div class="text-center">
        <h2 class="page-title">Family Health Care</h2>

        <ul class="nav nav-pills justify-content-center mb-4">
            <li class="nav-item"><a class="nav-link active" id="tab-heat" onclick="setMode('heat')">체온 관리</a></li>
            <li class="nav-item"><a class="nav-link" id="tab-vaccine" onclick="setMode('vaccine')">백신 관리</a></li>
            <li class="nav-item"><a class="nav-link" id="tab-bmi" onclick="setMode('bmi')">BMI 관리</a></li>
        </ul>

        <h5 id="instruction-text" class="instruction">체온을 기록할 대상을 선택하세요</h5>
    </div>

    <div class="row justify-content-center g-4">
        <c:forEach var="child" items="${childList}">
            <div class="col-12 col-md-4 col-lg-3">
                <div class="glass-card">
                    <div class="card-body-click" onclick="goManage('${child.childId}', '${child.childName}')">
                        <h3 class="fw-bold m-0" style="color: #333;">${child.childName}</h3>
                        <div class="mt-2 text-muted small">${child.gender == 'M' ? '남성' : '여성'}</div>
                    </div>

                    <div class="card-footer-btn">
                        <button class="btn-edit" onclick="location.href='/child/edit?childId=${child.childId}'">
                            정보 수정
                        </button>
                    </div>
                </div>
            </div>
        </c:forEach>

        <div class="col-12 col-md-4 col-lg-3">
            <div class="glass-card add-card" onclick="location.href='/child/add'">
                <span style="font-size: 1.2rem;">+ 대상 추가</span>
            </div>
        </div>
    </div>

    <div class="text-center mt-5">
        <a href="/" class="btn btn-light rounded-pill px-4" style="opacity: 0.8; font-weight:bold; color: #555;">메인으로</a>
    </div>
</div>

</body>
</html>