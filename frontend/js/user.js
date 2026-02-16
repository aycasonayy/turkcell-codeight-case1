function getUserIdFromUrl() {
    const params = new URLSearchParams(window.location.search);
    return params.get("user_id");
}

async function loadUserDetail() {
    const userId = getUserIdFromUrl();

    if (!userId) return;

    try {
        const response = await fetch(`http://127.0.0.1:8000/api/users`);
        const data = await response.json();

        const user = data.find(u => u.user_id === userId);

        if (!user) return;

        document.getElementById("user-id").innerText = user.user_id;
        document.getElementById("user-points").innerText = user.total_points;

    } catch (error) {
        console.error("User detail error:", error);
    }
}

document.addEventListener("DOMContentLoaded", loadUserDetail);
