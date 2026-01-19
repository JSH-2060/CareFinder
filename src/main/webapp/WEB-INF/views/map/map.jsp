<%@ page contentType="text/html; charset=UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="ko">
<head>
    <meta charset="utf-8"/>
    <title>내 주변 병원</title>

    <link rel="stylesheet" href="<c:url value='/css/map.css'/>">
    <link rel="stylesheet" href="<c:url value='/css/style.css'/>">
    <link rel="stylesheet" href="<c:url value='/css/chatbotMap.css'/>">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <%--  카카오 맵 api --%>
    <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoMapsKey}&libraries=services"></script>

    <%-- 구글 맵 api --%>
    <script src="https://maps.googleapis.com/maps/api/js?key=${googleMapsKey}&libraries=places,geometry"></script>

    <script>
        // 전역 변수 설정
        const KAKAO_REST_API_KEY = "${kakaoRestKey}";
        const TMAP_APP_KEY = "${tmapAppKey}";
        window.KAKAO_REST_API_KEY = "${kakaoRestKey}";
        window.TMAP_APP_KEY = "${tmapAppKey}";
    </script>

    <script src="<c:url value='/js/route.js'/>"></script>
    <script src="<c:url value='/js/marker.js'/>"></script>

</head>

<body>
<div class="header">
    <div class="logo" onclick="location.href='/'">
        <i class="fa-solid fa-laptop-medical logo-icon"></i>
        <span class="logo-text">CareFinder</span>
    </div>
</div>

<div id="mapWrap">
    <div id="listPanel">
        <div class="list-header">
            내 주변 <span id="listTitle"></span> 목록
        </div>
        <ul id="placeList"></ul>
    </div>

    <!-- 리스트 접기/펼치기 버튼 -->
    <button id="listToggleBtn" class="list-toggle-btn">❮</button>

    <div id="map">
        <button class="home-btn" onclick="location.href='/'" title="메인으로 돌아가기">
            🏠
        </button>

        <button class="my-location-btn" id="myLocationBtn" title="내 위치로 이동">
            <img src="/img/UserLocation.png" alt="내 위치">
        </button>

        <div class="radius-dropdown" id="radiusDropdown">
            <div class="radius-toggle" id="radiusToggle">
                <span class="label">반경</span>
                <span class="value" id="radiusValue">1km</span>
                <span class="arrow">▼</span>
            </div>
            <div class="radius-menu" id="radiusMenu">
                <div class="radius-option" data-value="300">300m <span class="check">✓</span></div>
                <div class="radius-option" data-value="500">500m <span class="check">✓</span></div>
                <div class="radius-option active" data-value="1000">1km <span class="check">✓</span></div>
                <div class="radius-option" data-value="2000">2km <span class="check">✓</span></div>
                <div class="radius-option" data-value="3000">3km <span class="check">✓</span></div>
            </div>
        </div>
    </div>
</div>

<%-- 하단 상세정보 카드 --%>
<div id="detailCard">
    <div class="detail-card-inner">
        <div class="detail-info-section">
            <h3 class="detail-title">
                <span id="cardName">장소명</span>
                <span class="detail-badge" id="cardDistance">0m</span>
            </h3>
            <p class="detail-address" id="cardAddress">주소 정보</p>
            <p class="detail-phone" id="cardPhone">전화번호 없음</p>
        </div>

        <div class="detail-actions">
            <button id="cardWalkBtn" class="route-btn walk-btn" title="도보 길찾기">도보</button>
            <button id="cardDriveBtn" class="route-btn drive-btn" title="자동차 길찾기">차량</button>
            <button class="detail-close" onclick="window.markerModule.closeDetailCard()">✕</button>
        </div>
    </div>
</div>

