const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const webPush = require('web-push');

dotenv.config();

const app = express();
const port = Number(process.env.PORT || 4000);

app.use(cors());
app.use(express.json());

const subscriptions = new Map();
const orders = [];

const hasVapidKeys =
  process.env.VAPID_PUBLIC_KEY &&
  process.env.VAPID_PRIVATE_KEY &&
  process.env.VAPID_SUBJECT;

if (hasVapidKeys) {
  webPush.setVapidDetails(
    process.env.VAPID_SUBJECT,
    process.env.VAPID_PUBLIC_KEY,
    process.env.VAPID_PRIVATE_KEY,
  );
}

app.get('/health', (request, response) => {
  response.json({
    status: 'ok',
    pushConfigured: Boolean(hasVapidKeys),
    subscriptions: subscriptions.size,
    orders: orders.length,
  });
});

app.get('/api/config', (request, response) => {
  response.json({
    webPushPublicKey: process.env.VAPID_PUBLIC_KEY || null,
  });
});

app.post('/api/subscriptions', (request, response) => {
  const subscription = request.body;
  if (!subscription?.endpoint) {
    response.status(400).json({ error: 'Missing push subscription endpoint' });
    return;
  }

  subscriptions.set(subscription.endpoint, subscription);
  response.status(201).json({ saved: true, count: subscriptions.size });
});

app.post('/api/notifications/test', async (request, response) => {
  const payload = JSON.stringify({
    title: request.body?.title || 'MedCare notification',
    body: request.body?.body || 'This is a test push notification from the MedCare server.',
  });

  if (!hasVapidKeys) {
    response.status(503).json({
      error: 'Web push is not configured. Add VAPID keys in server/.env before sending notifications.',
    });
    return;
  }

  const results = await Promise.allSettled(
    [...subscriptions.values()].map((subscription) =>
      webPush.sendNotification(subscription, payload),
    ),
  );

  response.json({
    sent: results.filter((result) => result.status === 'fulfilled').length,
    failed: results.filter((result) => result.status === 'rejected').length,
  });
});

app.post('/api/orders', async (request, response) => {
  const order = {
    id: `MC-${Date.now()}`,
    items: request.body?.items || [],
    store: request.body?.store || null,
    address: request.body?.address || null,
    status: 'processing',
    createdAt: new Date().toISOString(),
  };

  orders.unshift(order);

  if (hasVapidKeys && subscriptions.size > 0) {
    const payload = JSON.stringify({
      title: 'Order received',
      body: `MedCare order ${order.id} is now being processed.`,
    });

    await Promise.allSettled(
      [...subscriptions.values()].map((subscription) =>
        webPush.sendNotification(subscription, payload),
      ),
    );
  }

  response.status(201).json(order);
});

app.get('/api/orders', (request, response) => {
  response.json(orders);
});

app.listen(port, () => {
  console.log(`MedCare server listening on http://localhost:${port}`);
});