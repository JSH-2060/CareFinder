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
   4. 차트 그리기 (JSP에서 데이터를 받아옴)
   ========================================= */
function renderHeatChart(labels, dataPoints) {
    const ctx = document.getElementById('tempChart').getContext('2d');

    // 동적 Y축 최대값 계산 (40도 넘으면 그래프 확장)
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
                { min: 35.0, max: 36.0, color: 'rgba(148,163,184,0.12)' },
                { min: 37.3, max: 38.0, color: 'rgba(253,186,116,0.14)' },
                { min: 38.0, max: 39.0, color: 'rgba(252,165,165,0.14)' },
                { min: 39.0, max: maxTemp + 2, color: 'rgba(216,180,254,0.14)' }
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

    // [플러그인] 오른쪽 텍스트 라벨
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
            ctx.font = '12px Pretendard, sans-serif';

            const lines = [
                { v: 37.3, text: '37.3℃ · 미열',  color: '#f97316' },
                { v: 38.0, text: '38.0℃ · 고열',  color: '#ef4444' },
                { v: 39.0, text: '39.0℃ · 초고열', color: '#7e22ce' }
            ];

            lines.forEach(l => {
                if (l.v <= scales.y.max && l.v >= scales.y.min) {
                    const py = y.getPixelForValue(l.v);
                    ctx.fillStyle = 'rgba(255,255,255,0.85)';
                    ctx.fillRect(right + 4, py - 8, 95, 16);
                    ctx.fillStyle = l.color;
                    ctx.fillText(l.text, right + 6, py);
                }
            });
            ctx.restore();
        }
    };

    // 차트 생성
    new Chart(ctx, {
        type: 'line',
        plugins: [temperatureBands, temperatureRightLabels],
        data: {
            labels: labels,
            datasets: [
                {
                    data: dataPoints,
                    borderColor: '#7f1d1d',
                    borderWidth: 2,
                    tension: 0,
                    fill: false,
                    pointRadius: 4,
                    pointBackgroundColor: '#7f1d1d',
                    pointBorderWidth: 0
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
            layout: { padding: { right: 110 } },
            scales: {
                y: {
                    min: 35,
                    max: maxTemp,
                    ticks: { stepSize: 0.5 }
                },
                x: {
                    ticks: { autoSkip: true, maxTicksLimit: 6 }
                }
            },
            plugins: {
                legend: { display: false }
            }
        }
    });
}