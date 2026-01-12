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
        #msg { font-size: 13px; margin-top: 6px; min-height: 20px; }
        .txt-red { color: #ef4444; font-weight: bold; }
        .txt-green { color: #16a34a; font-weight: bold; }
    </style>

    <script type="text/javascript">
        // 중복 체크 통과했는지 확인하는 변수
        let isIdSafe = false;

        $(document).ready(function(){
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
        });

        // 3. 전송 시 최종 확인
        function checkSubmit() {
            if(!isIdSafe) {
                alert("아이디 중복 확인을 해주세요.");
                $("#id").focus();
                return false; // 전송 막음
            }
            return true; // 전송
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
            <input type="text" name="name" required>
        </div>

        <div class="form-group">
            <label>생년월일</label>
            <input type="text" name="birth" class="datepicker" placeholder="날짜를 선택하세요" required style="background-color: white;">
        </div>

        <div class="form-group">
            <label>이메일</label>
            <div class="inline-group">
                <input type="text" name="emailId" placeholder="이메일 아이디">
                <select name="emailDomain">
                    <option value="@naver.com">@naver.com</option>
                    <option value="@gmail.com">@gmail.com</option>
                    <option value="@daum.net">@daum.net</option>
                </select>
            </div>
        </div>

        <div class="form-group">
            <label>성별</label>
            <select name="gender">
                <option value="male">남</option>
                <option value="female">여</option>
            </select>
        </div>

        <div class="form-group">
            <label>전화번호</label>
            <input type="text" name="phonenumber" placeholder="010-0000-0000">
        </div>

        <button type="submit" class="submit-btn" disabled>회원가입</button>

    </form>
</div>

</body>
</html>