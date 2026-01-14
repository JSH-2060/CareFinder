document.addEventListener("DOMContentLoaded", () => {
    const socialButtons = document.querySelectorAll(".social-btn");

    socialButtons.forEach(btn => {
        btn.addEventListener("click", () => {
            const url = btn.dataset.url;
            if (url) {
                location.href = url;
            }
        });
    });
});
