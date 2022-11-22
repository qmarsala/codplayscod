const getCurrentState = async (env) => {
    const stateJson = await env.DATA.get("state") ?? "";
    return stateJson.length > 0
        ? JSON.parse(stateJson)
        : {
            "cod": { score: 0, streak: 0, streakIndex: 0 },
            "crash": { score: 0, streak: 0, streakIndex: 0 }
        }
}

const saveState = async (state, env) => {
    await env.DATA.put("state", JSON.stringify(state));
}

export { getCurrentState, saveState }