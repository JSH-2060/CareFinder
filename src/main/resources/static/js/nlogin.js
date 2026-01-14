window.onload = function() {
    // URL 파라미터 확인 (로그인 실패/취소 메시지 처리)
    const urlParams = new URLSearchParams(window.location.search);
    const message = urlParams.get('message');

    if (message === 'canceled') {
        alert("네이버 로그인 동의가 취소되었습니다.");
    } else if (message === 'error') {
        alert("로그인 처리 중 오류가 발생했습니다.");
    }
};