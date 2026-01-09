<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>

    <style>
        * {
            box-sizing: border-box;
            font-family: 'Pretendard', 'Apple SD Gothic Neo', Arial, sans-serif;
        }

        body {
            margin: 0;
            height: 100vh;
            background: #F8FAFC;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .register-box {
            width: 520px;
            background: white;
            border-radius: 20px;
            padding: 40px 36px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
        }

        .register-box h2 {
            text-align: center;
            margin-bottom: 10px;
            font-size: 26px;
        }

        .register-box p.desc {
            text-align: center;
            color: #64748B;
            font-size: 14px;
            margin-bottom: 30px;
        }

        .form-group {
            margin-bottom: 18px;
        }

        .form-group label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 6px;
        }

        .form-group input,
        .form-group select {
            width: 100%;
            height: 46px;
            border-radius: 10px;
            border: 1px solid #CBD5E1;
            padding: 0 14px;
            font-size: 14px;
        }

        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #2563EB;
        }

        .inline-group {
            display: flex;
            gap: 10px;
        }

        .inline-group input,
        .inline-group select {
            flex: 1;
        }

        .submit-btn {
            width: 100%;
            height: 48px;
            border-radius: 12px;
            border: none;
            background: #1E3A8A;
            color: white;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 10px;
        }

        .submit-btn:hover {
            background: #1D4ED8;
        }

        #msg {
            font-size: 13px;
            margin-top: 6px;
        }
    </style>

    <script type="text/javascript">
        $(function(){
            $("#id").on("keyup", checkup);
        });

        async function checkup(){
            let txt = $("#id").val().trim();
            if(txt === ''){
                $("#msg").html('');
                return;
            }

            const response = await fetch('idCheck.jsp?id=' + txt);
            const data = await response.text();

            if(data.trim() === "1"){
                $("#msg").html("<span style='color:red'>이미 사용 중인 아이디입니다.</span>");
            }else{
                $("#msg").html("<span style='color:green'>사용 가능한 아이디입니다.</span>");
            }
        }
    </script>

</head>

<body>

<div class="register-box">

    <h2>회원가입</h2>
    <p class="desc">간단한 정보 입력으로 회원가입을 진행하세요</p>

    <form action="/member/join" method="post">

        <div class="form-group">
            <label>아이디</label>
            <input type="text" name="id" id="id" required>
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
            <input type="date" name="birth">
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
            <input type="text" name="phonenumber" placeholder="- 없이 입력해주세요">
        </div>

        <button type="submit" class="submit-btn">회원가입</button>

    </form>
</div>

</body>
</html>
