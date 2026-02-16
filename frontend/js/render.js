import { getUsers } from "./api.js";

async function renderLeaderboard() {
    const container = document.getElementById("leaderboard");
    if (!container) return;

    const users = await getUsers();

    const sorted = [...users].sort((a, b) => b.points - a.points);

    container.innerHTML = "";

    sorted.forEach((user, index) => {
        container.innerHTML += `
            <div class="card">
                <strong>#${index + 1}</strong><br>
                ${user.user_id}<br>
                ${user.points} Points
            </div>
        `;
    });
}

async function renderUsers() {
    const container = document.getElementById("users");
    if (!container) return;

    const users = await getUsers();
    container.innerHTML = "";

    users.forEach(user => {
        container.innerHTML += `
            <div class="card" onclick="goToUser('${user.user_id}')" style="cursor:pointer;">
                ${user.user_id}
            </div>
        `;
    });
}

window.goToUser = function(userId) {
    window.location.href = "user.html?user=" + userId;
};

renderLeaderboard();
renderUsers();
