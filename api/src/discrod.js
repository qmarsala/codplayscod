const sendDiscordMessages = async (messages, env) => {
    console.log("sending discord messages");
    const message = messages.filter(m => m.length > 0).join(`\n`);
    const response = await fetch(env.DISCORD_WEBHOOK, {
        method: 'POST',
        headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ "content": message })
    });
    if (response.status >= 200 && response.status < 300) {
        return true;
    }
    console.log(response.statusText);
    return false;
}

export { sendDiscordMessages }