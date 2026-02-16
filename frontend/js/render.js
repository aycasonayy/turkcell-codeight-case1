export function renderLeaderboard(data) {
    const tbody = document.querySelector("#leaderboardTable tbody");
    tbody.innerHTML = "";

    data.slice(0, 10).forEach(row => {
        tbody.innerHTML += `
            <tr>
                <td>${row.rank}</td>
                <td>${row.user_id}</td>
                <td>${row.total_points}</td>
            </tr>
        `;
    });
}

export function renderUsers(users) {
    const tbody = document.querySelector("#usersTable tbody");
    tbody.innerHTML = "";

    users.forEach(user => {
        tbody.innerHTML += `
            <tr onclick="window.location.href='user.html?user_id=${user.user_id}'">
                <td>${user.user_id}</td>
                <td>${user.total_points || 0}</td>
                <td>🔥 ${user.streak || 0}</td>
            </tr>
        `;
    });
}
