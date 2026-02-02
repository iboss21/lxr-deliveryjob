```
═══════════════════════════════════════════════════════════════════════════════════
 ██╗     ██╗  ██╗██████╗        ██████╗ ███████╗██╗     ██╗██╗   ██╗███████╗██████╗ ██╗   ██╗
 ██║     ╚██╗██╔╝██╔══██╗       ██╔══██╗██╔════╝██║     ██║██║   ██║██╔════╝██╔══██╗╚██╗ ██╔╝
 ██║      ╚███╔╝ ██████╔╝       ██║  ██║█████╗  ██║     ██║██║   ██║█████╗  ██████╔╝ ╚████╔╝ 
 ██║      ██╔██╗ ██╔══██╗       ██║  ██║██╔══╝  ██║     ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗  ╚██╔╝  
 ███████╗██╔╝ ██╗██║  ██║       ██████╔╝███████╗███████╗██║ ╚████╔╝ ███████╗██║  ██║   ██║   
 ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝   
═══════════════════════════════════════════════════════════════════════════════════
                    🐺 THE LAND OF WOLVES - DELIVERY JOB SYSTEM 🐺
═══════════════════════════════════════════════════════════════════════════════════
```

<img width="1024" height="1536" alt="The Land of Wolves - LXRCore Delivery System" src="https://github.com/user-attachments/assets/b3038f26-ae9b-4018-ad4d-16308324c037" />

## 📋 Overview

**A professional wagon/cart delivery system for RedM roleplay servers.**

This script enables players to undertake frontier delivery jobs, transporting goods across the Red Dead Redemption 2 map. Players select destinations, deliver wagons/carts, and earn configurable rewards. Built with security-first design featuring anti-exploit validation and rate limiting.

