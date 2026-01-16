/* =========================================
   1. Flatpickr (달력) 초기화
   ========================================= */
const fpConfig = {
    locale: "ko",
    dateFormat: "Y-m-d H:i",
    enableTime: true,
    time_24hr: true,
    defaultDate: new Date(),
    allowInput: true
};

// 모달 내부의 datepicker들을 초기화
const addPicker = flatpickr("#addModal .datepicker", fpConfig);
const editPicker = flatpickr("#editModal .datepicker", fpConfig);


/* =========================================
   2. 유효성 검사 (체온 범위 제한)
   ========================================= */
function validateForm(form) {
    const tempInput = form.querySelector('input[name="temperature"]');
    const val = parseFloat(tempInput.value);

    if (val < 34.0 || val > 43.0) {
        alert("체온은 34.0도 ~ 43.0도 사이만 입력 가능합니다.\n정상적인 수치를 입력해주세요!");
        tempInput.value = "";
        tempInput.focus();
        return false;
    }
    return true;
}


/* =========================================
   3. 수정 모달 열기
   ========================================= */
function openEditModal(row) {
    // data 속성 읽기
    const no = row.getAttribute('data-no');
    const temp = row.getAttribute('data-temp');
    const date = row.getAttribute('data-date');
    const memo = row.getAttribute('data-memo');

    // 폼에 값 채우기
    document.getElementById('edit_heatNo').value = no;
    document.getElementById('edit_temperature').value = temp;
    document.getElementById('edit_memo').value = memo;

    // 날짜 설정
    if (date) editPicker.setDate(date);

    // 부트스트랩 모달 띄우기
    new bootstrap.Modal(document.getElementById('editModal')).show();
}


/* =========================================
   4. 차트 그리기 (가독성 개선: 흰 배경 대응)
   ========================================= */
function renderHeatChart(labels, dataPoints) {
    const ctx = document.getElementById('tempChart').getContext('2d');

    // 동적 Y축 최대값
    let maxTemp = 40;
    if (dataPoints.length > 0) {
        const dataMax = Math.max(...dataPoints);
        if (dataMax >= 40) {
            maxTemp = dataMax + 1.0;
        }
    }

    // [플러그인] 배경 색상 밴드
    const temperatureBands = {
        id: 'temperatureBands',
        beforeDraw(chart) {
            const { ctx, chartArea, scales } = chart;
            if (!chartArea) return;
            const y = scales.y;
            const left = chartArea.left;
            const right = chartArea.right;

            const bands = [
                { min: 35.0, max: 36.0, color: 'rgba(148,163,184,0.1)' }, // 아주 연한 회색
                { min: 37.3, max: 38.0, color: 'rgba(253,186,116,0.15)' }, // 연한 주황
                { min: 38.0, max: 39.0, color: 'rgba(252,165,165,0.15)' }, // 연한 빨강
                { min: 39.0, max: maxTemp + 2, color: 'rgba(216,180,254,0.15)' } // 연한 보라
            ];

            ctx.save();
            bands.forEach(b => {
                const yMaxPixel = y.getPixelForValue(Math.min(b.max, y.max));
                const yMinPixel = y.getPixelForValue(Math.max(b.min, y.min));
                if (yMaxPixel < yMinPixel) {
                    ctx.fillStyle = b.color;
                    ctx.fillRect(left, y.getPixelForValue(b.max), right - left, y.getPixelForValue(b.min) - y.getPixelForValue(b.max));
                }
            });
            ctx.restore();
        }
    };

    // [플러그인] 오른쪽 라벨
    const temperatureRightLabels = {
        id: 'temperatureRightLabels',
        afterDraw(chart) {
            const { ctx, chartArea, scales } = chart;
            if (!chartArea) return;
            const y = scales.y;
            const right = chartArea.right;

            ctx.save();
            ctx.textAlign = 'left';
            ctx.textBaseline = 'middle';
            ctx.font = 'bold 12px Pretendard';

            const lines = [
                { v: 37.3, text: '37.3℃ 미열',  color: '#f97316' },
                { v: 38.0, text: '38.0℃ 고열',  color: '#ef4444' },
                { v: 39.0, text: '39.0℃ 초고열', color: '#7e22ce' }
            ];

            lines.forEach(l => {
                if (l.v <= scales.y.max && l.v >= scales.y.min) {
                    const py = y.getPixelForValue(l.v);
                    // 배경 흰색 박스 (글자 잘 보이게)
                    ctx.fillStyle = 'rgba(255,255,255,0.9)';
                    ctx.fillRect(right + 2, py - 9, 85, 18);

                    ctx.fillStyle = l.color;
                    ctx.fillText(l.text, right + 6, py);
                }
            });
            ctx.restore();
        }
    };

    new Chart(ctx, {
        type: 'line',
        plugins: [temperatureBands, temperatureRightLabels],
        data: {
            labels: labels,
            datasets: [
                {
                    data: dataPoints,
                    borderColor: '#7f1d1d', // 선 색상: 진한 빨강
                    borderWidth: 2,
                    tension: 0.1, // 약간 부드럽게
                    fill: false,
                    pointRadius: 4,
                    pointBackgroundColor: '#ffffff', // 포인트 내부 흰색
                    pointBorderColor: '#7f1d1d',     // 포인트 테두리
                    pointBorderWidth: 2
                },
                // 기준선 (점선)
                { data: labels.map(() => 37.3), borderColor: '#f97316', borderWidth: 1, pointRadius: 0, borderDash: [5,5] },
                { data: labels.map(() => 38.0), borderColor: '#ef4444', borderWidth: 1, pointRadius: 0, borderDash: [5,5] },
                { data: labels.map(() => 39.0), borderColor: '#7e22ce', borderWidth: 1, pointRadius: 0, borderDash: [5,5] }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            layout: { padding: { right: 90 } },
            scales: {
                y: {
                    min: 35,
                    max: maxTemp,
                    ticks: {
                        stepSize: 0.5,
                        color: '#64748b', // [중요] 눈금 글씨색 진하게
                        font: { family: 'Pretendard', size: 11 }
                    },
                    grid: { color: '#e2e8f0' } // 격자 선 연하게
                },
                x: {
                    ticks: {
                        autoSkip: true,
                        maxTicksLimit: 6,
                        color: '#64748b', // [중요] 날짜 글씨색 진하게
                        font: { family: 'Pretendard', size: 11 }
                    },
                    grid: { display: false }
                }
            },
            plugins: {
                legend: { display: false }
            }
        }
    });
}