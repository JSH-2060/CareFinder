<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/material_blue.css">
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
    <script src="https://npmcdn.com/flatpickr/dist/l10n/ko.js"></script>

    <style>
        * { box-sizing: border-box; font-family: 'Pretendard', sans-serif; }
        body { margin: 0; height: 100vh; background: #F8FAFC; display: flex; justify-content: center; align-items: center; }
        .register-box { width: 520px; background: white; border-radius: 20px; padding: 40px 36px; box-shadow: 0 20px 40px rgba(0,0,0,0.15); }
        .register-box h2 { text-align: center; margin-bottom: 10px; font-size: 26px; }
        .register-box p.desc { text-align: center; color: #64748B; font-size: 14px; margin-bottom: 30px; }
        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; font-size: 14px; font-weight: 600; margin-bottom: 6px; }
        .form-group input, .form-group select { width: 100%; height: 46px; border-radius: 10px; border: 1px solid #CBD5E1; padding: 0 14px; font-size: 14px; background: #fff; }
        .form-group input:focus { outline: none; border-color: #2563EB; }
        .inline-group { display: flex; gap: 10px; }

        /* 버튼 스타일 */
        .submit-btn { width: 100%; height: 48px; border-radius: 12px; border: none; background: #1E3A8A; color: white; font-size: 16px; font-weight: 600; cursor: pointer; margin-top: 10px; transition: 0.3s; }
        .submit-btn:hover { background: #1D4ED8; }
        .submit-btn:disabled { background: #94a3b8; cursor: not-allowed; } /* 비활성화 스타일 */

        /* 메시지 스타일 */
        #msg, #nameMsg { font-size: 13px; margin-top: 6px; min-height: 20px; }
        .txt-red { color: #ef4444; font-weight: bold; }
        .txt-green { color: #16a34a; font-weight: bold; }

        /* 필수 입력 에러 스타일 */
        .input-error {
            border: 1.5px solid #fca5a5 !important; /* 옅은 빨강 */
            animation: shake 0.25s ease-in-out;
        }
    </style>

    <script type="text/javascript">
        // 중복 체크 통과했는지 확인하는 변수
        let isIdSafe = false;

        $(document).ready(function(){
            // 입력하면 에러 스타일 제거
            $("input, select").on("input change", function () {
                $(this).removeClass("input-error");
            });

            // 1. 달력 적용 (생년월일)
            flatpickr(".datepicker", {
                locale: "ko",
                dateFormat: "Y-m-d",
                maxDate: "today", // 미래 날짜 선택 불가
                disableMobile: "true"
            });

            // 2. 아이디 입력 감지 (키보드 뗄 때마다 실행)
            $("#id").on("keyup", function(){
                let userId = $(this).val().trim();

                // 빈칸이면 메시지 지우고 버튼 잠금
                if(userId === "") {
                    $("#msg").text("");
                    isIdSafe = false;
                    $(".submit-btn").prop("disabled", true);
                    return;
                }

                // AJAX로 서버에 물어보기
                $.ajax({
                    url: "/member/checkId", // 아까 만든 컨트롤러 주소
                    type: "GET",
                    data: { id: userId },
                    success: function(response) {
                        if(response === "1") {
                            // 중복 (서버가 1을 줌)
                            $("#msg").html("<span class='txt-red'>이미 사용 중인 아이디입니다.</span>");
                            isIdSafe = false;
                            $(".submit-btn").prop("disabled", true); // 버튼 잠금
                        } else {
                            // 사용 가능 (서버가 0을 줌)
                            $("#msg").html("<span class='txt-green'>사용 가능한 아이디입니다.</span>");
                            isIdSafe = true;
                            $(".submit-btn").prop("disabled", false); // 버튼 풀림
                        }
                    },
                    error: function() {
                        console.log("에러 발생");
                    }
                });
            });

            let isComposing = false;
            // 한글 입력 조합 시작
            $("#name").on("compositionstart", function () {
                isComposing = true;
                $("#nameMsg").html(""); // ✅ 한글 입력 시작 시 경고 즉시 제거
            });

            // 한글 입력 조합 종료
            $("#name").on("compositionend", function () {
                isComposing = false;
                validateName($(this));
            });

            // 일반 입력 처리
            $("#name").on("input", function () {
                if (isComposing) return; // 한글 조합 중이면 검사 안 함
                validateName($(this));
            });

            // 이름 검증 함수
            function validateName($input) {
                let value = $input.val();

                // 공백이면 경고 제거
                if (value.trim() === "") {
                    $("#nameMsg").html("");
                    return;
                }

                let koreanOnly = value.replace(/[^가-힣ㄱ-ㅎㅏ-ㅣ]/g, "");

                // 영어/숫자/특수문자 입력 시: 제거 + 경고
                if (value !== koreanOnly) {
                    $input.val(koreanOnly);
                    $("#nameMsg").html("<span class='txt-red'>숫자나 영어는 입력할 수 없어요!</span>");
                } else {
                    $("#nameMsg").html("");
                }
            }

            // ✅ 전화번호 한글 입력 방지 (숫자 유지)
            let isPhoneComposing = false;

            // 한글 조합 시작
            $("input[name='phonenumber']").on("compositionstart", function () {
                isPhoneComposing = true;
            });

            // 한글 조합 종료
            $("input[name='phonenumber']").on("compositionend", function () {
                isPhoneComposing = false;
                filterPhoneNumber($(this));
            });

            // 일반 입력 처리
            $("input[name='phonenumber']").on("input", function () {
                if (isPhoneComposing) return; // 🔥 한글 조합 중이면 아무 것도 안 함
                filterPhoneNumber($(this));
            });

            // 숫자만 남기는 함수
            function filterPhoneNumber($input) {
                let value = $input.val();

                // 숫자만 허용
                value = value.replace(/[^0-9]/g, "");

                // 최대 11자리
                if (value.length > 11) {
                    value = value.slice(0, 11);
                }

                $input.val(value);
            }

        });

        // 3. 전송 시 최종 확인
        function checkSubmit() {
            let isValid = true;

            // 모든 input, select 중 required만 검사
            $("input[required], select[required]").each(function () {
                let $field = $(this);

                if ($field.val().trim() === "") {
                    isValid = false;

                    // 에러 스타일
                    $field.removeClass("input-error");
                    void $field[0].offsetWidth; // reflow
                    $field.addClass("input-error");
                }
            });

            if (!isValid) {
                return false; // 하나라도 비어 있으면 제출 막기
            }

            // 아이디 중복 체크도 포함
            if (!isIdSafe) {
                alert("아이디 중복 확인을 해주세요.");
                $("#id").focus();
                return false;
            }
            return true;
        }
    </script>
</head>

<body>

<div class="register-box">

    <h2>회원가입</h2>
    <p class="desc">간단한 정보 입력으로 회원가입을 진행하세요</p>

    <form action="/member/join" method="post" onsubmit="return checkSubmit()">

        <div class="form-group">
            <label>아이디</label>
            <input type="text" name="id" id="id" required placeholder="아이디를 입력하세요">
            <div id="msg"></div>
        </div>

        <div class="form-group">
            <label>비밀번호</label>
            <input type="password" name="pw" required>
        </div>

        <div class="form-group">
            <label>이름</label>
            <input type="text" name="name" id="name" required>
            <div id="nameMsg"></div>
        </div>

        <div class="form-group">
            <label>생년월일</label>
            <input type="text" name="birth" class="datepicker" placeholder="날짜를 선택하세요" style="background-color: white;" required>
        </div>

        <div class="form-group">
            <label>이메일</label>
            <div class="inline-group">
                <input type="text" name="emailId" placeholder="이메일 아이디" required>
                <select name="emailDomain">
                    <option value="@naver.com">@naver.com</option>
                    <option value="@gmail.com">@gmail.com</option>
                    <option value="@daum.net">@daum.net</option>
                </select>
            </div>
        </div>

        <div class="form-group">
            <label>성별</label>
            <select name="gender" required>
                <option value="male">남</option>
                <option value="female">여</option>
            </select>
        </div>

        <div class="form-group">
            <label>전화번호</label>
            <input type="text" name="phonenumber" placeholder="'-' 없이 입력해주세요." required>
        </div>

        <button type="submit" class="submit-btn" disabled>회원가입</button>

    </form>
</div>

</body>
</html>