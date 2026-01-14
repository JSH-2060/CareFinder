// =========================
// 로그인 여부 (JSP에서 주입)
// =========================
// const isLoggedIn = true / false;

/* =========================
   모달 공통
========================= */
window.onclick = function (e) {
    if (e.target.classList.contains('modal')) {
        e.target.style.display = "none";
    }
};

function openModal(id) {
    document.getElementById(id).style.display = 'flex';
}

function closeModal(id) {
    document.getElementById(id).style.display = 'none';
}

/* =========================
   병원 / 진료과
========================= */
function openDeptModal() {
    closeModal('hospitalModal');
    openModal('departmentModal');
}

function goMap(typeVal) {
    let url = '/map?mode=hospital';
    if (typeVal) {
        url += '&type=' + encodeURIComponent(typeVal);
    }
    location.href = url;
}

/* =========================
   건강관리 로그인 체크
========================= */
function checkLoginAndOpenHealth() {
    if (isLoggedIn) {
        openModal('healthModal');
    } else {
        alert("로그인이 필요한 서비스입니다.");
        location.href = '/Nologin';
    }
}

/* =========================
   유저 드롭다운
========================= */
function toggleUserMenu() {
    const menu = document.getElementById('userDropdown');
    menu.style.display = menu.style.display === 'flex' ? 'none' : 'flex';
}

window.addEventListener('click', function (e) {
    const menu = document.getElementById('userDropdown');
    if (!e.target.closest('.user-menu')) {
        if (menu) menu.style.display = 'none';
    }
});
