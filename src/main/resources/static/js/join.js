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

    /* 3. 최종 제출 검사 */
    $("#joinForm").on("submit", function () {
        if (!isIdSafe) {
            alert("아이디 중복 확인을 해주세요.");
            $("#id").focus();
            return false;
        }
        return true;
    });
});
