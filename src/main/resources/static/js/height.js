function toggleDateSearch() {
    const box = document.getElementById('dateSearchBox');
    box.style.display = (box.style.display === 'none') ? 'block' : 'none';
}

function openHeightEditModal(id, height, date) {
    document.getElementById('editHeightId').value = id;
    document.getElementById('editHeight').value = height;
    document.getElementById('editRecordDate').value = date;

    const modal = new bootstrap.Modal(
        document.getElementById('heightEditModal')
    );
    modal.show();
}

// 키 입력 모달: 최근 키 자동 세팅
const heightModal = document.getElementById('heightModal');
if (heightModal) {
    heightModal.addEventListener('show.bs.modal', function () {
        const last = document.getElementById('latestHeightValue').value;
        const input = document.getElementById('heightInput');

        if (last && !input.value) {
            input.value = last;
        }
    });
}
document.addEventListener("DOMContentLoaded", function() {
    flatpickr(".datepicker", {
        enableTime: true,       // 시간 선택 활성화
        dateFormat: "Y-m-d", // 날짜 형식 (예: 2026-01-16 14:47)
        time_24hr: true,        // 24시간제 사용
        locale: "ko",           // 한국어 설정
        defaultDate: new Date() // 기본값: 현재 시간
    });
});
