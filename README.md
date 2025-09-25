# lux-mission-delivery

Mission-based delivery system for **RedM** supporting **LXRCore**, **RSGCore**, and **VORP** via a framework adapter.

## Highlights
- Narrative mission board(s) with risk tiers, stealth runs, and escorts (hooks included).
- Dynamic payouts: distance × risk × demand – with cargo damage penalties.
- Player progression (levels + perks) with KVP or `oxmysql` storage.
- Highly configurable; Georgian `ge.lua` locale included.
- Clean adapters for money/items; fill in LXR-specific calls if your build differs.

## Install
1. Ensure `ox_lib` and (optionally) `oxmysql` are started before this resource.
2. Drop the folder into your resources and add to `server.cfg`:
   ```cfg
   ensure lux-mission-delivery
   ```
3. If using MySQL:
   - Set `Config.Progression.storageMode = "oxmysql"` in `shared/config.lua`.
   - Import `sql/lux_delivery.sql`.
4. Pick your framework in `shared/config.lua` or leave `AUTO` for detection.

> **Reminder**: This resource includes the required RedM prerelease warning in `fxmanifest.lua` per your preference.

## Framework Notes
- **RSGCore**: uses `GetCoreObject()` and `Player.Functions.AddMoney/AddItem`.
- **VORP**: uses `vorp_core` exports; currency account name comes from `Config.MoneyAccount`.
- **LXRCore**: map your money/item APIs in `shared/framework.lua` (placeholders included).

## Commands
- `/canceldelivery` — abort current mission.

## Extend
- Add ambush AI logic in `client/ambush.lua`.
- Add stealth/law detection and weather handling tweaks in `client/events.lua`.
- Add more boards/missions in `shared/config.lua`.

