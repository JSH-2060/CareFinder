function toggleDateSearch() {
    const box = document.getElementById('dateSearchBox');
    box.style.display = (box.style.display === 'none') ? 'block' : 'none';
}

function openBmiEditModal(bmiNo, height, weight) {
    document.getElementById('editBmiNo').value = bmiNo;
    document.getElementById('editHeight').value = height;
    document.getElementById('editWeight').value = weight;

    const modal = new bootstrap.Modal(
        document.getElementById('bmiEditModal')
    );
    modal.show();
}
