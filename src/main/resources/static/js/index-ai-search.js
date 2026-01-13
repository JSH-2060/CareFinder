document.addEventListener("DOMContentLoaded", () => {
    const input = document.getElementById("aiSearchInput");
    const btn = document.getElementById("aiSearchBtn");

    if (!input) return;

    const handleSearch = async () => {
        const message = input.value.trim();
        if (!message) return;

        console.log("✅ 검색 시작:", message);

        try {
            const res = await fetch("/api/chat", {
                method: "POST",
                headers: { "Content-Type": "application/json; charset=UTF-8" },
                body: JSON.stringify({ message })
            });

            const data = await res.json();
            console.log("🤖 AI 응답:", data);

            // 1️⃣ 사용자가 입력한 증상 저장
            sessionStorage.setItem("symptom", message);

            // 2️⃣ AI 설명 저장 (map 챗봇에서 표시용)
            if (data.message) {
                sessionStorage.setItem("chatbotIntroMessage", data.message);
            }

            // 자동 클릭 플래그 저장
            sessionStorage.setItem("isAiSearch", "true");

            /* =========================
               이동 로직
            ========================= */
            if (data.action === "MOVE_EMERGENCY") {
                location.href = "/map?mode=emergency";
                return;
            }

            if (data.action === "MOVE_VET") {
                location.href = "/map?mode=vet";
                return;
            }

            if (data.action === "MOVE_MAP" && data.dept) {
                location.href = `/map?mode=hospital&type=${encodeURIComponent(data.dept)}`;
                return;
            }

        } catch (e) {
            console.error(e);
            alert("AI 분석 실패");
        }
    };

    input.addEventListener("keydown", e => {
        if (e.key === "Enter") handleSearch();
    });

    btn?.addEventListener("click", handleSearch);
});
