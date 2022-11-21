import { Router } from 'itty-router';

const CRASH = "crashed";
const POINT_STREAKS = [
    { requirement: 3, name: "✈️ UAV" },
    { requirement: 4, name: "🛩️ Counter UAV" },
    { requirement: 12, name: "🛰️ Advanced UAV" },
    { requirement: 30, name: "☢️ Tactical Nuke" }
];
const PLAYERS = ["zamboni", "badcode", "sofakinggoated", "Jev"];

class JsonResponse extends Response {
    constructor(body, init) {
        const jsonBody = JSON.stringify(body);
        init = init || {
            headers: {
                'content-type': 'application/json;charset=UTF-8',
            },
        };
        super(jsonBody, init);
    }
}

const getRandomInt = (min, max) => {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

const processNotification = async (notification, env) => {
    console.log(notification);
    const player = notification.status === CRASH
        ? "crash"
        : "cod";
    const opponent = player === "cod"
        ? "crash"
        : "cod";
    const currentState = await env.DATA.get("state") ?? {};
    const currentStreak = currentState[player]?.streak ?? 0;
    const currentStreakIndex = currentState[player]?.streakIndex ?? 0;
    const currentScore = currentState[player]?.score ?? 0;
    const currentOppenentScore = currentState[opponent]?.score ?? 0;
    const newState = { ...currentState }
    
    console.log(newState);
    console.log(JSON.stringify(newState));
    
    newState[player] ??= { score: 0, streak: 0, streakIndex: 0 };
    newState[opponent] ??= { score: 0, streak: 0, streakIndex: 0 };

    console.log(newState);
    console.log(JSON.stringify(newState));

    newState[player].score = currentScore + 1;
    newState[player].streak = currentStreak + 1;

    const currentStreakReward = POINT_STREAKS[currentStreakIndex];
    const isStreak = newState[player].streak >= currentStreakReward.requirement;
    let newStreakIndex = isStreak
        ? currentStreakIndex + 1
        : currentStreakIndex;
    newStreakIndex = newStreakIndex >= POINT_STREAKS.length
        ? 0
        : newStreakIndex
    newState[player].streakIndex = newStreakIndex;
    newState[opponent].streak = 0;
    newState[opponent].streakIndex = 0;

    console.log(newState);
    console.log(JSON.stringify(newState));
    await env.DATA.put("state", JSON.stringify(newState));

    const randomPlayer = PLAYERS[getRandomInt(0, 3)];
    const killFeedMessage = player === "cod"
        ? `cod 🔫 ${randomPlayer}`
        : `${randomPlayer} 🔫 cod`;
    const newScore = newState[player].score;
    const scoreMessage = (newScore + currentOppenentScore) % 4 === 0
        ? ` | ${player}: ${newScore} - ${opponent}: ${currentOppenentScore}`
        : "";
    const killStreakMessage = isStreak
        ? `${player} called in a ${currentStreakReward.name}`
        : "";
    return [`${killFeedMessage}${scoreMessage}`, killStreakMessage]
}

const sendDiscordMessages = async (messages, env) => {
    console.log("sending discord messages");
    const msgs = messages.filter(m => m.length > 0);
    for (var m of msgs) {
        const response = await fetch(env.DISCORD_WEBHOOK, {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ "content": m })
        });
        if (response.status > 299) {
            return false;
        }
    }
    return true;
}

const router = Router();
router.post('/', async (request, env) => {
    let notification = await request.json();
    let discordMessages = await processNotification(notification, env);
    let success = await sendDiscordMessages(discordMessages, env);
    return new JsonResponse({ status: success ? 200 : 500 });
});
router.all('*', () => new Response('Not Found.', { status: 404 }));

export default {
    async fetch(request, env) {
        return router.handle(request, env);
    },
};