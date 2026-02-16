const BASE_URL = "http://192.168.1.23:8000";  // arkadaşının IP'si

async function loadLeaderboard() {
    try {
        const response = await fetch(`${BASE_URL}/api/leaderboard`);
        const data = await response.json();

        const table = document.getElementById("leaderboard-body");
        table.innerHTML = "";

        data.forEach(row => {
            table.innerHTML += `
                <tr>
                    <td>${row.rank}</td>
                    <td>${row.user_id}</td>
                    <td>${row.total_points}</td>
                </tr>
            `;
        });
    } catch (err) {
        console.error(err);
    }
}

async function loadUsers() {
    try {
        const response = await fetch(`${BASE_URL}/api/users`);
        const data = await response.json();

        const table = document.getElementById("users-body");
        table.innerHTML = "";

        data.forEach(user => {
            table.innerHTML += `
                <tr>
                    <td>${user.user_id}</td>
                    <td>${user.total_points}</td>
                </tr>
            `;
        });
    } catch (err) {
        console.error(err);
    }
}

document.addEventListener("DOMContentLoaded", function () {
    loadLeaderboard();
    loadUsers();
});
