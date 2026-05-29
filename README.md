# 云暮星霞

云暮星霞 is a native WeChat Mini Program for Delta Force companion-play booking. It can be imported directly into WeChat Developer Tools from the `miniprogram/` directory.

## Features

- Branded landing page for 云暮星霞
- Delta Force companion-play service cards
- Companion hall with gameplay-style filters
- Booking flow for service type, duration, time slot, voice channel, and notes
- Local order list stored with WeChat Mini Program storage
- Profile center with support, verification, membership, and announcements

## Project structure

```text
.
├── miniprogram/              # WeChat Mini Program project
│   ├── app.js
│   ├── app.json
│   ├── app.wxss
│   ├── project.config.json
│   ├── pages/
│   │   ├── home/             # Landing page
│   │   ├── companions/       # Companion list and filters
│   │   ├── booking/          # Booking form
│   │   ├── orders/           # Local order list
│   │   └── profile/          # Profile center
│   └── utils/data.js         # Mock service and companion data
├── backend/                  # Existing Node.js API service
└── flutter/                  # Existing Flutter client
```

## Run in WeChat Developer Tools

1. Open WeChat Developer Tools.
2. Choose **Import Project**.
3. Select the `miniprogram/` folder as the project directory.
4. Use your own AppID, or keep `touristappid` for local preview.
5. Compile and preview.

The current prototype uses local mock data and `wx.setStorageSync` for orders, so it does not require a backend service to run.
