// ========================================
// ✅ TMAP 보행자 경로 모듈 (깔끔한 버전)
// ========================================
let routeLayers = [];
const apiKey = window.TMAP_APP_KEY;

async function showWalkingRoute(place, map, myPos) {
    if (!myPos) return;
    clearRoute();

    const url = "https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1&format=json";
    const body = {
        startX: myPos.getLng().toString(),
        startY: myPos.getLat().toString(),
        endX: place.x.toString(),
        endY: place.y.toString(),
        reqCoordType: "WGS84GEO",
        resCoordType: "WGS84GEO",
        startName: "Origin",
        endName: "Destination"
    };

    try {
        const response = await fetch(url, {
            method: "POST",
            headers: {
                "appKey": TMAP_APP_KEY,
                "Content-Type": "application/json"
            },
            body: JSON.stringify(body)
        });

        const data = await response.json();

        if (data.features) {
            const path = [];
            data.features.forEach(feature => {
                if (feature.geometry.type === "LineString") {
                    feature.geometry.coordinates.forEach(coord => {
                        path.push(new kakao.maps.LatLng(coord[1], coord[0]));
                    });
                }
            });

            // 1. 경로 그리기 (애니메이션 없이 즉시 혹은 부드럽게)
            renderPath(path, map);

            // 2. 현실적인 시간 계산 (중요!)
            const totalDist = data.features[0].properties.totalDistance; // 미터(m)

            // 티맵 시간 대신 직접 계산: 1분당 67m (성인 보통 걸음)
            const walkingTime = Math.ceil(totalDist / 67);
            const kcal = (totalDist * 0.04).toFixed(1);

            // 3. UI 업데이트
            const infoHTML = `
                <div style="padding: 15px; background: #fff; border-radius: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); text-align: center;">
                    <div style="font-size: 1.2rem; font-weight: bold; color: #3897FF; margin-bottom: 5px;">
                        약 ${walkingTime}분 소요
                    </div>
                    <div style="font-size: 0.9rem; color: #666;">
                        남은 거리: ${totalDist}m | 소모 칼로리: ${kcal}kcal
                    </div>
                </div>
            `;

            if (window.markerModule?.updateRouteInfo) {
                window.markerModule.updateRouteInfo(infoHTML, "티맵 실시간 보행 안내");
            }

            // 4. 지도 줌 조절
            const bounds = new kakao.maps.LatLngBounds();
            path.forEach(p => bounds.extend(p));
            map.setBounds(bounds, 80, 80, 80, 80);
        }
    } catch (e) {
        console.error("Route Error:", e);
    }
}

function renderPath(path, map) {
    const line = new kakao.maps.Polyline({
        path: path,
        strokeWeight: 6,
        strokeColor: '#3897FF',
        strokeOpacity: 0.8,
        strokeStyle: 'shortdash', // 점선 스타일 유지 (보행자 느낌)
        map: map
    });
    routeLayers.push(line);
}

function clearRoute() {
    routeLayers.forEach(l => l.setMap(null));
    routeLayers = [];
}