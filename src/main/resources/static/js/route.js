// ========================================
// 길찾기 관련 변수
// ========================================
let routeLayers = [];

// ========================================
// 🚶 TMAP 보행자 경로 (도보)
// ========================================
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
                strokeWeight: 14,
                strokeColor: '#808000',  // 다크 올리브
                strokeOpacity: 0.3,
                map: map
            });

            const layer2 = new kakao.maps.Polyline({
                path: path,
                strokeWeight: 10,
                strokeColor: '#9a9850',  // 미디엄 올리브
                strokeOpacity: 0.6,
                map: map
            });

            const layer3 = new kakao.maps.Polyline({
                path: path,
                strokeWeight: 6,
                strokeColor: '#bab86c',  // 라이트 올리브
                strokeOpacity: 1.0,
                map: map
            });

            routeLayers.push(layer1, layer2, layer3);

            // 시간 계산
            const totalDist = data.features[0].properties.totalDistance;
            const walkingTime = Math.ceil(totalDist / 67);
            const kcal = (totalDist * 0.04).toFixed(1);

            // UI 업데이트 (올리브 그라디언트)
            const infoHTML = `
                <div style="padding: 15px; background: linear-gradient(135deg, #bab86c 0%, #808000 100%); border-radius: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.2); text-align: center; color: white;">
                    <div style="font-size: 1.3rem; font-weight: bold; margin-bottom: 8px;">
                        🚶 도보 약 ${walkingTime}분
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
    if (!myPos) return;
    clearRoute();

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
                strokeWeight: 12,
                strokeColor: '#FFB1B1',
                strokeOpacity: 0.3,
                map: map
            });

            const layer2 = new kakao.maps.Polyline({
                path: path,
                strokeWeight: 8,
                strokeColor: '#FF8A9B',
                strokeOpacity: 0.6,
                map: map
            });

            const layer3 = new kakao.maps.Polyline({
                path: path,
                strokeWeight: 5,
                strokeColor: '#F06292',
                strokeOpacity: 1.0,
                map: map
            });

            routeLayers.push(layer1, layer2, layer3);

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
                <div style="padding: 15px; background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); border-radius: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.2); text-align: center; color: white;">
                    <div style="font-size: 1.3rem; font-weight: bold; margin-bottom: 8px;">
                        🚗 차량 약 ${timeText}
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