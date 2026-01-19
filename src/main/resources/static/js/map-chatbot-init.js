document.addEventListener("DOMContentLoaded", () => {
    const symptom = sessionStorage.getItem("symptom");

    //챗봇 처음 열릴때 보여주는 메시지
    const intro = sessionStorage.getItem("chatbotIntroMessage");

    if (!symptom && !intro) return;

    const panel = document.getElementById("chatbot-panel");
    panel?.classList.add("open");//패널 자동으로 열기

    //ui 오픈 애니메이션 자연스럽게 보이도록 지연시간
    setTimeout(() => {
        if (symptom) showMessage(symptom, true); // 🙋 사용자 증상
        if (intro) showMessage(intro, false);   // 🤖 AI 설명

    }, 300);


    sessionStorage.removeItem("symptom");
    sessionStorage.removeItem("chatbotIntroMessage");
});
