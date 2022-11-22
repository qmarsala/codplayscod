import { playRound } from "./game";
import { sendDiscordMessages } from "./discrod";
import { saveState, getCurrentState } from "./data";

const STATUS_CRASH = "crashed";

const aggregateStatus = (context, status) => {
    console.log(`context: ${JSON.stringify(context)}, status: ${status}`);
    const isCrash = status === STATUS_CRASH
    const state = { ...context.state };
    const messages = [...context.messages] ?? [];
    const roundResult = playRound(state, isCrash);
    messages.push(...roundResult.messages);
    const newContext = {
        state: roundResult.state,
        messages: messages
    };
    console.log(`new context: ${JSON.stringify(newContext)}`);
    return newContext;
}

const execute = async (env) => {
    const listResponse = await env.DATA.list({ prefix: "status:" });
    console.log(`processing list: ${JSON.stringify(listResponse)}`);
    const keys = listResponse?.keys;
    if ((keys?.length ?? 0) < 1) {
        console.log("no messages to process");
        return Promise.resolve("Success");
    }

    let currentState = await getCurrentState(env);
    let context = { messages: [], state: currentState };
    for (var val of keys) {
        const status = await env.DATA.get(val.name);
        context = aggregateStatus(context, status)
        await env.DATA.delete(val.name);
    }

    if ((context?.messages?.length ?? 0) < 1) {
        console.log("state unchanged");
        return Promise.resolve("Success");
    }

    await saveState(context.state, env);
    let success = await sendDiscordMessages(context.messages, env);
    return success
        ? Promise.resolve("Success")
        : Promise.reject("Failure");
}

export { execute };