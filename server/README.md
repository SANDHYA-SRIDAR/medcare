# MedCare Server

This is a simple Express backend for MedCare. It is designed to support:

- shopping order submission
- push subscription registration
- broadcast test push notifications

## Quick start

1. Copy `.env.example` to `.env`
2. Generate VAPID keys for web push
3. Install dependencies with `npm install`
4. Start the server with `npm run dev`

## Endpoints

- `GET /health`
- `GET /api/config`
- `POST /api/subscriptions`
- `POST /api/notifications/test`
- `POST /api/orders`
- `GET /api/orders`

This server is intentionally simple. For production mobile push notifications, replace the web-push layer with Firebase Cloud Messaging or another push provider and connect the Flutter app through authenticated APIs.