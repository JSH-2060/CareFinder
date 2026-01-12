document.addEventListener("DOMContentLoaded", () => {
    const fab = document.getElementById("chatbot-fab");
    const panel = document.getElementById("chatbot-panel");
    const closeBtn = document.getElementById("chatbot-close");
    const sendBtn = document.getElementById("chatbotSendBtn");
    const input = document.getElementById("chatbotInput");

    fab?.addEventListener("click", () => {
        panel.classList.toggle("open");
    });

    closeBtn?.addEventListener("click", () => {
        panel.classList.remove("open");
    });

    sendBtn?.addEventListener("click", () => sendMessage());
    input?.addEventListener("keydown", (e) => {
        if (e.key === "Enter") {
            e.preventDefault();
            sendMessage();
        }
    });
});

/* =========================
   전역 메시지 API
========================= */
window.showMessage = function (text, isUser) {
    const box = document.getElementById("chatbot-messages");
    if (!box) return;

    const div = document.createElement("div");
    div.className = isUser ? "msg user" : "msg bot";
    div.textContent = (isUser ? "🙋 " : "🤖 ") + text;

    box.appendChild(div);
    box.scrollTop = box.scrollHeight;
};

window.sendMessage = function (presetText) {
    const input = document.getElementById("chatbotInput");
    const text = presetText ?? input.value.trim();
    if (!text) return;

    showMessage(text, true);
    if (input) input.value = "";

    fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json; charset=UTF-8" },
        body: JSON.stringify({ message: text })
    })
        .then(res => res.json())
        .then(data => {
            if (data?.message) {
                showMessage(data.message, false);
            }
        })
        .catch(() => {
            showMessage("⚠️ 서버 오류가 발생했습니다.", false);
        });
};
