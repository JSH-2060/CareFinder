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

// 키 입력 모달
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
        enableTime: true,
        dateFormat: "Y-m-d",
        time_24hr: true,
        locale: "ko",
        defaultDate: new Date()
    });
});
