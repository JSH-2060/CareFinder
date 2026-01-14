// Flatpickr (달력) 초기화
flatpickr(".datepicker", {
    locale: "ko",       // 한국어 설정
    dateFormat: "Y-m-d", // 날짜 형식
    maxDate: "today"    // 미래 날짜 선택 불가 (생일이니까)
});