const POINT_STREAKS = [
    { requirement: 3, name: "✈️ UAV" },
    { requirement: 4, name: "🛩️ Counter UAV" },
    { requirement: 12, name: "🛰️ Advanced UAV" },
    { requirement: 30, name: "☢️ Tactical Nuke" }
];
const TEAM_NAMES = {
    "cod": "CoD",
    "crash": "TheySeeMeCrashin"
}

const generateMessages = (roundResult, player, opponent) => {
    const PLAYERS = ["zamboni", "badcode", "sofakinggoated", "Jev"];
    const getRandomInt = (min, max) => {
        min = Math.ceil(min);
        max = Math.floor(max);
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }
    const randomPlayer = PLAYERS[getRandomInt(0, 3)];
    const killFeedMessage = player === "cod"
        ? `${TEAM_NAMES["cod"]} 🔫 ${randomPlayer}`
        : `${randomPlayer} 🔫 ${TEAM_NAMES["cod"]}`;
    const state = roundResult.state;
    const playerScore = state[player]?.score ?? 0;
    const opponentScore = state[opponent]?.score ?? 0;
    const scoreMessage = (playerScore + opponentScore) % 4 === 0
        ? ` | ${TEAM_NAMES[player]}: ${playerScore} - ${TEAM_NAMES[opponent]}: ${opponentScore}`
        : "";
    const killStreakMessage = roundResult.isStreak
        ? `${player} called in a ${roundResult.currentStreakReward.name}`
        : "";
    const messages = [];
    messages.push(`${killFeedMessage}${scoreMessage}`);
    if (killStreakMessage.length > 0) {
        messages.push(killFeedMessage);
    }
    return messages;
}

const playRound = (state, isCrash) => {
    const player = isCrash
        ? "crash"
        : "cod";
    const opponent = player === "cod"
        ? "crash"
        : "cod";
    const currentStreak = state[player]?.streak ?? 0;
    const currentStreakIndex = state[player]?.streakIndex ?? 0;
    const currentScore = state[player]?.score ?? 0;
    const newState = { ...state }
    newState[player] ??= { score: 0, streak: 0, streakIndex: 0 };
    newState[opponent] ??= { score: 0, streak: 0, streakIndex: 0 };
    newState[player].score = currentScore + 1;
    newState[player].streak = currentStreak + 1;

    const currentStreakReward = POINT_STREAKS[currentStreakIndex];
    const isStreak = newState[player].streak === currentStreakReward.requirement;
    let newStreakIndex = isStreak
        ? currentStreakIndex + 1
        : currentStreakIndex;
    newStreakIndex = newStreakIndex >= POINT_STREAKS.length
        ? 0
        : newStreakIndex
    newState[player].streakIndex = newStreakIndex;
    newState[opponent].streak = 0;
    newState[opponent].streakIndex = 0;
    const messages = generateMessages({ state, isStreak, currentStreakReward }, player, opponent);
    return {
        state: newState,
        messages
    };
}

export { playRound }