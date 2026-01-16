// ========================================
// 길찾기 관련 변수
// ========================================
let routeLayers = [];
let activeRouteType = null;  // 👈 추가: 'walking' | 'driving' | null

// ========================================
// 🚶 TMAP 보행자 경로 (도보)
// ========================================
async function showWalkingRoute(place, map, myPos) {
    // 토글 체크
    if (activeRouteType === 'walking') {
        clearRoute();
        activeRouteType = null;
        return;  // 경로 지우고 종료
    }

    if (!myPos) return;
    clearRoute();
    activeRouteType = 'walking';  // 상태 설정

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
                "appKey": window.TMAP_APP_KEY,
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

            // 올리브 그라디언트 3중 레이어 경로선 (실선)
            const layer1 = new kakao.maps.Polyline({
                path: path,
                strokeWeight: 9.4,
                strokeColor: '#1b5087',
                strokeOpacity: 0.8,
                map: map
            });

            const layer2 = new kakao.maps.Polyline({
                path: path,
                strokeWeight: 7,
                strokeColor: '#378ba8',
                strokeOpacity: 0.6,
                map: map
            });

            routeLayers.push(layer1, layer2);

            // 시간 계산
            const totalDist = data.features[0].properties.totalDistance;
            const walkingTime = Math.ceil(totalDist / 67);
            const kcal = (totalDist * 0.04).toFixed(1);

            // UI 업데이트 (올리브 그라디언트)
            const infoHTML = `
                <div style="padding: 12px; background: linear-gradient(135deg, #378ba8 0%, #1b5087 100%); border-radius: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.2); text-align: center; color: white;">
                    <div style="font-size: 1.2rem; font-weight: bold; margin-bottom: 8px;">
                        도보 약 ${walkingTime}분
                    </div>
                    <div style="font-size: 0.95rem; opacity: 0.9;">
                        거리 ${totalDist}m · 칼로리 ${kcal}kcal
                    </div>
                </div>
            `;

            if (window.markerModule?.updateRouteInfo) {
                window.markerModule.updateRouteInfo(infoHTML, "도보 경로");
            }

            // 지도 줌 조절
            const bounds = new kakao.maps.LatLngBounds();
            path.forEach(p => bounds.extend(p));
            map.setBounds(bounds, 80, 80, 80, 80);
        }
    } catch (e) {
        console.error("도보 경로 오류:", e);
        alert("도보 경로를 찾을 수 없습니다.");
    }
}

// ========================================
// 🚗 카카오 자동차 경로
// ========================================
async function showDrivingRoute(place, map, myPos) {
    // 토글 체크
    if (activeRouteType === 'driving') {
        clearRoute();
        activeRouteType = null;
        return;  // 경로 지우고 종료
    }

    if (!myPos) return;
    clearRoute();
    activeRouteType = 'driving';  // 상태 설정

    const url = 'https://apis-navi.kakaomobility.com/v1/waypoints/directions';
    const body = {
        origin: {
            x: myPos.getLng(),
            y: myPos.getLat()
        },
        destination: {
            x: parseFloat(place.x),
            y: parseFloat(place.y)
        },
        priority: 'RECOMMEND',
        car_fuel: 'GASOLINE',
        car_hipass: false,
        alternatives: false,
        road_details: false
    };

    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Authorization': `KakaoAK ${window.KAKAO_REST_API_KEY}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(body)
        });

        if (!response.ok) {
            alert('자동차 경로를 찾을 수 없습니다.');
            return;
        }

        const data = await response.json();

        if (data.routes && data.routes.length > 0) {
            const route = data.routes[0];
            const path = [];

            // 경로 좌표 추출
            route.sections.forEach(section => {
                section.roads.forEach(road => {
                    road.vertexes.forEach((vertex, idx) => {
                        if (idx % 2 === 0) {
                            path.push(new kakao.maps.LatLng(
                                road.vertexes[idx + 1],
                                road.vertexes[idx]
                            ));
                        }
                    });
                });
            });

            // 3중 레이어 경로선
            const layer1 = new kakao.maps.Polyline({
                path: path,
                strokeWeight: 9.4,
                strokeColor: '#10af7c',
                strokeOpacity: 0.8,
                map: map
            });

            const layer2 = new kakao.maps.Polyline({
                path: path,
                strokeWeight: 7,
                strokeColor: '#12a982',
                strokeOpacity: 0.6,
                map: map
            });

            routeLayers.push(layer1, layer2);

            // 거리/시간 정보
            const distance = route.summary.distance;
            const duration = route.summary.duration; // 초 단위

            const distText = distance >= 1000
                ? `${(distance / 1000).toFixed(1)}km`
                : `${distance}m`;

            const timeMinutes = Math.ceil(duration / 60);
            const timeText = timeMinutes >= 60
                ? `${Math.floor(timeMinutes / 60)}시간 ${timeMinutes % 60}분`
                : `${timeMinutes}분`;

            // UI 업데이트
            const infoHTML = `
                <div style="padding: 12px; background: linear-gradient(135deg, #12a982 0%, #10af7c 100%); border-radius: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.2); text-align: center; color: white;">
                    <div style="font-size: 1.2rem; font-weight: bold; margin-bottom: 8px;">
                        차량 약 ${timeText}
                    </div>
                    <div style="font-size: 0.95rem; opacity: 0.9;">
                        거리 ${distText}
                    </div>
                </div>
            `;

            if (window.markerModule?.updateRouteInfo) {
                window.markerModule.updateRouteInfo(infoHTML, "자동차 경로");
            }

            // 지도 줌 조절
            const bounds = new kakao.maps.LatLngBounds();
            path.forEach(p => bounds.extend(p));
            map.setBounds(bounds, 80, 80, 80, 80);
        }

    } catch (error) {
        console.error('자동차 경로 오류:', error);
        alert('자동차 경로를 찾을 수 없습니다.');
    }
}

// ========================================
// 경로 지우기
// ========================================
function clearRoute() {
    routeLayers.forEach(l => l.setMap(null));
    routeLayers = [];
    activeRouteType = null;

    if (window.markerModule?.updateRouteInfo) {
        window.markerModule.updateRouteInfo('', '');
    }
}

// ========================================
// 외부 export
// ========================================
window.showWalkingRoute = showWalkingRoute;
window.showDrivingRoute = showDrivingRoute;
window.clearRoute = clearRoute;
window.routeModule = {
    clearAllLayers: clearRoute
};