<div class="address-modal" id="addressModal">
    <div class="address-modal-content">
        <h2>📍 위치를 설정해주세요</h2>
        <p>위치 권한이 거부되었습니다. 주소를 검색하여 위치를 설정하세요.</p>

        <div class="address-input-wrap">
            <input type="text" id="addressInput" placeholder="주소 또는 장소명 입력 (예: 강남역, 서초동)"
                   onkeypress="if(event.key==='Enter') searchAddress()">
            <button onclick="searchAddress()">검색</button>
        </div>

        <div class="address-results" id="addressResults"></div>

        <button class="retry-location-btn" onclick="retryLocation()">
            🔄 위치 권한 다시 요청
        </button>
    </div>
</div>

<script>
    <%-- 병원 종류 선택 --%>
    const mode = new URLSearchParams(location.search).get("mode") || "vet";
    const hospitalType = new URLSearchParams(location.search).get("type");

    let titleByMode = (mode === "hospital") ? "일반병원" :
        (mode === "emergency") ? "응급실" :
            (mode === "pharmacy") ? "약국" : "동물병원";

    if (hospitalType) titleByMode = hospitalType;

    document.title = "내 주변 " + titleByMode;
    document.getElementById("listTitle").textContent = titleByMode;

    // 지도 생성및 검색 초기화
    const map = new kakao.maps.Map(document.getElementById("map"), {
        center: new kakao.maps.LatLng(37.5665, 126.9780),
        level: 3
    });

    window.onload = () => {
        if(window.markerModule) window.markerModule.initMarkerModule(map);
    };

    // 마커 이미지
    const myMarker = new kakao.maps.Marker({
        map,
        image: new kakao.maps.MarkerImage("/img/UserLocation.png", new kakao.maps.Size(40, 44), { offset: new kakao.maps.Point(18, 40) }),
        zIndex: 1000
    });

    let markerImg = "/img/AnimalHosLocation.png";
    if (mode === "hospital") markerImg = "/img/HospitalLocation.png";
    if (mode === "emergency") markerImg = "/img/EmergencyHosLocation.png";
    if (mode === "pharmacy") markerImg = "/img/PharmacyLocation.png";

    const placeMarkerImage = new kakao.maps.MarkerImage(markerImg, new kakao.maps.Size(40, 44), { offset: new kakao.maps.Point(16, 32) });

    let myPos = null;
    let rangeCircle = null;
    // 모드별 기본 반경 설정 : 일반 1km, 응급실 3km, 약국 500m
    let currentRadius = (mode === "emergency") ? 3000 :
        (mode === "pharmacy") ? 500 : 1000;

    let ignoreNextMapClick = false;
    const places = new kakao.maps.services.Places();
    const placeListEl = document.getElementById("placeList");
    const placeResults = [];  // 정렬용 배열 추가

    // ✅ 현재 열린 아코디언 항목 추적
    let currentOpenAccordion = null;

    function esc(s) {
        return String(s ?? "").replace(/[&<>"']/g, m => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&#39;" }[m]));
    }

    function clearResults() {
        resultMarkers.forEach(m => m.setMap(null));
        resultMarkers = [];
        placeListEl.innerHTML = "";
        placeResults.length = 0;
        currentOpenAccordion = null;
        if (rangeCircle) rangeCircle.setMap(null);
        if (window.markerModule) window.markerModule.clearAllMarkers();
        if (window.routeModule) window.routeModule.clearAllLayers();
    }

    function toggleAccordion(li, place) {
        const accordionContent = li.querySelector('.list-accordion-content');
        const chevron = li.querySelector('.accordion-chevron');

        if (currentOpenAccordion && currentOpenAccordion !== li) {
            const prevContent = currentOpenAccordion.querySelector('.list-accordion-content');
            const prevChevron = currentOpenAccordion.querySelector('.accordion-chevron');
            if (prevContent) {
                prevContent.classList.remove('open');
                currentOpenAccordion.classList.remove('accordion-open');
            }
            if (prevChevron) prevChevron.classList.remove('open');
        }

        if (accordionContent) {
            const isOpen = accordionContent.classList.toggle('open');
            li.classList.toggle('accordion-open', isOpen);
            if (chevron) chevron.classList.toggle('open', isOpen);

            currentOpenAccordion = isOpen ? li : null;

            if (isOpen) {
                const hoursEl = accordionContent.querySelector('.accordion-hours');
                if (hoursEl && hoursEl.textContent === '불러오는 중...') {
                    loadOpeningHours(place, hoursEl);
                }
            }
        }
    }

    // 영업시간 로드 함수
    function loadOpeningHours(place, hoursEl) {
        if (typeof window.fetchGoogleDetail !== 'function') {
            hoursEl.textContent = '영업시간 정보를 불러올 수 없습니다.';
            return;
        }

        window.fetchGoogleDetail(
            place.place_name,
            Number(place.y),
            Number(place.x),
            (googleDetail) => {
                if (!document.body.contains(hoursEl)) return;

                if (googleDetail?.opening_hours?.weekday_text) {
                    hoursEl.innerHTML = googleDetail.opening_hours.weekday_text
                        .map(d => '<div class="hours-row">' + esc(d) + '</div>')
                        .join('');
                } else {
                    hoursEl.textContent = '영업시간 정보가 없습니다.';
                }
            }
        );
    }

    // 정렬 함수
    function sortAndRenderList() {
        // 정렬: 영업중(거리순) > 정보없음(거리순) > 영업종료(거리순)
        placeResults.sort((a, b) => {
            const openOrder = (item) => item.isOpen === true ? 0 : item.isOpen === null ? 1 : 2;

            const orderDiff = openOrder(a) - openOrder(b);
            if (orderDiff !== 0) return orderDiff;

            return a.distance - b.distance;
        });

        placeListEl.innerHTML = '';
        placeResults.forEach(item => {
            placeListEl.appendChild(item.li);
        });

        const isFromAiSearch = sessionStorage.getItem("isAiSearch") === "true";

        if (isFromAiSearch && placeResults.length > 0) {
            setTimeout(() => {
                console.log("📍 AI 추천: 가장 가까운 병원의 상세정보를 자동으로 엽니다.");
                const firstHeader = placeResults[0].li.querySelector('.place-item-header');
                if (firstHeader) firstHeader.click();
                sessionStorage.removeItem("isAiSearch");
            }, 300);
        }
    }

    // 반경 드롭다운 선택 가능
    const radiusDropdown = document.getElementById('radiusDropdown');
    const radiusToggle = document.getElementById('radiusToggle');
    const radiusOptions = document.querySelectorAll('.radius-option');

    function updateRadiusUI(value) {
        document.getElementById('radiusValue').textContent = (value >= 1000) ? (value / 1000) + 'km' : value + 'm';
        radiusOptions.forEach(opt => {
            opt.classList.toggle('active', parseInt(opt.dataset.value) === value);
        });
    }

    radiusToggle.addEventListener('click', (e) => { e.stopPropagation(); radiusDropdown.classList.toggle('open'); });
    radiusOptions.forEach(option => {
        option.addEventListener('click', () => {
            currentRadius = parseInt(option.dataset.value);
            updateRadiusUI(currentRadius);
            radiusDropdown.classList.remove('open');
            if (myPos) searchWithinRadiusByMode(false, true);
        });
    });
    updateRadiusUI(currentRadius);

    // 지도 빈 곳 클릭 시 드롭다운 닫기
    document.addEventListener('click', (e) => {
        if (!radiusDropdown.contains(e.target)) {
            radiusDropdown.classList.remove('open');
        }
    });

    // 내 위치로 버튼
    document.getElementById('myLocationBtn').addEventListener('click', () => {
        if (myPos) {
            map.panTo(myPos);

            const currentLevel = map.getLevel();
            if (currentLevel !== 3) {
                let step = currentLevel < 3 ? 1 : -1;
                let level = currentLevel;

                const zoomInterval = setInterval(() => {
                    level += step;
                    map.setLevel(level);

                    if (level === 3) {
                        clearInterval(zoomInterval);
                    }
                }, 50);
            }
        } else {
            alert('현재 위치를 찾을 수 없습니다.');
        }
    });

    // 장소 검색 및 결과 표시
    const addedIds = new Set();
    const radiusSteps = [300, 500, 1000, 2000, 3000];
    let userSelectedRadius = false;

    function searchWithinRadiusByMode(autoExpand = false, userSelected = false) {
        if (!myPos) return;
        if (userSelected) userSelectedRadius = true;
        if (!autoExpand && !userSelected) userSelectedRadius = false;

        clearResults();
        addedIds.clear();

        rangeCircle = new kakao.maps.Circle({
            center: myPos, radius: currentRadius, strokeWeight: 2, strokeColor: '#2196F3', strokeOpacity: 0.7, fillColor: '#2196F3', fillOpacity: 0.08
        });
        rangeCircle.setMap(map);

        // 진료과목별 키워드 검색
        let keywords = (mode === "hospital") ?
            (hospitalType ? [hospitalType, hospitalType + "병원", hospitalType + "의원"] : ["종합병원", "병원"]) :
            (mode === "emergency") ? ["응급실", "응급의료센터"] :
                (mode === "pharmacy") ? ["약국"] : ["동물병원"];

        let idx = 0;
        let totalResults = 0;
        const bounds = new kakao.maps.LatLngBounds();
        bounds.extend(myPos);

        function runSearch() {
            places.keywordSearch(keywords[idx], (data, status, pagination) => {
                if (status === kakao.maps.services.Status.OK) {
                    data.forEach(place => {
                        if (addedIds.has(place.id)) return;

                        // 외과 검색 시 성형외과 제외
                        if (hospitalType === "외과") {
                            if (place.category_name?.includes("성형외과") || place.place_name.includes("성형")) {
                                return;
                            }
                        }

                        // 응급실 필터링
                        if (mode === "emergency" && ["FD6", "CE7"].includes(place.category_group_code)) return;
                        if (mode === "emergency") {
                            if (!/응급|병원|의료원/.test(place.place_name || "")) return;
                        }

                        addedIds.add(place.id);
                        totalResults++;

                        const pos = new kakao.maps.LatLng(place.y, place.x);
                        bounds.extend(pos);

                        const marker = new kakao.maps.Marker({ map, position: pos, image: placeMarkerImage });
                        resultMarkers.push(marker);

                        const dist = window.markerModule ? window.markerModule.calculateDistance(myPos, pos) : place.distance;
                        const distText = window.markerModule ? window.markerModule.formatDistance(dist) : (place.distance + 'm');

                        const li = document.createElement("li");
                        li.className = "place-item";
                        li.innerHTML =
                            '<div class="place-item-header">' +
                            '<div class="place-item-main">' +
                            '<div class="place-name">' + esc(place.place_name) + '</div>' +
                            '<div class="place-meta">' +
                            '<span class="distance">' + distText + '</span>' +
                            '<span class="list-open-badge" data-open-badge>확인중...</span>' +
                            esc(place.road_address_name || place.address_name) +
                            '</div>' +
                            '</div>' +
                            '<span class="accordion-chevron">▼</span>' +
                            '</div>' +
                            '<div class="list-accordion-content">' +
                            '<div class="accordion-hours-wrapper">' +
                            '<div class="accordion-hours-title">상세 영업시간</div>' +
                            '<div class="accordion-hours">불러오는 중...</div>' +
                            '</div>' +
                            '</div>';

                        placeListEl.appendChild(li);

                        const placeItem = {
                            place,
                            li,
                            marker,
                            distance: dist,
                            isOpen: null
                        };

                        placeResults.push(placeItem);

                        const badgeEl = li.querySelector("[data-open-badge]");
                        if (badgeEl && typeof window.fetchGoogleDetail === 'function') {
                            window.fetchGoogleDetail(
                                place.place_name,
                                Number(place.y),
                                Number(place.x),
                                (googleDetail) => {
                                    if (!document.body.contains(badgeEl)) return;

                                    if (googleDetail?.opening_hours && typeof googleDetail.opening_hours.open_now === 'boolean') {
                                        const isOpen = googleDetail.opening_hours.open_now;
                                        badgeEl.classList.remove("open", "closed", "no-info");

                                        placeItem.isOpen = isOpen;

                                        if (isOpen) {
                                            badgeEl.textContent = "영업중";
                                            badgeEl.classList.add("open");
                                        } else {
                                            badgeEl.textContent = "영업종료";
                                            badgeEl.classList.add("closed");
                                        }
                                    } else {
                                        badgeEl.classList.remove("open", "closed");
                                        badgeEl.textContent = "영업 정보 없음";
                                        badgeEl.classList.add("no-info");
                                        placeItem.isOpen = null;
                                    }

                                    sortAndRenderList();
                                }
                            );
                        }

                        const headerEl = li.querySelector('.place-item-header');

                        const openDetail = () => {
                            if (!window.markerModule) return;

                            if (window.clearRoute) window.clearRoute();

                            window.markerModule.showAllMarkers(resultMarkers);

                            window.markerModule.showDetailCard(
                                place,
                                map,
                                myPos,
                                distText
                            );

                            marker.setVisible(true);

                            window.markerModule.enlargeMarker(marker, markerImg);
                            window.markerModule.hideOtherMarkers(marker, resultMarkers);

                            map.panTo(pos);

                            toggleAccordion(li, place);
                        };

                        kakao.maps.event.addListener(marker, "click", openDetail);
                        headerEl.onclick = openDetail;
                    });

                    map.setBounds(bounds);

                    if (pagination.hasNextPage) {
                        pagination.nextPage();
                    } else if (++idx < keywords.length) {
                        runSearch();
                    } else {
                        checkAndExpandRadius();
                    }
                } else if (status === kakao.maps.services.Status.ZERO_RESULT) {
                    if (++idx < keywords.length) {
                        runSearch();
                    } else {
                        checkAndExpandRadius();
                    }
                }
            }, { location: myPos, radius: currentRadius, sort: kakao.maps.services.SortBy.DISTANCE });
        }

        function checkAndExpandRadius() {
            if (totalResults === 0 && currentRadius < 3000 && !userSelectedRadius) {
                const nextRadius = radiusSteps.find(r => r > currentRadius);
                if (nextRadius) {
                    console.log('결과 없음 - 반경 ' + currentRadius + 'm → ' + nextRadius + 'm 자동 확장');
                    currentRadius = nextRadius;
                    updateRadiusUI(currentRadius);
                    searchWithinRadiusByMode(true, false);
                } else {
                    showNoResultMessage(3000);
                }
            } else if (totalResults === 0) {
                showNoResultMessage(currentRadius);
            }
        }

        function showNoResultMessage(radius) {
            const radiusText = radius >= 1000 ? (radius / 1000) + 'km' : radius + 'm';
            placeListEl.innerHTML = '<li class="place-item" style="text-align:center; color:#666; padding:20px;">반경 ' + radiusText + ' 내에<br/>' + titleByMode + '이(가) 없습니다.</li>';
        }

        runSearch();
    }

    // 위치 정보
    window.selectAddress = (lat, lng) => {
        myPos = new kakao.maps.LatLng(lat, lng);
        map.setCenter(myPos); myMarker.setPosition(myPos);
        document.getElementById('addressModal').style.display = 'none';
        userSelectedRadius = false;
        searchWithinRadiusByMode();
    };

    function requestLocation() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                p => {
                    myPos = new kakao.maps.LatLng(p.coords.latitude, p.coords.longitude);
                    map.setCenter(myPos); myMarker.setPosition(myPos);
                    searchWithinRadiusByMode();
                },
                () => { document.getElementById('addressModal').style.display = 'flex'; }
            );
        }
    }
    requestLocation();

    // 위치 정보 권한 거부 시에 주소 검색
    function searchAddress() {
        const input = document.getElementById('addressInput');
        const keyword = input.value.trim();

        if (!keyword) {
            alert("주소 또는 장소명을 입력해주세요.");
            return;
        }

        places.keywordSearch(keyword, (result, status) => {
            const resultsEl = document.getElementById('addressResults');
            resultsEl.innerHTML = "";

            if (status === kakao.maps.services.Status.OK) {
                result.slice(0, 5).forEach(item => {
                    const div = document.createElement('div');
                    div.className = 'address-result-item';
                    div.innerHTML = '<div class="addr-name">' + esc(item.place_name) + '</div>' +
                        '<div class="addr-detail">' + esc(item.address_name || item.road_address_name || '') + '</div>';

                    div.onclick = () => {
                        selectAddress(item.y, item.x);
                    };
                    resultsEl.appendChild(div);
                });
            } else {
                resultsEl.innerHTML = "<p style='padding:20px; color:#999; text-align:center;'>검색 결과가 없습니다.</p>";
            }
        });
    }

    function retryLocation() {
        document.getElementById('addressModal').style.display = 'none';
        requestLocation();
    }

    document.addEventListener("DOMContentLoaded", function() {
        const walkBtn = document.getElementById("cardWalkBtn");
        if (walkBtn) {
            walkBtn.onclick = function() {
                const currentPlace = window.markerModule ? window.markerModule.currentPlace : null;
                if (currentPlace && typeof window.showWalkingRoute === 'function') {
                    window.showWalkingRoute(currentPlace, map, myPos);
                }
            };
        }

        const driveBtn = document.getElementById("cardDriveBtn");
        if (driveBtn) {
            driveBtn.onclick = function() {
                const currentPlace = window.markerModule ? window.markerModule.currentPlace : null;
                if (currentPlace && typeof window.showDrivingRoute === 'function') {
                    window.showDrivingRoute(currentPlace, map, myPos);
                }
            };
        }
    });

    // 구글 places 서비스
    const googleService = new google.maps.places.PlacesService(
        document.createElement("div")
    );

    // 구글에서 가져온 영업시간 정보
    function fetchGoogleDetail(placeName, lat, lng, callback) {
        const location = new google.maps.LatLng(lat, lng);

        googleService.nearbySearch({
            location,
            radius: 50,
            keyword: placeName
        }, (results, status) => {
            if (status !== google.maps.places.PlacesServiceStatus.OK || !results[0]) {
                callback(null);
                return;
            }

            const placeId = results[0].place_id;

            googleService.getDetails({
                placeId,
                fields: ["opening_hours", "formatted_phone_number", "website", "utc_offset_minutes"]
            }, (detail, detailStatus) => {
                if (detailStatus === google.maps.places.PlacesServiceStatus.OK) {
                    callback(detail);
                } else {
                    callback(null);
                }
            });
        });
    }
    window.fetchGoogleDetail = fetchGoogleDetail;