**Developer:** iBoss21 / The Lux Empire  
**Website:** [www.wolves.land](https://www.wolves.land)  
**Discord:** [Join The Land of Wolves Community](https://discord.gg/CrKcWdfd3A)  
**GitHub:** [github.com/iBoss21](https://github.com/iBoss21)

---

## ✨ Features

### 🎯 Core Features
- ✅ **Multi-Framework Support** - LXR-Core, RSG-Core, and VORP frameworks
- ✅ **Flexible Interaction** - Native prompts or [Murphy Interaction](https://github.com/levraimurphy/murphy_interact)
- ✅ **Selectable Destinations** - Choose from multiple delivery towns
- ✅ **GPS Routing** - Automatic waypoint to delivery location
- ✅ **Configurable Rewards** - Customizable money and XP payouts

### 🔒 Security & Anti-Exploit
- ✅ **Server-Side Validation** - All rewards validated server-side
- ✅ **Session Management** - One active delivery per player
- ✅ **Rate Limiting** - Prevents spam and exploits
- ✅ **Anti-Cheat Protection** - Built-in safeguards against abuse

### ⚡ Performance
- ✅ **Optimized Code** - 60+ FPS target maintained
- ✅ **Efficient Resource Usage** - Minimal impact on server
- ✅ **Clean Architecture** - Modular, maintainable codebase

---

## 📸 Screenshots

<img width="574" height="677" alt="Delivery NPC Interaction" src="https://github.com/user-attachments/assets/5ba87932-82bc-4ee1-81af-e1980b5bfd0f" />
<img width="558" height="660" alt="Destination Selection Menu" src="https://github.com/user-attachments/assets/b263d03c-61e6-4899-b7f8-b3dc2a349fda" />

---

## 🚀 Quick Start

### Installation

1. **Download** this repository into your RedM `resources` folder:
   ```bash
   resources/[jobs]/lxr-deliveryjob
   ```

2. **Add to server.cfg**:
   ```cfg
   ensure lxr-deliveryjob
   ```

3. **Configure** the script in `shared/config.lua`:
   - Set your framework (LXR/RSG/VORP)
   - Configure delivery locations
   - Adjust reward amounts
   - Choose interaction method
   - Set anti-spam timers

4. **Restart** your server and enjoy!

### 📚 Dependencies

**Required:**
- RedM server (latest build recommended)
- [ox_lib](https://github.com/Rexshack-RedM/ox_lib) - Essential library
- One of these frameworks:
  - [LXR-Core](https://www.wolves.land) - The Land of Wolves framework
  - [RSG-Core](https://github.com/Rexshack-RedM) - RedM Script Group
  - [VORP Framework](https://github.com/VORPCORE) - Vintage Outlaw RP

**Optional:**
- [Murphy Interaction](https://github.com/levraimurphy/murphy_interact) - Enhanced UI

---

## 📁 Project Structure

```
lxr-deliveryjob/
├── client/          - Client-side scripts (UI, interactions, wagon spawning)
├── server/          - Server-side validation and security
├── shared/          - Configuration and framework adapter
├── docs/            - Additional documentation
└── fxmanifest.lua   - Resource manifest
```

**📖 See each folder's README for detailed information.**

---

## 🎮 How to Use

1. **Approach** a delivery NPC at a configured location
2. **Interact** with the NPC (press prompt or use Murphy Interact)
3. **Select** your delivery destination from the menu
4. **Deliver** the spawned wagon to the destination
5. **Receive** your reward automatically upon arrival

---

## ⚙️ Configuration

Edit `shared/config.lua` to customize:

- **Framework**: Choose LXR, RSG, or VORP
- **Interaction**: Native prompts or Murphy Interact
- **Rewards**: Money and XP amounts
- **Locations**: Start points and delivery destinations
- **Anti-Spam**: Cooldown timers and rate limits
- **NPCs**: Models, animations, and blips

---

## 🌐 Server Information

```
═══════════════════════════════════════════════════════════════════════════
                      🐺 THE LAND OF WOLVES 🐺
═══════════════════════════════════════════════════════════════════════════
Server:     The Land of Wolves | მგლების მიწა
Community:  Georgian RP 🇬🇪 | რჩეულთა ადგილი!
Tagline:    ისტორია ცოცხლდება აქ! (History Lives Here!)
Type:       Serious Hardcore Roleplay
Access:     Discord & Whitelisted

Website:    https://www.wolves.land
Discord:    https://discord.gg/CrKcWdfd3A
GitHub:     https://github.com/iBoss21
Store:      https://theluxempire.tebex.io
Listing:    https://servers.redm.net/servers/detail/8gj7eb
═══════════════════════════════════════════════════════════════════════════
``` 
---

## 🙏 Credits & Attribution

**Original Creators:**
- **RexShack** - [rsg-delivery](https://github.com/Rexshack-RedM/rsg-delivery) - Original RSG delivery system
- **Muhammad Abdullah Shurjeel** - [stx-coder](https://github.com/stx-coder) - Base concept and wagon logic

**Current Development:**
- **Developer:** iBoss21
- **Brand:** The Land of Wolves (www.wolves.land)
- **Organization:** The Lux Empire
- **System:** LXRCore Delivery System

This script is a rebranded and enhanced version maintaining full respect for original creators while adding enterprise-level security, multi-framework support, and performance optimizations.

---

## 📞 Support & Community

- **Discord:** [Join The Land of Wolves](https://discord.gg/CrKcWdfd3A)
- **Website:** [www.wolves.land](https://www.wolves.land)
- **GitHub Issues:** [Report bugs or request features](https://github.com/iBoss21/lxr-deliveryjob/issues)
- **Store:** [The Lux Empire on Tebex](https://theluxempire.tebex.io)

---

## 📄 License

```
Copyright (c) 2024-2026 The Lux Empire / iBoss21

Licensed under MIT License
wolves.land

Respect the original creators and their work.
This script maintains attribution to all contributors.
```

---

## 🏷️ Tags

`redm` `roleplay` `delivery-job` `wagon-delivery` `lxr-core` `rsg-core` `vorp` `anti-exploit` `multi-framework` `land-of-wolves` `georgian-rp` `frontier-jobs` `economy`

---

**Made with 🐺 by The Land of Wolves**  
*Where History Lives | ისტორია ცოცხლდება აქ*
