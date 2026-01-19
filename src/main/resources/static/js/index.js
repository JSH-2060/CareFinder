// 1. 모달 닫기 (배경 클릭 시)
window.onclick = function(e) {
    if(e.target.classList.contains('modal')) {
        e.target.style.display = "none";
    }
}

// 2. 모달 열기/닫기 공통 함수
function openModal(id) { document.getElementById(id).style.display = 'flex'; }
function closeModal(id) { document.getElementById(id).style.display = 'none'; }

// 3. 진료과 모달 스위칭 (병원 모달 -> 진료과 모달)
function openDeptModal() {
    closeModal('hospitalModal');
    openModal('departmentModal');
}

// 4. 지도 페이지 이동
function goMap(typeVal) {
    let url = '/map?mode=hospital';
    if(typeVal) {
        url += '&type=' + encodeURIComponent(typeVal);
    }
    location.href = url;
}

// 5. 건강관리 접근 제어 (isLoggedIn 변수는 index.jsp에서 정의됨)
function checkLoginAndOpenHealth() {
    if(typeof isLoggedIn !== 'undefined' && isLoggedIn) {
        openModal('healthModal');
    } else {
        if(confirm("로그인이 필요한 서비스입니다. 로그인 하시겠습니까?")){
            location.href = '/Nologin';
        }
    }
}

// 6. 챗봇 연결 로직
function connectChatbotToggle() {
    if (typeof toggleChatWindow === 'function') {
        toggleChatWindow();
        return;
    }

    const chatContainer = document.getElementById('chat-container') ||
        document.getElementById('chatbot-container') ||
        document.querySelector('.chat-window');
    if (chatContainer) {
        const currentDisplay = window.getComputedStyle(chatContainer).display;
        chatContainer.style.display = (currentDisplay === 'none') ? 'flex' : 'none';
    }
}

// 7. 유저 메뉴 토글
function toggleUserMenu() {
    const menu = document.getElementById('userDropdown');
    menu.style.display = menu.style.display === 'flex' ? 'none' : 'flex';
}

// 8. 이벤트 리스너: 메뉴 바깥 클릭 시 닫기
window.addEventListener('click', function(e) {
    const menu = document.getElementById('userDropdown');
    if (!e.target.closest('.user-menu')) {
        if(menu) menu.style.display = 'none';
    }
});

// 9. 초기화: 기존 챗봇 버튼 강제 숨김
window.addEventListener('DOMContentLoaded', () => {
    const potentialOldButtons = document.querySelectorAll('.chatbot-launcher, #chatbot-launcher, .chatbot-btn');
    potentialOldButtons.forEach(btn => btn.style.display = 'none');
});