</script>
<jsp:include page="../common/chatbot.jsp"/>
<script src="/js/chatbot.js"></script>
<script src="/js/map-chatbot-init.js"></script>

<script>
    console.log("map element:", document.getElementById("map"));
    console.log("map height:", document.getElementById("map")?.offsetHeight);

    // 리스트 펼치기/접기
    const listPanel = document.getElementById("listPanel");
    const listToggleBtn = document.getElementById("listToggleBtn");

    listToggleBtn.addEventListener("click", () => {
        const isClosed = listPanel.classList.toggle("closed");
        listToggleBtn.textContent = isClosed ? "❯" : "❮";
    });

    // 지도 빈 곳 클릭 시 상세 정보창 닫기
    kakao.maps.event.addListener(map, 'click', function () {
        if (window.markerModule) {
            window.markerModule.closeDetailCard();
            window.markerModule.showAllMarkers(resultMarkers);
        }

        if (currentOpenAccordion) {
            const content = currentOpenAccordion.querySelector('.list-accordion-content');
            const chevron = currentOpenAccordion.querySelector('.accordion-chevron');
            if (content) {
                content.classList.remove('open');
                currentOpenAccordion.classList.remove('accordion-open');
            }
            if (chevron) chevron.classList.remove('open');
            currentOpenAccordion = null;
        }
    });

</script>

</body>
</html>
