/* =========================================
   1. Flatpickr (달력) 초기화
   ========================================= */
const fpConfig = {
    locale: "ko",
    dateFormat: "Y-m-d",
    defaultDate: new Date()
};

const addPicker = flatpickr("#addModal .datepicker", fpConfig);
const editPicker = flatpickr("#editModal .datepicker", fpConfig);


/* =========================================
   2. 수정 모달 열기 함수
   ========================================= */
function openEditModal(row) {
    // data 속성 읽기
    const no = row.getAttribute('data-no');
    const name = row.getAttribute('data-name');
    const chasu = row.getAttribute('data-chasu');
    const date = row.getAttribute('data-date');

    // 모달 폼에 값 채우기
    document.getElementById('edit_vaccineNo').value = no;
    document.getElementById('edit_vaccineName').value = name;
    document.getElementById('edit_chasu').value = chasu;

    // 날짜 설정
    if (date) editPicker.setDate(date);

    // 모달 띄우기
    new bootstrap.Modal(document.getElementById('editModal')).show();
}


/* =========================================
   3. 차트 그리기 (JSP에서 데이터 받음)
   ========================================= */
function renderVaccineChart(doneCnt, yetCnt) {
    const ctx = document.getElementById('vaccineChart');
    if (!ctx) return; // 차트 캔버스가 없으면 종료

    new Chart(ctx.getContext('2d'), {
        type: 'doughnut',
        data: {
            labels: ['접종 완료', '미접종'],
            datasets: [{
                data: [doneCnt, yetCnt],
                backgroundColor: ['#3b82f6', '#fee2e2'], // 파랑, 연한 빨강
                borderWidth: 0,
                hoverOffset: 4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '70%',
            plugins: {
                legend: { display: false },
                tooltip: { enabled: true }
            }
        }
    });
}