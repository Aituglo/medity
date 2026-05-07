---
layout: default
title: Privacy — Medity
permalink: /privacy
---

# Privacy Policy

_Last updated: May 2026._

Medity is a meditation timer app for iOS. This page describes what data
the app handles, where it goes, and what choices you have.

## Short version

- **No analytics, no third-party SDKs, no advertising.** Medity does not
  send any data to its developer.
- **Your meditation data stays on your device** and, optionally, in your
  own private iCloud — never on any server we control.
- **Apple Health** integration is opt-in and only writes "Mindful Minutes"
  for sessions you complete. Heart-rate / HRV are read locally if you
  grant permission and never leave your device.
- **Notifications** are local-only. We don't push notifications from a
  server.
- **In-app purchases** are processed by Apple. We never see or store your
  payment details.

## What data Medity stores

| Data | Where it's stored | Why |
|------|-------------------|-----|
| Meditation sessions (start/end time, duration, sound choice) | Locally on your device, optionally synced via your iCloud account (CloudKit private database) | Compute streak, statistics, heatmap |
| Default sound, bell, reminder schedule, Plus unlock | Locally on device, optionally synced via your iCloud | Persist your preferences across launches and devices |
| HealthKit "Mindful Minutes" sample, one per completed session | Apple Health on your device | Surface meditation in the system Health app |
| HealthKit heart-rate / HRV (if you grant permission) | Read locally during a session, never persisted by Medity | Display heart-rate context on the post-session view |

That is the entirety of what Medity reads or writes. There is no other
collection, profiling, identifier, fingerprint, or telemetry.

## What Medity does **not** do

- No analytics SDKs (Firebase, Amplitude, Mixpanel, Segment, etc.)
- No crash reporters that send data off-device
- No ads, no ad SDKs, no ad identifiers
- No network requests other than to Apple's own services (StoreKit, iCloud)
- No tracking across apps or websites
- No sharing of any data with third parties

## iCloud sync

When you are signed in to iCloud and have iCloud Drive enabled, your
session history and preferences sync via Apple's CloudKit to your other
devices that have Medity installed. The data lives in your **private**
CloudKit database — only your devices, signed in to your Apple ID, can
read it. The Medity developer cannot.

If you want to keep everything strictly device-local, sign out of iCloud
or disable iCloud for Medity in Settings → \[your name\] → iCloud.

## Apple Health

If you grant Health access during onboarding (or later in Settings),
Medity writes one Mindful Minutes sample per completed session of 60
seconds or longer. Heart-rate and HRV (if granted) are read on demand
to populate the post-session view and never stored by Medity.

You can revoke Health access at any time in Settings → Health → Data
Access & Devices → Medity.

## Notifications

If you enable the daily reminder, Medity schedules a local
`UNCalendarNotificationTrigger` that fires at the time and on the days
you choose. No remote push, no server, no notification provider.

## Children

Medity is suitable for all ages. No personal data of any kind is
collected, so we don't make any age-specific provisions.

## In-app purchase

Medity Plus is a one-time purchase processed entirely by Apple's
StoreKit. We never see your credit card or Apple ID. The only piece of
data Medity stores after a purchase is a local boolean ("you own Plus")
and Apple's verified entitlement record.

## Data deletion

To delete every piece of data Medity has stored about you:

1. Delete the app from your iPhone (long-press the icon → Remove App →
   Delete App). This removes the local SQLite database.
2. (Optional) In Settings → \[your name\] → iCloud → Manage Account
   Storage → Medity, tap "Delete Data" to remove the synced copy.
3. (Optional) In the Apple Health app, remove the Mindful Minutes
   samples written by Medity in Browse → Mindfulness → Show All Data.

## Contact

For privacy questions: <contact@aituglo.com>.

---

This policy may change as the app evolves. Material changes will be
announced in the app's release notes on the App Store.
