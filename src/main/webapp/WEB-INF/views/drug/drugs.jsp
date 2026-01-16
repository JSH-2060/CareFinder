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
            <span id="toggleIcon">▼</span> 약 모양으로 찾기
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

            <button class="shape-search-btn" onclick="searchByShape()"> 모양으로 검색</button>
        </div>
    </div>

    <div id="result"></div>

    <!-- 📰 뉴스 섹션 -->
    <div class="news-section">
        <h2> 건강 뉴스</h2>
        <div id="newsList">
            <p>기사를 불러오는 중...</p>
        </div>
    </div>
</div>

<script>
    // 로딩 HTML 생성 함수
    function getLoadingHtml() {
        return '<div class="loading">' +
            '<img src="/img/loading_circle.gif" alt="로딩중">' +
            '<p class="loading-text">Loading . . .</p>' +
            '</div>';
    }

    // 모양 검색 폼 토글
    function toggleShapeSearch() {
        var form = document.getElementById('shapeSearchForm');
        var icon = document.getElementById('toggleIcon');
        var button = document.querySelector('.shape-toggle-btn'); // 이 줄 추가

        if (form.classList.contains('open')) {
            form.classList.remove('open');
            button.classList.remove('active'); // 이 줄 추가
            icon.textContent = '▼';
        } else {
            form.classList.add('open');
            button.classList.add('active'); // 이 줄 추가
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

        fetch('/drug/search?name=' + encodeURIComponent(keyword))
            .then(function(response) {
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
                console.error('에러:', error);
                resultDiv.innerHTML = '<div class="empty-message">오류가 발생했습니다. 다시 시도해주세요.</div>';
            });
    }

    // 모양으로 검색 기능
    function searchByShape() {
        var shape = document.getElementById('shapeSelect').value;
        var color = document.getElementById('colorSelect').value;
        var print = document.getElementById('printInput').value.trim();

        if (!shape && !color && !print) {
            alert('최소 하나의 조건을 선택하거나 입력해주세요.');
            return;
        }

        var resultDiv = document.getElementById('result');
        resultDiv.innerHTML = getLoadingHtml();

        var params = new URLSearchParams();
        if (shape) params.append('shape', shape);
        if (color) params.append('color', color);
        if (print) params.append('print', print);

        fetch('/drug/searchByShape?' + params.toString())
            .then(function(response) {
                return response.json();
            })
            .then(function(data) {
                console.log('받은 데이터 개수:', data.length);

                if (!data || data.length === 0) {
                    resultDiv.innerHTML = '<div class="empty-message">검색 결과가 없습니다.<br><small>다른 조건으로 다시 검색해보세요.</small></div>';
                    return;
                }

                var html = '<div class="result-info">검색 결과: ' + data.length + '건</div>';

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

                    if (drug.className) {
                        html += '<div class="info-section">';
                        html += '<span class="info-label">📋 분류</span>';
                        html += '<div class="info-content">' + drug.className + '</div>';
                        html += '</div>';
                    }

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
                        newsHtml += '<span class="news-link-text">기사 보러 가기 →</span>';
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