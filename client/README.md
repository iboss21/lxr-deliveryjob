```
═══════════════════════════════════════════════════════════════════════════
 ██╗     ██╗  ██╗██████╗        ██████╗ ███████╗██╗     ██╗██╗   ██╗███████╗██████╗ ██╗   ██╗
 ██║     ╚██╗██╔╝██╔══██╗       ██╔══██╗██╔════╝██║     ██║██║   ██║██╔════╝██╔══██╗╚██╗ ██╔╝
 ██║      ╚███╔╝ ██████╔╝       ██║  ██║█████╗  ██║     ██║██║   ██║█████╗  ██████╔╝ ╚████╔╝ 
 ██║      ██╔██╗ ██╔══██╗       ██║  ██║██╔══╝  ██║     ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗  ╚██╔╝  
 ███████╗██╔╝ ██╗██║  ██║       ██████╔╝███████╗███████╗██║ ╚████╔╝ ███████╗██║  ██║   ██║   
 ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝   
═══════════════════════════════════════════════════════════════════════════
                        🐺 CLIENT-SIDE SCRIPTS 🐺
═══════════════════════════════════════════════════════════════════════════
```

# 📁 Client Directory

## 🎯 Purpose

**Client-side scripts managing player interactions and user experience.**

This directory contains all client-facing code for the delivery job system, handling UI elements, player interactions with NPCs, wagon spawning and management, GPS routing, delivery completion detection, and client-side anti-exploit measures.

---

## 📄 File Descriptions

### `client.lua`
**Main client-side logic and delivery management**

- 🎮 **Player Interface** - Menu systems for job selection
- 🚗 **Wagon Management** - Spawns delivery vehicles with proper physics
- 🗺️ **GPS & Navigation** - Sets waypoints and manages delivery routes
- 📍 **Proximity Detection** - Monitors distance to delivery zones
- ✅ **Completion Handling** - Detects successful deliveries
- 🛡️ **Client-Side Protection** - Basic anti-exploit measures
- 🎨 **Blip Management** - Creates and manages map markers

**Key Functions:**
- Delivery menu creation (ox_lib integration)
- Wagon spawning with network synchronization
- Delivery zone proximity checks
- Reward request communication with server
- Cleanup on job completion/cancellation

---

### `interaction.lua`
**NPC interaction and menu system handler**

- 👥 **NPC Interactions** - Manages player-NPC communication
- 🎯 **Prompt System** - Native RedM prompts for interaction
- 🔌 **Murphy Integration** - Support for murphy_interact system
- ⏱️ **Rate Limiting** - Anti-spam protection for interactions
- 📋 **Menu Triggering** - Opens delivery selection interface
- 🔒 **Cooldown Management** - Prevents interaction abuse

**Key Features:**
- Dual interaction method support (prompts/murphy)
- Client-side cooldown timers
- Smooth menu transitions
- Distance-based interaction zones

---

### `npcs.lua`
**NPC spawning and management**

- 🧍 **NPC Spawning** - Creates delivery job NPCs at configured locations
- 🎭 **Animations** - Sets NPC scenarios and idle animations
- 🚫 **Entity Flags** - Makes NPCs invincible and non-targetable
- 🗺️ **Blip Creation** - Generates map markers for NPC locations
- 🔄 **Lifecycle Management** - Handles NPC creation and cleanup
- ⚙️ **Config Integration** - Reads NPC data from shared config

**Responsibilities:**
- Spawn NPCs on resource start
- Apply correct models and animations
- Set entity properties (frozen, invincible)
- Create corresponding map blips
- Clean up on resource stop

---

## 🔗 How Client Connects to Server

### Event Communication Flow

```
┌─────────────┐                          ┌─────────────┐
│   CLIENT    │                          │   SERVER    │
└─────────────┘                          └─────────────┘
       │                                         │
       │  lxr-delivery:server:startDelivery     │
       │─────────────────────────────────────>  │
       │                                         │
       │                              Validates  │
       │                              Creates    │
       │                              Session    │
       │                                         │
       │  lxr-delivery:client:deliveryStarted   │
       │  <─────────────────────────────────────│
       │                                         │
       │  (Player delivers wagon)                │
       │                                         │
       │  lxr-delivery:server:completeDelivery  │
       │─────────────────────────────────────>  │
       │                                         │
       │                              Validates  │
       │                              Calculates │
       │                              Gives $$$  │
       │                                         │
       │  lxr-delivery:client:rewardReceived    │
       │  <─────────────────────────────────────│
       │                                         │
```

### Server Events Triggered by Client

- `lxr-delivery:server:startDelivery` - Request to start a delivery job
- `lxr-delivery:server:completeDelivery` - Notify server of delivery completion
- `lxr-delivery:server:cancelDelivery` - Cancel active delivery

### Client Events Received from Server

- `lxr-delivery:client:deliveryStarted` - Confirmation job started
- `lxr-delivery:client:rewardReceived` - Delivery complete, reward given
- `lxr-delivery:client:notifyError` - Error messages from server

---

## 🛡️ Client-Side Security

### Anti-Exploit Measures

1. **Rate Limiting** - Cooldowns on interactions prevent spam
2. **Session Checks** - Validates active delivery state
3. **Distance Validation** - Ensures proper proximity to zones
4. **Cooldown Timers** - Prevents rapid job completion
5. **Input Sanitization** - Validates menu selections

> **Note:** Primary security validation occurs server-side. Client measures provide UX improvements and basic filtering.

---

## ⚡ Performance Considerations

- **Threaded Loops** - Efficient proximity detection
- **Event-Driven** - Minimal constant processing
- **Optimized Natives** - Carefully selected game functions
- **Resource Cleanup** - Proper entity and blip deletion
- **Conditional Processing** - Only active when needed

**Target:** 60+ FPS maintained during all operations

---

## 🔧 Configuration

Client scripts read from `shared/config.lua`:

- **Interaction Method** - `Config.UsePrompt` vs Murphy
- **NPC Locations** - Spawn points and coordinates
- **Delivery Destinations** - Available target locations
- **Blip Settings** - Sprites, colors, labels
- **Cooldown Timers** - Anti-spam delays

---

## 🧪 Testing Client Scripts

### Manual Testing Checklist

- [ ] Approach NPC - prompt appears
- [ ] Open delivery menu - locations display
- [ ] Select destination - wagon spawns
- [ ] GPS waypoint - correctly set
- [ ] Deliver wagon - completion detected
- [ ] Receive reward - notification shown
- [ ] Cancel job - proper cleanup
- [ ] Spam protection - cooldowns working

---

## 📞 Support

**Issues with client scripts?**

- Check browser console (F8) for Lua errors
- Verify ox_lib is installed and running
- Confirm framework is correctly set in config
- Test with minimal resource load
- Report bugs: [GitHub Issues](https://github.com/iBoss21/lxr-deliveryjob/issues)

---

**🐺 The Land of Wolves | Client-Side Excellence**  
*Optimized for Performance, Built for Roleplay*
