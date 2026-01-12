document.addEventListener("DOMContentLoaded", () => {
    const symptom = sessionStorage.getItem("symptom");
    const intro = sessionStorage.getItem("chatbotIntroMessage");

    if (!symptom && !intro) return;

    const panel = document.getElementById("chatbot-panel");
    panel?.classList.add("open");

    setTimeout(() => {
        if (symptom) showMessage(symptom, true); // 🙋 사용자 증상
        if (intro) showMessage(intro, false);   // 🤖 AI 설명

    }, 300);

    // ✅ 한 번 보여주고 제거 (중복 방지)
    sessionStorage.removeItem("symptom");
    sessionStorage.removeItem("chatbotIntroMessage");
});
