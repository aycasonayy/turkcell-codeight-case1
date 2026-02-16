// MOCK DATA

const USERS = [
    {
        user_id: "user_1",
        points: 450,
        login_today: 1,
        play_minutes_7d: 720,
        streak: 4
    },
    {
        user_id: "user_2",
        points: 320,
        login_today: 1,
        play_minutes_7d: 300,
        streak: 2
    },
    {
        user_id: "user_3",
        points: 150,
        login_today: 0,
        play_minutes_7d: 100,
        streak: 1
    }
];

export async function getUsers() {
    return USERS;
}

export async function getUserById(id) {
    return USERS.find(u => u.user_id === id);
}
