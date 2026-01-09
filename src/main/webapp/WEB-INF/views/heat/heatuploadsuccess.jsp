<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>저장 완료</title>
</head>
<body>
<script>
    if (window.opener && !window.opener.closed) {
        window.opener.location.href = "/heat/list?ts=" + new Date().getTime();
        window.close();
    } else {
        location.href = "/heat/list";
    }
</script>
</body>
</html>
