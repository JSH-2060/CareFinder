/**
 * marker.js
 * 마커 관리 및 상세 카드 제어 모듈 (✅ Google 영업시간 기능 + 마커 확대/축소)
 */

// [중요] 변수는 여기서만 선언합니다.
let resultMarkers = [];
let hoverOverlay = null;
let detailCard = null;

// ✅ 마커 확대/축소 관리 변수
let selectedMarker = null;
const originalMarkerImages = new Map();

// ✅ 구글 영업상태/상세 캐시 & 동시요청 제한
const openStatusCache = new Map();     // key -> { text, state }  (영업중/종료)
const googleDetailCache = new Map();   // key -> googleDetail (opening_hours 등)

const openStatusQueue = [];
let openStatusActive = 0;
const MAX_OPEN_REQ = 3;               // 동시에 3개만 요청 (필요시 조절)

// 검색/결과 초기화 시 이전 요청 무시용 토큰
let searchToken = 0;

// ========================================
// 초기화 함수
// ========================================
function initMarkerModule(map) {
    hoverOverlay = new kakao.maps.CustomOverlay({
        yAnchor: 1.6,
        zIndex: 200
    });
    detailCard = document.getElementById('detailCard');
}

// ========================================
// HTML 이스케이프 함수
// ========================================
function esc(s) {
    return String(s ?? "").replace(/[&<>"']/g, m => ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        "\"": "&quot;",
        "'": "&#39;"
    }[m]));
}

