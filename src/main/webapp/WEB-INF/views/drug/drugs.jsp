<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>의약품 검색</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="stylesheet" href="<c:url value='/css/drugs.css'/>">

</head>
<body>
<div class="logo" onclick="location.href='/'">
    <i class="fa-solid fa-laptop-medical logo-icon"></i>
    <span class="logo-text">CareFinder</span>
</div>

<div class="container">
    <h1> 의약품 정보 검색</h1>

    <div class="search-container">
        <!-- 이름 검색 -->
        <div class="search-box">
            <input type="text" id="searchInput" placeholder="의약품 이름을 입력하세요 (예: 타이레놀)" onkeypress="if(event.key==='Enter') searchDrug()">
            <button onclick="searchDrug()">검색</button>
        </div>

        <!-- 모양 검색 토글 버튼 -->
        <button class="shape-toggle-btn" onclick="toggleShapeSearch()">
            <span id="toggleIcon">▼</span> 💊 약 모양으로 찾기
        </button>

        <!-- 모양 검색 폼 (접혀있음) -->
        <div id="shapeSearchForm" class="shape-search-form">
            <div class="shape-form-title">약의 특징을 선택하세요</div>

            <div class="shape-form-grid">
                <!-- 모양 선택 -->
                <div class="form-group">
                    <label>모양</label>
                    <select id="shapeSelect">
                        <option value="">전체</option>
                        <option value="원형">원형</option>
                        <option value="타원형">타원형</option>
                        <option value="장방형">장방형</option>
                        <option value="반원형">반원형</option>
                        <option value="삼각형">삼각형</option>
                        <option value="사각형">사각형</option>
                        <option value="마름모형">마름모형</option>
                        <option value="오각형">오각형</option>
                        <option value="육각형">육각형</option>
                        <option value="팔각형">팔각형</option>
                        <option value="기타">기타</option>
                    </select>
                </div>

                <!-- 색상 선택 -->
                <div class="form-group">
                    <label>색상</label>
                    <select id="colorSelect">
                        <option value="">전체</option>
                        <option value="하양">하양</option>
                        <option value="노랑">노랑</option>
                        <option value="주황">주황</option>
                        <option value="분홍">분홍</option>
                        <option value="빨강">빨강</option>
                        <option value="갈색">갈색</option>
                        <option value="연두">연두</option>
                        <option value="초록">초록</option>
                        <option value="청록">청록</option>
                        <option value="파랑">파랑</option>
                        <option value="남색">남색</option>
                        <option value="자주">자주</option>
                        <option value="보라">보라</option>
                        <option value="회색">회색</option>
                        <option value="검정">검정</option>
                        <option value="투명">투명</option>
                    </select>
                </div>

                <!-- 각인 입력 -->
                <div class="form-group full-width">
                    <label>각인 (약에 적힌 글자)</label>
                    <input type="text" id="printInput" placeholder="예: kd, LA, 500">
                </div>
            </div>

            <button class="shape-search-btn" onclick="searchByShape()">🔍 모양으로 검색</button>
        </div>
    </div>

    <div id="result"></div>

    <!-- 📰 뉴스 섹션 -->
    <div class="news-section">
        <h2>📰 최근 의약품 관련 기사</h2>
        <div id="newsList">
            <p>기사를 불러오는 중...</p>
        </div>
    </div>
</div>

