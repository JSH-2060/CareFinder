document.addEventListener("DOMContentLoaded", function() {

    // 1. 오늘 날짜 구하기
    const today = new Date();

    // 2. 만 나이 120세 제한
    const minDate = new Date();
    minDate.setFullYear(today.getFullYear() - 120);

    // 3. 달력 설정
    flatpickr(".datepicker", {
        locale: "ko",        // 한국어
        dateFormat: "Y-m-d", // 날짜 형식
        maxDate: "today",    // 미래 날짜 선택 불가
        minDate: minDate,    // 오늘 기준 120년 전까지만 선택 가능
        allowInput: false    // 직접 타이핑 방지
    });

});