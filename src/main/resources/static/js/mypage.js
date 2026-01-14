function goHome() {
    location.href = "/";
}

function confirmWithdraw() {
    return confirm(
        "정말 회원탈퇴 하시겠습니까?\n모든 정보는 복구할 수 없습니다."
    );
}