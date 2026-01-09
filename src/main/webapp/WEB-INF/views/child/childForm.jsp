<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>${empty child ? '대상 추가' : '정보 수정'}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        /* 배경 통일: 밝은 블루+퍼플 파스텔 */
        body {
            background: linear-gradient(120deg, #e0c3fc 0%, #8ec5fc 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Pretendard', sans-serif;
            margin: 0;
        }

        .glass-container {
            background: rgba(255, 255, 255, 0.55); /* 더 밝고 투명하게 */
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.8);
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.1);
            padding: 40px;
            width: 100%;
            max-width: 500px;
        }

        .page-title {
            text-align: center;
            font-weight: 800;
            color: #444; /* 가독성을 위해 진한 회색 */
            margin-bottom: 30px;
        }

        .form-label { font-weight: 700; color: #555; }

        /* 인풋창 스타일: 흰색 배경에 깔끔하게 */
        .form-control {
            background: rgba(255, 255, 255, 0.7);
            border: 1px solid rgba(255, 255, 255, 0.5);
            color: #333;
        }
        .form-control:focus {
            background: white;
            border-color: #8ec5fc;
            box-shadow: 0 0 0 3px rgba(142, 197, 252, 0.3);
            color: #333;
        }

        /* 버튼 스타일 */
        .btn-primary-custom {
            background: #6a93cb; /* 파스텔톤 블루 */
            background-image: linear-gradient(315deg, #6a93cb 0%, #74ebd5 74%);
            border: none;
            color: white;
            font-weight: bold;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .btn-primary-custom:hover {
            background: #5b84bc;
            transform: translateY(-2px);
            color: white;
        }

        .btn-danger-custom {
            background: #ff9a9e;
            border: none;
            color: white;
            font-weight: bold;
        }
        .btn-danger-custom:hover { background: #ff7e83; color: white; }

        .btn-check:checked + .btn-outline-primary {
            background-color: #6a93cb;
            border-color: #6a93cb;
            color: white;
        }
        .btn-outline-primary {
            color: #6a93cb;
            border-color: #6a93cb;
        }
    </style>
</head>
<body>

<div class="glass-container">
    <h3 class="page-title">
        ${empty child ? '새로운 대상 추가' : '정보 수정'}
    </h3>

    <form action="${empty child ? '/child/add' : '/child/update'}" method="post">

        <c:if test="${not empty child}">
            <input type="hidden" name="childId" value="${child.childId}">
        </c:if>

        <div class="mb-3">
            <label class="form-label">이름</label>
            <input type="text" name="childName" class="form-control form-control-lg"
                   placeholder="이름 입력" value="${child.childName}" required>
        </div>

        <div class="mb-3">
            <label class="form-label">생년월일</label>
            <input type="date" name="birth" class="form-control form-control-lg"
                   value="${child.birth}" required>
        </div>

        <div class="mb-4">
            <label class="form-label">성별</label>
            <div class="d-flex gap-2">
                <input type="radio" class="btn-check" name="gender" id="male" value="M"
                ${empty child or child.gender == 'M' ? 'checked' : ''}>
                <label class="btn btn-outline-primary w-100 py-2" for="male">남성</label>

                <input type="radio" class="btn-check" name="gender" id="female" value="F"
                ${child.gender == 'F' ? 'checked' : ''}>
                <label class="btn btn-outline-primary w-100 py-2" for="female">여성</label>
            </div>
        </div>

        <div class="d-grid gap-2">
            <c:choose>
                <c:when test="${empty child}">
                    <button type="submit" class="btn btn-primary-custom py-3 rounded-3">
                        등록하기
                    </button>
                </c:when>
                <c:otherwise>
                    <button type="submit" class="btn btn-primary-custom py-2 rounded-3">
                        수정 내용 저장
                    </button>
                    <button type="button" class="btn btn-danger-custom py-2 rounded-3"
                            onclick="deleteChild('${child.childId}')">
                        삭제하기
                    </button>
                </c:otherwise>
            </c:choose>

            <a href="/heat/select" class="btn btn-link text-secondary text-decoration-none mt-2">취소</a>
        </div>
    </form>
</div>

<script>
    function deleteChild(childId) {
        if (confirm("정말 삭제하시겠습니까?\n모든 기록이 삭제됩니다.")) {
            location.href = '/child/delete?childId=' + childId;
        }
    }
</script>

</body>
</html>