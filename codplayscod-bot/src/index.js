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
	let player = notification.status === CRASH
		? "crash"
		: "cod";
	let opponent = player === "cod"
		? "crash"
		: "cod";
	let currentScore = parseInt(await env.DATA.get(`${player}_score`) ?? 0);
	let currentOppenentScore = parseInt(await env.DATA.get(`${opponent}_score`) ?? 0);
	let currentStreak = parseInt(await env.DATA.get(`${player}_streak`) ?? 0);
	let currentStreakIndex = parseInt(await env.DATA.get(`${player}_streakIndex`) ?? 0);
	let currentStreakReward = POINT_STREAKS[currentStreakIndex];
	let newScore = currentScore + 1;
	let newStreak = currentStreak + 1;
	let isStreak = newStreak >= currentStreakReward.requirement;
	let newStreakIndex = isStreak
		? currentStreakIndex + 1
		: currentStreakIndex;
	newStreakIndex = newStreakIndex >= POINT_STREAKS.length
		? 0
		: newStreakIndex

	await env.DATA.put(`${player}_score`, newScore);
	await env.DATA.put(`${player}_streak`, newStreak);
	await env.DATA.put(`${player}_streakIndex`, newStreakIndex);
	await env.DATA.put(`${opponent}_streakIndex`, 0);
	await env.DATA.put(`${opponent}_streak`, 0);

	let randomPlayer = PLAYERS[getRandomInt(0, 3)];
	let killFeedMessage = player === "cod"
		? `cod 🔫 ${randomPlayer}`
		: `${randomPlayer} 🔫 cod`;
	let scoreMessage = (newScore + currentOppenentScore) % 4 === 0
		? ` | ${player}: ${newScore} - ${opponent}: ${currentOppenentScore}`
		: "";
	let killStreakMessage = isStreak
		? `${player} called in a ${currentStreakReward.name}`
		: "";
	return [`${killFeedMessage}${scoreMessage}`, killStreakMessage]
}

const sendDiscordMessages = async (messages, env) => {
	console.log("sending discord messages");
	let msgs = messages.filter(m => m.length > 0);
	for (var m of msgs) {
		let response = await fetch(env.DISCORD_WEBHOOK, {
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