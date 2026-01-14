/**
 * 자녀 프로필 삭제 함수
 * @param {Event} e - 클릭 이벤트 객체
 * @param {number} childId - 자녀 ID
 * @param {string} childName - 자녀 이름
 */
function deleteChild(e, childId, childName) {
    // 이벤트 전파 방지 (혹시 모를 카드 클릭 이벤트 간섭 차단)
    e.preventDefault();
    e.stopPropagation();

    if (confirm("정말 '" + childName + "' 프로필을 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.")) {
        // 삭제 컨트롤러로 이동
        location.href = '/child/delete?childId=' + childId;
    }
}