import { Router } from 'itty-router';
import { execute } from './cron';

const logStatus = async (notification, env) => {
    const dateTime = Date.now();
    const secondsFromNow = 6000;
    env.DATA.put(`status:${dateTime}`, notification.status, { expirationTtl: secondsFromNow });
}

const router = Router();
router.post('/', async (request, env) => {
    //todo: handle discord commands to "call in streaks", and "check score"
    const body = await request.json();
    console.log(`request:${JSON.stringify(request)}, body: ${JSON.stringify(body)}`);
    return new Response({ status: 204 });
});
router.post('/status', async (request, env) => {
    const notification = await request.json();
    await logStatus(notification, env);
    return new Response({ "loggedStatus": notification.status }, { status: 202 });
});
router.get('/', async (request, env) => {
    const state = await env.DATA.get("state");
    return new Response(state ?? {}, { status: 200 });
});
router.all('*', () => new Response({ error: "Not Found." }, { status: 404 }));

export default {
    async scheduled(event, env, ctx) {
        ctx.waitUntil(execute(env));
    },
    async fetch(request, env) {
        return router.handle(request, env);
    },
};