<script>
    // 로딩 HTML 생성 함수 (픽셀 프로그레스 바)
    function getLoadingHtml() {
        return '<div class="loading">' +
            '<img src="/img/loading_pixel.gif" alt="로딩중">' +
            '<div class="loading-text">약 정보를 찾고 있어요...</div>' +
            '<div class="pixel-progress-container">' +
            '<div class="pixel-progress-bar" id="loadingProgress"></div>' +
            '</div>' +
            '<div class="loading-timer" id="loadingTimer">Loading...</div>' +
            '</div>';
    }

    // 프로그레스 바 애니메이션
    function startLoadingTimer() {
        const progressEl = document.getElementById('loadingProgress');
        const timerEl = document.getElementById('loadingTimer');
        let width = 0;

        const interval = setInterval(function() {
            if (progressEl && timerEl) {
                width += 1;
                if (width <= 100) {
                    progressEl.style.width = width + '%';
                    timerEl.textContent = 'Loading... ' + width + '%';
                } else {
                    timerEl.textContent = 'Loading... 100%';
                }
            } else {
                clearInterval(interval);
            }
        }, 470); // 47초 = 100 * 470ms

        return interval;
    }

    // 모양 검색 폼 토글
    function toggleShapeSearch() {
        var form = document.getElementById('shapeSearchForm');
        var icon = document.getElementById('toggleIcon');

        if (form.classList.contains('open')) {
            form.classList.remove('open');
            icon.textContent = '▼';
        } else {
            form.classList.add('open');
            icon.textContent = '▲';
        }
    }

    // 기존 이름 검색 기능
    function searchDrug() {
        var keyword = document.getElementById('searchInput').value.trim();

        if (!keyword) {
            alert('검색어를 입력해주세요.');
            return;
        }

        var resultDiv = document.getElementById('result');
        resultDiv.innerHTML = getLoadingHtml();

        // ✅ 타이머 시작
        var timerInterval = startLoadingTimer();

        fetch('/drug/search?name=' + encodeURIComponent(keyword))
            .then(function(response) {
                clearInterval(timerInterval); // ✅ 타이머 종료
                return response.json();
            })
            .then(function(data) {
                console.log('받은 데이터:', data);

                if (!data || data.length === 0) {
                    resultDiv.innerHTML = '<div class="empty-message">검색 결과가 없습니다.</div>';
                    return;
                }

                var html = '';

                for (var i = 0; i < data.length; i++) {
                    var drug = data[i];

                    html += '<div class="drug-card">';
                    html += '<div class="drug-name">' + (drug.itemName || '정보 없음') + '</div>';
                    html += '<div class="drug-company">제조사: ' + (drug.entpName || '정보 없음') + '</div>';

                    if (drug.itemImage) {
                        html += '<div class="drug-image">';
                        html += '<img src="' + drug.itemImage + '" alt="의약품 이미지">';
                        html += '</div>';
                    }

                    if (drug.efcyQesitm) {
                        html += '<div class="info-section">';
                        html += '<span class="info-label">📌 효능·효과</span>';
                        html += '<div class="info-content">' + drug.efcyQesitm + '</div>';
                        html += '</div>';
                    }

                    if (drug.useMethodQesitm) {
                        html += '<div class="info-section">';
                        html += '<span class="info-label">💊 복용 방법</span>';
                        html += '<div class="info-content">' + drug.useMethodQesitm + '</div>';
                        html += '</div>';
                    }

                    if (drug.atpnWarnQesitm) {
                        html += '<div class="info-section">';
                        html += '<span class="info-label">⚠️ 주의사항 경고</span>';
                        html += '<div class="info-content">' + drug.atpnWarnQesitm + '</div>';
                        html += '</div>';
                    }

                    if (drug.atpnQesitm) {
                        html += '<div class="info-section">';
                        html += '<span class="info-label">⚠️ 주의사항</span>';
                        html += '<div class="info-content">' + drug.atpnQesitm + '</div>';
                        html += '</div>';
                    }

                    if (drug.intrcQesitm) {
                        html += '<div class="info-section">';
                        html += '<span class="info-label">🔄 상호작용</span>';
                        html += '<div class="info-content">' + drug.intrcQesitm + '</div>';
                        html += '</div>';
                    }

                    if (drug.seQesitm) {
                        html += '<div class="info-section">';
                        html += '<span class="info-label">🩺 부작용</span>';
                        html += '<div class="info-content">' + drug.seQesitm + '</div>';
                        html += '</div>';
                    }

                    if (drug.depositMethodQesitm) {
                        html += '<div class="info-section">';
                        html += '<span class="info-label">📦 보관 방법</span>';
                        html += '<div class="info-content">' + drug.depositMethodQesitm + '</div>';
                        html += '</div>';
                    }

                    html += '</div>';
                }

                resultDiv.innerHTML = html;
            })
            .catch(function(error) {
                clearInterval(timerInterval); // ✅ 에러 시에도 타이머 종료
                console.error('에러:', error);
                resultDiv.innerHTML = '<div class="empty-message">오류가 발생했습니다. 다시 시도해주세요.</div>';
            });
    }

    // 모양으로 검색 기능 (프론트엔드 필터링)
    function searchByShape() {
        var shape = document.getElementById('shapeSelect').value;
        var color = document.getElementById('colorSelect').value;
        var print = document.getElementById('printInput').value.trim().toUpperCase();

        // 최소 하나는 입력해야 함
        if (!shape && !color && !print) {
            alert('최소 하나의 조건을 선택하거나 입력해주세요.');
            return;
        }

        var resultDiv = document.getElementById('result');
        resultDiv.innerHTML = getLoadingHtml();

        // ✅ 타이머 시작
        var timerInterval = startLoadingTimer();

        fetch('/drug/searchByShape')
            .then(function(response) {
                clearInterval(timerInterval); // ✅ 타이머 종료
                return response.json();
            })
            .then(function(data) {
                console.log('받은 데이터 개수:', data.length);

                if (!data || data.length === 0) {
                    resultDiv.innerHTML = '<div class="empty-message">데이터를 불러올 수 없습니다.</div>';
                    return;
                }

                // 프론트엔드에서 필터링
                var filtered = data.filter(function(drug) {
                    var matchShape = true;
                    var matchColor = true;
                    var matchPrint = true;

                    // 모양 필터
                    if (shape) {
                        matchShape = drug.drugShape && drug.drugShape === shape;
                    }

                    // 색상 필터
                    if (color) {
                        matchColor = (drug.colorClass1 && drug.colorClass1.includes(color)) ||
                            (drug.colorClass2 && drug.colorClass2.includes(color));
                    }

                    // 각인 필터
                    if (print) {
                        var frontMatch = drug.printFront && drug.printFront.toUpperCase().includes(print);
                        var backMatch = drug.printBack && drug.printBack.toUpperCase().includes(print);
                        matchPrint = frontMatch || backMatch;
                    }

                    return matchShape && matchColor && matchPrint;
                });

                console.log('필터링 후 개수:', filtered.length);

                if (filtered.length === 0) {
                    resultDiv.innerHTML = '<div class="empty-message">검색 결과가 없습니다.<br><small>다른 조건으로 다시 검색해보세요.</small></div>';
                    return;
                }

                // 최대 50개만 표시
                var displayData = filtered.slice(0, 50);
                var html = '';

                if (filtered.length > 50) {
                    html += '<div class="result-info">총 ' + filtered.length + '건 중 50건 표시</div>';
                } else {
                    html += '<div class="result-info">총 ' + filtered.length + '건</div>';
                }

                for (var i = 0; i < displayData.length; i++) {
                    var drug = displayData[i];

                    html += '<div class="drug-card">';
                    html += '<div class="drug-name">' + (drug.itemName || '정보 없음') + '</div>';
                    html += '<div class="drug-company">제조사: ' + (drug.entpName || '정보 없음') + '</div>';

                    if (drug.itemImage) {
                        html += '<div class="drug-image">';
                        html += '<img src="' + drug.itemImage + '" alt="의약품 이미지">';
                        html += '</div>';
                    }

                    // 모양 정보 표시
                    html += '<div class="shape-info">';

                    if (drug.drugShape) {
                        html += '<span class="shape-tag">모양: ' + drug.drugShape + '</span>';
                    }
                    if (drug.colorClass1) {
                        html += '<span class="shape-tag">색상: ' + drug.colorClass1;
                        if (drug.colorClass2) {
                            html += ' / ' + drug.colorClass2;
                        }
                        html += '</span>';
                    }
                    if (drug.printFront || drug.printBack) {
                        html += '<span class="shape-tag">각인: ';
                        if (drug.printFront) html += '(앞) ' + drug.printFront + ' ';
                        if (drug.printBack) html += '(뒤) ' + drug.printBack;
                        html += '</span>';
                    }
                    if (drug.formCodeName) {
                        html += '<span class="shape-tag">제형: ' + drug.formCodeName + '</span>';
                    }

                    html += '</div>';

                    // 크기 정보
                    if (drug.lengLong || drug.lengShort || drug.thick) {
                        html += '<div class="info-section">';
                        html += '<span class="info-label">📏 크기</span>';
                        html += '<div class="info-content">';
                        if (drug.lengLong) html += '장축: ' + drug.lengLong + 'mm ';
                        if (drug.lengShort) html += '단축: ' + drug.lengShort + 'mm ';
                        if (drug.thick) html += '두께: ' + drug.thick + 'mm';
                        html += '</div>';
                        html += '</div>';
                    }

                    // 분류 정보
                    if (drug.className) {
                        html += '<div class="info-section">';
                        html += '<span class="info-label">📋 분류</span>';
                        html += '<div class="info-content">' + drug.className + '</div>';
                        html += '</div>';
                    }

                    // 전문/일반 구분
                    if (drug.etcOtcName) {
                        html += '<div class="info-section">';
                        html += '<span class="info-label">💊 구분</span>';
                        html += '<div class="info-content">' + drug.etcOtcName + '</div>';
                        html += '</div>';
                    }

                    html += '</div>';
                }

                resultDiv.innerHTML = html;
            })
            .catch(function(error) {
                clearInterval(timerInterval); // ✅ 에러 시에도 타이머 종료
                console.error('에러:', error);
                resultDiv.innerHTML = '<div class="empty-message">오류가 발생했습니다. 다시 시도해주세요.</div>';
            });
    }

    // 뉴스 불러오기 기능
    window.addEventListener('DOMContentLoaded', function() {
        loadDrugNews();
    });

    function loadDrugNews() {
        fetch('/api/news')
            .then(function(response) {
                return response.json();
            })
            .then(function(data) {
                var newsList = document.getElementById('newsList');

                if (data.items && data.items.length > 0) {
                    var newsHtml = '';

                    for (var i = 0; i < data.items.length; i++) {
                        var item = data.items[i];
                        newsHtml += '<a href="' + item.link + '" target="_blank" class="news-item">';
                        newsHtml += '<h3>' + removeHtmlTags(item.title) + '</h3>';
                        newsHtml += '<p class="news-description">' + removeHtmlTags(item.description) + '</p>';
                        newsHtml += '<div class="news-meta">';
                        newsHtml += '<span class="news-date">' + formatDate(item.pubDate) + '</span>';
                        newsHtml += '<span class="news-link-text">기사 원문 보기 →</span>';
                        newsHtml += '</div>';
                        newsHtml += '</a>';
                    }

                    newsList.innerHTML = newsHtml;
                } else {
                    newsList.innerHTML = '<p>최근 기사가 없습니다.</p>';
                }
            })
            .catch(function(error) {
                console.error('뉴스 로딩 실패:', error);
                document.getElementById('newsList').innerHTML =
                    '<p>기사를 불러오는데 실패했습니다. 잠시 후 다시 시도해주세요.</p>';
            });
    }

    function removeHtmlTags(str) {
        if (!str) return '';
        return str.replace(/<\/?[^>]+(>|$)/g, "");
    }

    function formatDate(dateStr) {
        var date = new Date(dateStr);
        var year = date.getFullYear();
        var month = String(date.getMonth() + 1).padStart(2, '0');
        var day = String(date.getDate()).padStart(2, '0');
        return year + '.' + month + '.' + day;
    }
</script>
</body>
</html>