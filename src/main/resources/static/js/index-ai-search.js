document.addEventListener("DOMContentLoaded", () => {
    const input = document.getElementById("aiSearchInput");
    const btn = document.getElementById("aiSearchBtn");
    const toast = document.getElementById("toast");

    if (!input) return;

    const showToast = (message) => {
        if (!toast) return;
        toast.textContent = message;
        toast.classList.add("show");

        setTimeout(() => {
            toast.classList.remove("show");
        }, 3500);
    };

    const handleSearch = async () => {
        const message = input.value.trim();

        //  입력 안 했을 때
        if (!message) {
            showToast("증상을 통해 쉽고 빠르게 근처 병원을 안내해드리는 검색창입니다. 증상을 입력해주세요. ");
            input.focus();
            return;
        }

        console.log("🔍 검색 시작:", message);

        try {
            const res = await fetch("/api/chat", {
                method: "POST",
                headers: { "Content-Type": "application/json; charset=UTF-8" },
                body: JSON.stringify({ message })
            });

            const data = await res.json();
            console.log(" AI 응답:", data);

            /* =========================
               사용자 입력 / 챗봇 메시지 저장
            ========================= */
            // 1️⃣ 사용자가 입력한 증상 저장
            sessionStorage.setItem("symptom", message);

            if (data.summary) {
                sessionStorage.setItem("chatbotIntroMessage", data.summary);
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

            /* =========================
               ❗ 증상 아님 → toast 피드백
            ========================= */
            showToast(data.summary || "증상을 통해 쉽고 빠르게 근처 병원을 안내해드리는 검색창입니다. 증상을 입력해주세요. Q&A 궁금하신점은 우측 하단 챗봇을 이용해주세요!");

        } catch (e) {
            console.error(e);
            showToast("AI 분석에 실패했어요. 잠시 후 다시 시도해주세요.");
        }
    };

    input.addEventListener("keydown", e => {
        if (e.key === "Enter") handleSearch();
    });

    btn?.addEventListener("click", handleSearch);
});
