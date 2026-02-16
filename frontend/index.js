document.addEventListener("DOMContentLoaded", () => {
    loadLeaderboard();
    loadUsers();
});

async function loadLeaderboard() {
    try {
        const res = await fetch("http://localhost:5000/api/leaderboard");
        const data = await res.json();

        const table = document.getElementById("leaderboard-body");
        table.innerHTML = "";

        data.forEach(row => {
            table.innerHTML += `
                <tr>
                    <td>${row.rank}</td>
                    <td>
                        <a href="user.html?user_id=${row.user_id}">
                            ${row.user_id}
                        </a>
                    </td>
                    <td>${row.total_points}</td>
                </tr>
            `;
        });

    } catch (err) {
        console.error("Leaderboard error:", err);
    }
}

async function loadUsers() {
    try {
        const res = await fetch("http://localhost:5000/api/users");
        const data = await res.json();

        const table = document.getElementById("users-body");
        table.innerHTML = "";

        data.forEach(user => {
            table.innerHTML += `
                <tr>
                    <td>
                        <a href="user.html?user_id=${user.user_id}">
                            ${user.user_id}
                        </a>
                    </td>
                    <td>${user.total_points}</td>
                    <td>🔥 ${user.streak || 0}</td>
                </tr>
            `;
        });

    } catch (err) {
        console.error("Users error:", err);
    }
}
