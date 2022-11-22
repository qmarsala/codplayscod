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
            console.log(response.statusText);
            return false;
        }
    }
    return true;
}

export { sendDiscordMessages }