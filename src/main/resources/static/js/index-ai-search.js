document.addEventListener("DOMContentLoaded", () => {
    const input = document.getElementById("aiSearchInput");
    const btn = document.getElementById("aiSearchBtn");

    if (!input) {
        console.error("❌ aiSearchInput 없음");
        return;
    }

    // 🔥 핵심 함수 (Enter / 버튼 공용)
    const handleSearch = async () => {
        const message = input.value.trim();

        if (!message) {
            alert("증상을 입력해주세요");
            return;
        }

        console.log("✅ 검색 시작:", message);

        try {
            const res = await fetch("/api/chat", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ message })
            });

            const data = await res.json();

            console.log("✅ AI 응답:", data);

            // 1️⃣ 챗봇 메시지 출력
            if (window.chatbot?.showMessage) {
                window.chatbot.showMessage(data.message);
            }

            // 2️⃣ 이동 로직 (🔥 여기 중요)
            if (data.action === "MOVE_EMERGENCY") {
                console.log("➡ 응급실 이동");
                location.href = "/map?mode=emergency";
                return;
            }

            if (data.action === "MOVE_VET") {
                console.log("➡ 동물병원 이동");
                location.href = "/map?mode=vet";
                return;
            }

            if (data.action === "MOVE_MAP" && data.dept) {
                console.log("➡ 병원 이동:", data.dept);
                location.href =
                    `/map?mode=hospital&type=${encodeURIComponent(data.dept)}`;
                return;
            }

            console.warn("⚠ 이동 조건 불충족:", data);

        } catch (err) {
            console.error("❌ AI 요청 실패", err);
            alert("AI 분석 중 오류가 발생했습니다");
        }
    };

    // ✅ Enter 키
    input.addEventListener("keydown", (e) => {
        if (e.key === "Enter") {
            e.preventDefault();
            handleSearch();
        }
    });

    // ✅ 검색 버튼
    if (btn) {
        btn.addEventListener("click", (e) => {
            e.preventDefault();
            handleSearch();
        });
    } else {
        console.error("❌ aiSearchBtn 없음");
    }
});
