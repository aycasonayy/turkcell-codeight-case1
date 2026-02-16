import { getUserById } from "./api.js";

function getUserIdFromUrl() {
    const params = new URLSearchParams(window.location.search);
    return params.get("user");
}

function renderUser(user) {
    const container = document.getElementById("user-detail");
    if (!container) return;

    container.innerHTML = `
        <div class="card">
            <strong>User:</strong> ${user.user_id}
        </div>

        <div class="card">
            <strong>Login Today:</strong> ${user.login_today}<br>
            <strong>Play Minutes (7d):</strong> ${user.play_minutes_7d}<br>
            <strong>Streak:</strong> ${user.streak}
        </div>

        <div class="card">
            <strong>Triggered Quests:</strong><br>
            ${
                user.triggered_quests && user.triggered_quests.length > 0
                    ? user.triggered_quests.map(q => q.name).join("<br>")
                    : "None"
            }
        </div>

        <div class="card" style="border:2px solid #16a34a;">
            <strong>Selected Quest:</strong><br>
            ${
                user.selected_quest
                    ? `${user.selected_quest.name}<br><strong>Reward:</strong> ${user.selected_quest.reward} Points`
                    : "None"
            }
        </div>

        <div class="card">
            <strong>Suppressed Quests:</strong><br>
            ${
                user.suppressed_quests && user.suppressed_quests.length > 0
                    ? user.suppressed_quests.map(q => q.name).join("<br>")
                    : "None"
            }
        </div>

        <div class="card">
            <strong>Badge:</strong> ${user.badge ? user.badge : "None"}
        </div>

        <div class="card">
            <strong>Notifications:</strong><br>
            ${
                user.notifications && user.notifications.length > 0
                    ? user.notifications.map(n => n.message).join("<br>")
                    : "None"
            }
        </div>
    `;
}

async function init() {
    const userId = getUserIdFromUrl();
    if (!userId) return;

    try {
        const user = await getUserById(userId);
        renderUser(user);
    } catch (error) {
        console.error("User load error:", error);
    }
}

init();