// ========================================
// 거리 계산 함수 (Haversine 공식)
// ========================================
function calculateDistance(from, to) {
    if(!from || !to) return 0;
    const r = Math.PI / 180;
    const R = 6371000;
    const a =
        Math.sin((to.getLat() - from.getLat()) * r / 2) ** 2 +
        Math.cos(from.getLat() * r) *
        Math.cos(to.getLat() * r) *
        Math.sin((to.getLng() - from.getLng()) * r / 2) ** 2;
    return 2 * R * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

// ========================================
// 거리 텍스트 변환 함수
// ========================================
function formatDistance(distance) {
    return distance < 1000
        ? Math.round(distance) + "m"
        : (distance / 1000).toFixed(1) + "km";
}

// ========================================
// ✅ place 고유키 생성 (캐시용)
// ========================================
function getPlaceKey(place) {
    return place.id || `${place.place_name}|${place.y},${place.x}`;
}

// ========================================
// ✅ 리스트/상세 공용: 영업 뱃지 적용
// ========================================
function applyOpenBadge(badgeEl, info) {
    if (!badgeEl) return;

    badgeEl.classList.remove("open", "closed");

    if (!info) {
        badgeEl.textContent = "정보없음";
        return;
    }

    badgeEl.textContent = info.text;

    if (info.state === "open") badgeEl.classList.add("open");
    if (info.state === "closed") badgeEl.classList.add("closed");
}

// ========================================
// ✅ 구글 상세정보 기반으로 영업상태 캐시 생성
// ========================================
function toOpenInfo(googleDetail) {
    const oh = googleDetail?.opening_hours;
    if (!oh || typeof oh.open_now !== "boolean") {
        return { text: "정보없음", state: null };
    }
    return oh.open_now
        ? { text: "영업중", state: "open" }
        : { text: "영업종료", state: "closed" };
}

// ========================================
// ✅ place당 영업상태 요청 (큐 + 캐시)
// ========================================
function requestOpenStatus(place, badgeEl, tokenAtRequest) {
    const key = getPlaceKey(place);

    // 캐시 있으면 바로 적용
    if (openStatusCache.has(key)) {
        applyOpenBadge(badgeEl, openStatusCache.get(key));
        return;
    }

    // fetchGoogleDetail이 없으면 표시만 하고 종료
    if (typeof window.fetchGoogleDetail !== "function") {
        applyOpenBadge(badgeEl, { text: "미설정", state: null });
        return;
    }

    // 로딩 표시
    if (badgeEl) badgeEl.textContent = "확인중...";

    // 큐에 넣고 처리
    openStatusQueue.push({ place, badgeEl, key, tokenAtRequest });
    processOpenStatusQueue();
}

function processOpenStatusQueue() {
    while (openStatusActive < MAX_OPEN_REQ && openStatusQueue.length > 0) {
        const job = openStatusQueue.shift();
        openStatusActive++;

        const { place, badgeEl, key, tokenAtRequest } = job;

        window.fetchGoogleDetail(
            place.place_name,
            Number(place.y),
            Number(place.x),
            (googleDetail) => {
                // 검색이 바뀐 뒤 들어온 응답이면 무시
                if (tokenAtRequest !== searchToken) {
                    openStatusActive--;
                    processOpenStatusQueue();
                    return;
                }

                // 구글 상세 캐시 저장(상세카드에도 재사용 가능)
                if (googleDetail) {
                    googleDetailCache.set(key, googleDetail);
                }

                const info = toOpenInfo(googleDetail);
                openStatusCache.set(key, info);

                // 요소가 아직 DOM에 있을 때만 업데이트
                if (badgeEl && document.body.contains(badgeEl)) {
                    applyOpenBadge(badgeEl, info);
                }

                openStatusActive--;
                processOpenStatusQueue();
            }
        );
    }
}

// ========================================
// ✅ 새로운 기능: 마커 확대 함수
// ========================================
function enlargeMarker(marker, markerImgSrc) {
    // 원본 이미지 저장
    if (!originalMarkerImages.has(marker)) {
        originalMarkerImages.set(marker, marker.getImage());
    }

    // 확대된 이미지 생성 (1.5배)
    const enlargedImage = new kakao.maps.MarkerImage(
        markerImgSrc,
        new kakao.maps.Size(60, 66), // 원본 40x44 -> 60x66
        { offset: new kakao.maps.Point(24, 48) } // 중심점도 비례 조정
    );

    marker.setZIndex(999);
    marker.setImage(enlargedImage);

    // ✅ 내부 변수도 업데이트
    selectedMarker = marker;
    window.markerModule.selectedMarker = marker; // 🔥 동기화
}

// ========================================
// ✅ 새로운 기능: 마커 원래 크기로 복원
// ========================================
function restoreMarker(marker) {
    if (originalMarkerImages.has(marker)) {
        marker.setImage(originalMarkerImages.get(marker));
        marker.setZIndex(1);
    }
}

// ========================================
// 선택된 마커 제외 나머지 숨기기
// ========================================
function hideOtherMarkers(selectedMkr, allMarkers) {
    allMarkers.forEach(marker => {
        if (marker !== selectedMkr) {
            marker.setVisible(false);
        }
    });
}

// ========================================
// 모든 마커 다시 표시
// ========================================
function showAllMarkers(allMarkers) {
    allMarkers.forEach(marker => {
        marker.setVisible(true);
    });

    // 선택된 마커가 있으면 원래 크기로 복원
    if (selectedMarker) {
        restoreMarker(selectedMarker);
        selectedMarker = null;
        window.markerModule.selectedMarker = null;
    }
}

// ========================================
// 마커 관리 (추가 및 삭제)
// ========================================

// map.jsp에서 생성한 마커를 이 모듈의 배열에 등록하는 함수
function addMarker(marker) {
    resultMarkers.push(marker);
}

// ✅ 모든 마커 제거 + 구글 큐/토큰 초기화
function clearAllMarkers() {
    // 검색 토큰 증가 → 이전 요청 응답 무시
    searchToken++;

    resultMarkers.forEach(m => m.setMap(null));
    resultMarkers = [];
    originalMarkerImages.clear();  // ✅ 마커 이미지 맵 초기화
    selectedMarker = null;  // ✅ 선택된 마커 초기화

    if (hoverOverlay) hoverOverlay.setMap(null);
    closeDetailCard();

    // 큐 비우기
    openStatusQueue.length = 0;
    openStatusActive = 0;

    // (선택) 캐시 유지하고 싶으면 아래 두 줄은 주석 처리하면 됨
    // openStatusCache.clear();
    // googleDetailCache.clear();
}

// ========================================
// ✅ 상세정보 카드 표시 (구글 운영시간 + 영업상태 포함)
// ========================================
function showDetailCard(place, map, myPos, distanceText) {
    if (!detailCard) detailCard = document.getElementById('detailCard');
    if (!detailCard) return;

    // ✅ currentPlace 저장 (길찾기 버튼에서 사용)
    window.markerModule.currentPlace = place;

    detailCard.innerHTML = `
    <div class="detail-card-inner">
      <div class="detail-info-section">
        <h3 class="detail-title">
          <span>${esc(place.place_name)}</span>
          <span id="googleOpenNowBadge" class="main-open-badge">확인중...</span>
        </h3>
        <p class="detail-address">
            ${distanceText ? `<span class="detail-badge">${esc(distanceText)}</span>` : ""}
            ${esc(place.road_address_name || place.address_name)}
        </p>
        <p class="detail-phone">${place.phone ? esc(place.phone) : "전화번호 없음"}</p>

        <div class="detail-google">
            <details class="hours-accordion">
                <summary class="detail-hours-head">
                    <b>🕒 상세 영업시간 보기</b>
                    <span class="chevron">▼</span>
                </summary>
                <div id="googleOpeningHours" class="opening-hours">
                    불러오는 중...
                </div>
            </details>
        </div>
      </div>

      <div class="detail-actions">
        <button id="cardWalkBtn" class="route-btn walk-btn" title="도보 길찾기">🚶 도보</button>
        <button id="cardDriveBtn" class="route-btn drive-btn" title="자동차 길찾기">🚗 차량</button>
        <button class="detail-close" onclick="window.markerModule.closeDetailCard()">✕</button>
      </div>
    </div>
    <div id="routeInfo" class="route-info"></div>
  `;
    detailCard.classList.add('active');

    // ✅ 버튼 이벤트 연결
    const walkBtn = document.getElementById("cardWalkBtn");
    const driveBtn = document.getElementById("cardDriveBtn");

    if (walkBtn) {
        walkBtn.onclick = () => {
            if (typeof window.showWalkingRoute === 'function') {
                window.showWalkingRoute(place, map, myPos);
            }
        };
    }

    if (driveBtn) {
        driveBtn.onclick = () => {
            if (typeof window.showDrivingRoute === 'function') {
                window.showDrivingRoute(place, map, myPos);
            }
        };
    }

    // Google 운영시간 로드
    const badgeEl = document.getElementById("googleOpenNowBadge");
    const hoursEl = document.getElementById("googleOpeningHours");

    const key = getPlaceKey(place);

    // 1) 캐시가 있으면 먼저 즉시 반영
    if (googleDetailCache.has(key)) {
        const cached = googleDetailCache.get(key);
        renderGoogleDetailToCard(cached, badgeEl, hoursEl);
        return;
    }

    // 2) 캐시 없으면 구글 호출
    if (typeof window.fetchGoogleDetail !== "function") {
        if (badgeEl) badgeEl.textContent = "기능 준비 안됨";
        if (hoursEl) hoursEl.textContent = "운영시간 기능 준비 안됨";
        return;
    }

    // 현재 토큰 캡처 (검색 바뀌면 무시)
    const tokenAtRequest = searchToken;

    window.fetchGoogleDetail(
        place.place_name,
        Number(place.y),
        Number(place.x),
        (googleDetail) => {
            if (tokenAtRequest !== searchToken) return;

            if (googleDetail) googleDetailCache.set(key, googleDetail);
            renderGoogleDetailToCard(googleDetail, badgeEl, hoursEl);
        }
    );
}

// 상세카드에 구글 상세정보 렌더
function renderGoogleDetailToCard(googleDetail, badgeEl, hoursEl) {
    if (!googleDetail?.opening_hours) {
        // 데이터가 없으면 뱃지를 계속 숨김 처리
        if (badgeEl) badgeEl.style.display = 'none';
        if (hoursEl) hoursEl.textContent = "운영시간 정보 없음";
        return;
    }

    const info = toOpenInfo(googleDetail);

    if (badgeEl) {
        badgeEl.classList.remove("open", "closed");
        badgeEl.textContent = info.text;

        if (info.state === "open") {
            badgeEl.classList.add("open");
            badgeEl.style.display = 'inline-flex'; // ✅ 영업중일 때만 표시
        } else if (info.state === "closed") {
            badgeEl.classList.add("closed");
            badgeEl.style.display = 'inline-flex'; // ✅ 영업종료일 때만 표시
        }
    }

    // 요일별 시간 렌더링
    const weekday = googleDetail.opening_hours.weekday_text;
    if (weekday && hoursEl) {
        hoursEl.innerHTML = weekday
            .map(d => `<div>${esc(d)}</div>`)
            .join("");
    }
}

function closeDetailCard() {
    if (detailCard) detailCard.classList.remove('active');

    const routeInfo = document.getElementById('routeInfo');
    if (routeInfo) {
        routeInfo.style.display = 'none';
        routeInfo.innerHTML = '';
    }

    if (window.routeModule) window.routeModule.clearAllLayers();

    // 모든 마커 다시 표시 + 선택된 마커 복원
    resultMarkers.forEach(marker => {
        marker.setVisible(true);
    });

    // 마커 상태도 함께 정리
    if (selectedMarker) {
        restoreMarker(selectedMarker);
        selectedMarker = null;
        window.markerModule.selectedMarker = null;
    }
}

// ========================================
// 경로 정보 업데이트
// ========================================
function updateRouteInfo(distText, timeText) {
    const routeInfo = document.getElementById('routeInfo');
    if (routeInfo) {
        routeInfo.innerHTML = `
            <div class="route-details">
                 <span class="route-distance">${distText}</span>
                 <span class="route-time"></span>
            </div>
        `;
        routeInfo.style.display = 'block';
    }
}

// ========================================
// createMarker (리스트에 영업상태 뱃지 추가)
// ========================================
function createMarker(place, markerImage, map, myPos, placeListEl) {
    const pos = new kakao.maps.LatLng(place.y, place.x);

    // 거리 계산
    const distance = calculateDistance(myPos, pos);
    const distanceText = formatDistance(distance);

    // 마커 생성
    const marker = new kakao.maps.Marker({
        map,
        position: pos,
        image: markerImage
    });
    resultMarkers.push(marker);

    // ✅ 팀원 기능: 리스트 아이템에 영업상태 뱃지 추가
    const li = document.createElement("li");
    li.className = "place-item";
    li.innerHTML = `
    <div class="place-name">${esc(place.place_name)}</div>
    <div class="place-meta">
      <span class="distance">${distanceText}</span>
      <span class="list-open-badge" data-open-badge>확인중...</span>
      ${esc(place.road_address_name || place.address_name || "")}<br/>
      ${place.phone ? "📞 " + esc(place.phone) : ""}
    </div>
  `;

    // ✅ 리스트 영업상태 요청 (검색 토큰 함께 전달)
    const badgeEl = li.querySelector("[data-open-badge]");
    requestOpenStatus(place, badgeEl, searchToken);

    // Hover 이벤트
    kakao.maps.event.addListener(marker, "mouseover", () => {
        hoverOverlay.setContent(`<div class="hover-label">${esc(place.place_name)}</div>`);
        hoverOverlay.setPosition(pos);
        hoverOverlay.setMap(map);
    });

    kakao.maps.event.addListener(marker, "mouseout", () => {
        hoverOverlay.setMap(null);
    });

    // 클릭 이벤트 - 하단 카드에 정보 표시
    const openDetail = () => {
        showDetailCard(place, map, myPos, distanceText);
        map.panTo(pos);
        hoverOverlay.setMap(null);
    };

    kakao.maps.event.addListener(marker, "click", openDetail);
    li.addEventListener("click", openDetail);

    return { marker, pos, li, distance };
}

// ========================================
// 외부 노출 인터페이스
// ========================================
window.markerModule = {
    initMarkerModule,
    addMarker,
    clearAllMarkers,
    showDetailCard,
    closeDetailCard,
    updateRouteInfo,
    calculateDistance,
    formatDistance,
    createMarker,
    esc,
    currentPlace: null,
    enlargeMarker,      // ✅ 마커 확대
    restoreMarker,      // ✅ 마커 복원
    hideOtherMarkers,   // ✅ 나머지 마커 숨기기
    showAllMarkers,     // ✅ 모든 마커 표시
    selectedMarker      // ✅ 선택된 마커 (외부에서 접근 가능)
};

window.clickNearestMarker = function() {
    if (resultMarkers && resultMarkers.length > 0) {
        // resultMarkers[0]은 보통 가장 가까운 병원입니다.
        // 그 병원의 리스트 아이템(li)을 강제로 클릭합니다.
        console.log("📍 가장 가까운 병원 자동 선택 실행");
        resultMarkers[0].li.click();
    }
}