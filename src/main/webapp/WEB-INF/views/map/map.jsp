<%@ page contentType="text/html; charset=UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="ko">
<head>
    <meta charset="utf-8"/>
    <title>내 주변 병원</title>

    <link rel="stylesheet" href="<c:url value='/css/style.css'/>">

    <%-- 1. 카카오 맵 API --%>
    <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoMapsKey}&libraries=services"></script>

    <%-- 2. 구글 맵 API --%>
    <script src="https://maps.googleapis.com/maps/api/js?key=${googleMapsKey}&libraries=places,geometry"></script>

    <script>
        // 전역 변수 설정
        const KAKAO_REST_API_KEY = "${kakaoRestKey}";
        const TMAP_APP_KEY = "${tmapAppKey}";

        // window 객체에도 설정
        window.KAKAO_REST_API_KEY = "${kakaoRestKey}";
        window.TMAP_APP_KEY = "${tmapAppKey}";
    </script>

    <%-- 3. 커스텀 JS 파일들 --%>
    <script src="<c:url value='/js/route.js'/>"></script>
    <script src="<c:url value='/js/marker.js'/>"></script>
</head>

<body>

<div id="mapWrap">
    <div id="listPanel">
        <div class="list-header">
            내 주변 <span id="listTitle"></span> 목록
        </div>
        <ul id="placeList"></ul>
    </div>

    <!-- ✅ 리스트 접기/펼치기 버튼 -->
    <button id="listToggleBtn" class="list-toggle-btn">❮</button>

    <div id="map">
        <!-- ✅ 내 위치로 돌아가기 버튼 -->
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
            <button id="cardWalkBtn" class="route-btn walk-btn" title="도보 길찾기">🚶 도보</button>
            <button id="cardDriveBtn" class="route-btn drive-btn" title="자동차 길찾기">🚗 차량</button>
            <button class="detail-close" onclick="window.markerModule.closeDetailCard()">✕</button>
        </div>
    </div>
    <div id="routeInfo" class="route-info"></div>
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
    /* =========================
       1. 초기 설정 및 모드 파악
    ========================= */
    const mode = new URLSearchParams(location.search).get("mode") || "vet";

    // ✅ 팀원 기능 추가: 진료과목별 병원 검색
    const hospitalType = new URLSearchParams(location.search).get("type");

    let titleByMode = (mode === "hospital") ? "일반병원" :
        (mode === "emergency") ? "응급실" :
            (mode === "pharmacy") ? "약국" : "동물병원";

    // ✅ 팀원 기능: 진료과목이 선택된 경우 제목 변경
    if (hospitalType) titleByMode = hospitalType;

    document.title = "내 주변 " + titleByMode;
    document.getElementById("listTitle").textContent = titleByMode;

    /* =========================
       2. 지도 생성 및 모듈 초기화
    ========================= */
    const map = new kakao.maps.Map(document.getElementById("map"), {
        center: new kakao.maps.LatLng(37.5665, 126.9780),
        level: 3
    });

    // marker.js 모듈 초기화
    window.onload = () => {
        if(window.markerModule) window.markerModule.initMarkerModule(map);
    };

    /* =========================
       3. 마커 이미지 설정
    ========================= */
    const myMarker = new kakao.maps.Marker({
        map,
        image: new kakao.maps.MarkerImage("/img/UserLocation.png", new kakao.maps.Size(40, 44), { offset: new kakao.maps.Point(18, 40) }),
        zIndex: 1
    });

    let markerImg = "/img/AnimalHosLocation.png";
    if (mode === "hospital") markerImg = "/img/HospitalLocation.png";
    if (mode === "emergency") markerImg = "/img/EmergencyHosLocation.png";
    if (mode === "pharmacy") markerImg = "/img/PharmacyLocation.png";

    const placeMarkerImage = new kakao.maps.MarkerImage(markerImg, new kakao.maps.Size(40, 44), { offset: new kakao.maps.Point(16, 32) });

    /* =========================
       4. 공통 변수 및 유틸리티
    ========================= */
    let myPos = null;
    let rangeCircle = null;
    let currentRadius = 1000;
    let ignoreNextMapClick = false;
    const places = new kakao.maps.services.Places();
    const placeListEl = document.getElementById("placeList");

    function esc(s) {
        return String(s ?? "").replace(/[&<>"']/g, m => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&#39;" }[m]));
    }

    function clearResults() {
        resultMarkers.forEach(m => m.setMap(null));
        resultMarkers = [];
        placeListEl.innerHTML = "";
        if (rangeCircle) rangeCircle.setMap(null);
        if (window.markerModule) window.markerModule.clearAllMarkers();
        if (window.routeModule) window.routeModule.clearAllLayers();
    }

    /* =========================
       5. 반경 드롭다운 로직
    ========================= */
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

    // 외부 클릭 시 드롭다운 닫기
    document.addEventListener('click', (e) => {
        if (!radiusDropdown.contains(e.target)) {
            radiusDropdown.classList.remove('open');
        }
    });

    /* =========================
       ✅ 내 위치로 돌아가기 버튼
    ========================= */
    document.getElementById('myLocationBtn').addEventListener('click', () => {
        if (myPos) {
            // 1️⃣ 위치 이동은 panTo()로 부드럽게
            map.panTo(myPos);

            // 2️⃣ 줌 레벨도 단계별로 부드럽게
            const currentLevel = map.getLevel();
            if (currentLevel !== 3) {
                let step = currentLevel < 3 ? 1 : -1;  // 확대/축소 방향 결정
                let level = currentLevel;

                const zoomInterval = setInterval(() => {
                    level += step;
                    map.setLevel(level);

                    if (level === 3) {
                        clearInterval(zoomInterval);  // 목표 레벨 도달 시 중단
                    }
                }, 50); // 50ms마다 한 단계씩 줌
            }
        } else {
            alert('현재 위치를 찾을 수 없습니다.');
        }
    });

    /* =========================
       6. 장소 검색 및 결과 표시
    ========================= */
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
            // pagination 매개변수 활용
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

                        // 거리 계산 및 리스트 아이템 생성
                        const dist = window.markerModule ? window.markerModule.calculateDistance(myPos, pos) : place.distance;
                        const distText = window.markerModule ? window.markerModule.formatDistance(dist) : (place.distance + 'm');

                        const li = document.createElement("li");
                        li.className = "place-item";
                        li.innerHTML = '<div class="place-name">' + esc(place.place_name) + '</div>' +
                            '<div class="place-meta">' +
                            '<span class="distance">' + distText + '</span>' +
                            '<span class="list-open-badge" data-open-badge>확인중...</span>' +
                            esc(place.road_address_name || place.address_name) +
                            '</div>';
                        placeListEl.appendChild(li);

                        // ✅ 영업 상태 뱃지 업데이트
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
                                        badgeEl.classList.remove("open", "closed");
                                        if (isOpen) {
                                            badgeEl.textContent = "영업중";
                                            badgeEl.classList.add("open");

                                            placeListEl.insertBefore(li, placeListEl.firstChild);  // 영업중부터 상단으로

                                        } else {
                                            badgeEl.textContent = "영업종료";
                                            badgeEl.classList.add("closed");
                                        }
                                    } else {
                                        badgeEl.textContent = "정보없음";
                                        badgeEl.style.display = "none";
                                    }
                                }
                            );
                        }

                        // 이벤트 연결 (상세 카드 호출)
                        const openDetail = () => {
                            if (window.markerModule) {
                                window.markerModule.showDetailCard(place, map, myPos, distText);
                            }
                            map.panTo(pos);
                        };
                        kakao.maps.event.addListener(marker, "click", openDetail);
                        li.onclick = openDetail;
                    });

                    map.setBounds(bounds);

                    // ✅ 팀원 기능: 다음 페이지가 있으면 계속 검색
                    if (pagination.hasNextPage) {
                        pagination.nextPage();
                    } else if (++idx < keywords.length) {
                        runSearch();
                    } else {
                        // 모든 검색 완료
                        checkAndExpandRadius();
                    }
                } else if (status === kakao.maps.services.Status.ZERO_RESULT) {
                    // 결과가 없는 경우 다음 키워드로
                    if (++idx < keywords.length) {
                        runSearch();
                    } else {
                        checkAndExpandRadius();
                    }
                }
            }, { location: myPos, radius: currentRadius, sort: kakao.maps.services.SortBy.DISTANCE });
        }

        // ✅ 결과 없으면 자동으로 반경 확장 (사용자가 직접 선택한 경우 제외)
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

    /* =========================
       7. 위치 정보 획득
    ========================= */
    window.selectAddress = (lat, lng) => {
        myPos = new kakao.maps.LatLng(lat, lng);
        map.setCenter(myPos); myMarker.setPosition(myPos);
        document.getElementById('addressModal').style.display = 'none';
        userSelectedRadius = false; // 새 위치에서는 자동 확장 허용
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

    /* =========================
       8. 주소 검색 (위치 권한 거부 시) - keywordSearch 사용
    ========================= */
    function searchAddress() {
        const input = document.getElementById('addressInput');
        const keyword = input.value.trim();

        if (!keyword) {
            alert("주소 또는 장소명을 입력해주세요.");
            return;
        }

        // ✅ keywordSearch로 변경 - 장소명, 주소 모두 검색 가능
        places.keywordSearch(keyword, (result, status) => {
            const resultsEl = document.getElementById('addressResults');
            resultsEl.innerHTML = "";

            if (status === kakao.maps.services.Status.OK) {
                // 상위 5개 결과만 표시
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

    // 위치 권한 재요청 함수
    function retryLocation() {
        document.getElementById('addressModal').style.display = 'none';
        requestLocation();
    }

    /* =========================
       9. 길찾기 버튼 이벤트 (도보/자동차)
    ========================= */
    document.addEventListener("DOMContentLoaded", function() {
        // 도보 버튼
        const walkBtn = document.getElementById("cardWalkBtn");
        if (walkBtn) {
            walkBtn.onclick = function() {
                const currentPlace = window.markerModule ? window.markerModule.currentPlace : null;
                if (currentPlace && typeof window.showWalkingRoute === 'function') {
                    window.showWalkingRoute(currentPlace, map, myPos);
                }
            };
        }

        // 자동차 버튼
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

    /* =========================
       ✅ Google Places 서비스
    ========================= */
    const googleService = new google.maps.places.PlacesService(
        document.createElement("div")
    );

    /* =========================
       ✅ Google 운영시간 조회
    ========================= */
    function fetchGoogleDetail(placeName, lat, lng, callback) {
        const location = new google.maps.LatLng(lat, lng);

        // 1️⃣ 주변 검색 (이름 기준)
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

            // 2️⃣ 상세 정보 요청
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

    /* =========================
   리스트 접기 / 펼치기
========================= */
    const listPanel = document.getElementById("listPanel");
    const listToggleBtn = document.getElementById("listToggleBtn");

    listToggleBtn.addEventListener("click", () => {
        const isClosed = listPanel.classList.toggle("closed");

        // 버튼 방향 변경
        listToggleBtn.textContent = isClosed ? "❯" : "❮";
    });

    /* =========================
        지도 클릭 시 상세 카드 닫기
    ========================= */
    kakao.maps.event.addListener(map, 'click', function () {
        if (window.markerModule) {
            window.markerModule.closeDetailCard();
        }
    });

</script>

</body>
</html>
