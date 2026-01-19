document.addEventListener("DOMContentLoaded", () => {
    const fab = document.getElementById("chatbot-fab"); //chatbot 둉그라미
    const panel = document.getElementById("chatbot-panel");// 동그라미 패널
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


   // 전역 메시지 API
window.showMessage = function (text, isUser) {
    const box = document.getElementById("chatbot-messages");
    if (!box) return;

    const div = document.createElement("div");
    //사용자,챗봇 구별
    div.className = isUser ? "msg user" : "msg bot";
    div.textContent = (isUser ? "🙋 " : "🤖 ") + text; // -------------------------------------tntntntntntn수정

    box.appendChild(div);
    box.scrollTop = box.scrollHeight;
};

//pressText 버튼 추천 문구 직접 넘길 겨우 사용
window.sendMessage = function (presetText) {
    const input = document.getElementById("chatbotInput");
    const text = presetText ?? input.value.trim();
    if (!text) return;

    //사용자 메시지 즉시 출력
    showMessage(text, true);
    if (input) input.value = "";


    //서버에 메시지 전송
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
            showMessage("서버 오류가 발생했습니다.", false);
        });
};
