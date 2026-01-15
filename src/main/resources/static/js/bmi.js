/* =========================
   날짜 검색 토글
   ========================= */
function toggleDateSearch() {
    const box = document.getElementById('dateSearchBox');
    if (!box) return;

    box.style.display = (box.style.display === 'none' || box.style.display === '')
        ? 'block'
        : 'none';
}

/* =========================
   BMI 수정 모달
   ========================= */
function openBmiEditModal(bmiNo, height, weight) {
    const bmiNoInput = document.getElementById('editBmiNo');
    const heightInput = document.getElementById('editHeight');
    const weightInput = document.getElementById('editWeight');
    const modalEl = document.getElementById('bmiEditModal');

    if (!bmiNoInput || !heightInput || !weightInput || !modalEl) return;

    bmiNoInput.value = bmiNo;
    heightInput.value = height;
    weightInput.value = weight;

    const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
    modal.show();
}

/* =========================
   브랜드 헤더 스크롤 처리
   ========================= */
(function () {
    const header = document.querySelector('.brand-header');
    if (!header) return;

    let ticking = false;

    window.addEventListener('scroll', () => {
        if (!ticking) {
            window.requestAnimationFrame(() => {
                header.classList.toggle('scrolled', window.scrollY > 20);
                ticking = false;
            });
            ticking = true;
        }
    });
})();
