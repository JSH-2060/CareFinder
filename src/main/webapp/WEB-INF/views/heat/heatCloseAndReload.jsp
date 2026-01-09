<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>알림</title>
</head>
<body>
<script>
    // 컨트롤러에서 담아준 메시지를 출력 (없을 경우 기본 저장 멘트)
    var message = "${msg}";
    if (!message) {
        message = "기록이 저장되었습니다.";
    }

    alert(message);

    // 부모창을 새로고침하고 현재 팝업을 닫음
    if (window.opener && !window.opener.closed) {
        window.opener.location.reload();
    }
    window.close();
</script>
</body>
</html>