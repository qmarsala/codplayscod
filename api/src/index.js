import { Router } from 'itty-router';
import { execute } from './cron';

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

const logStatus = async (notification, env) => {
    const dateTime = Date.now();
    const secondsFromNow = 6000;
    env.DATA.put(`status:${dateTime}`, notification.status, { expirationTtl: secondsFromNow });
}

const router = Router();
router.post('/', async (request, env) => {
    const notification = await request.json();
    await logStatus(notification, env);
    return new JsonResponse({ status: 202 });
});
router.get('/', async (request, env) => {
    const state = await env.DATA.get("state");
    return new JsonResponse(state ?? {}, { status: 200 });
});
router.all('*', () => new Response('Not Found.', { status: 404 }));

export default {
    async scheduled(event, env, ctx) {
        ctx.waitUntil(execute(env));
    },
    async fetch(request, env) {
        return router.handle(request, env);
    },
};