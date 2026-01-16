// 아이디 중복 체크 통과 여부
let isIdSafe = false;

$(document).ready(function () {

    /* 1. flatpickr 적용 */
    flatpickr(".datepicker", {
        locale: "ko",
        dateFormat: "Y-m-d",
        maxDate: "today",
        disableMobile: true
    });

    /* [중요 추가] 페이지 로딩 시, 서버에서 받아온 아이디가 이미 있다면
       중복 체크를 통과한 것으로 간주 (또는 다시 체크)
    */
    if ($("#id").val().trim() !== "") {
        // 이미 아이디가 입력되어 있다면(에러 후 돌아온 경우 등), 일단 통과 상태로 둠
        // (더 확실하게 하려면 여기서 ajax를 한번 더 호출해도 됩니다)
        isIdSafe = true;
        $(".submit-btn").prop("disabled", false);
    }

    /* 2. 아이디 중복 체크 */
    $("#id").on("keyup", function () {
        const userId = $(this).val().trim();

        if (userId === "") {
            $("#msg").text("");
            isIdSafe = false;
            $(".submit-btn").prop("disabled", true);
            return;
        }

        $.ajax({
            url: "/member/checkId",
            type: "GET",
            data: { id: userId },
            success: function (response) {
                if (response === "1") {
                    $("#msg").html("<span class='txt-red'>이미 사용 중인 아이디입니다.</span>");
                    isIdSafe = false;
                    $(".submit-btn").prop("disabled", true);
                } else {
                    $("#msg").html("<span class='txt-green'>사용 가능한 아이디입니다.</span>");
                    isIdSafe = true;
                    $(".submit-btn").prop("disabled", false);
                }
            },
            error: function () {
                console.error("아이디 중복 체크 에러");
            }
        });
    });

    /* [추가된 부분] 3. 휴대폰 번호 수정 시 에러 메시지 삭제 */
    $('input[name="phonenumber"]').on('input', function() {
        var val = $(this).val();
        // 숫자만 추출
        var onlyNum = val.replace(/[^0-9]/g, '');

        // 010으로 시작하고 11자리가 되면 에러 메시지(.error-msg) 내용을 지움
        if (onlyNum.length === 11 && onlyNum.startsWith('010')) {
            $('.error-msg').text('');
        }
    });

    /* 4. 최종 제출 검사 */
    $("#joinForm").on("submit", function () {
        if (!isIdSafe) {
            alert("아이디 중복 확인을 해주세요.");
            $("#id").focus();
            return false;
        }
        return true;
    });
});