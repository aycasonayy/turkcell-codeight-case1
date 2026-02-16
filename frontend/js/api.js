export async function fetchUsers() {
    const res = await fetch("/data/users.json");
    return await res.json();
}

export async function fetchLeaderboard() {
    const res = await fetch("/data/leaderboard.json");
    return await res.json();
}

export async function fetchUserById(userId) {
    const users = await fetchUsers();
    return users.find(u => u.user_id === userId);
}
