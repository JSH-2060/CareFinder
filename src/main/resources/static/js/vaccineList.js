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
    const no = row.getAttribute('data-no');
    const name = row.getAttribute('data-name');
    const chasu = row.getAttribute('data-chasu');
    const date = row.getAttribute('data-date');

    document.getElementById('edit_vaccineNo').value = no;
    document.getElementById('edit_vaccineName').value = name;
    document.getElementById('edit_chasu').value = chasu;

    if (date) editPicker.setDate(date);

    new bootstrap.Modal(document.getElementById('editModal')).show();
}


/* =========================================
   3. 차트 그리기 (흰색 배경 대응)
   ========================================= */
function renderVaccineChart(doneCnt, yetCnt) {
    const ctx = document.getElementById('vaccineChart');
    if (!ctx) return;

    new Chart(ctx.getContext('2d'), {
        type: 'doughnut',
        data: {
            labels: ['접종 완료', '미접종'],
            datasets: [{
                data: [doneCnt, yetCnt],
                // 선명한 파랑, 선명한 빨강 (가독성 UP)
                backgroundColor: ['#2563EB', '#EF4444'],
                borderWidth: 0,
                hoverOffset: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '70%',
            plugins: {
                legend: { display: false },
                tooltip: {
                    enabled: true,
                    backgroundColor: 'rgba(30, 41, 59, 0.9)',
                    padding: 12,
                    titleFont: { family: 'Pretendard', size: 13 },
                    bodyFont: { family: 'Pretendard', size: 13 }
                }
            }
        }
    });
}