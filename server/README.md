```
═══════════════════════════════════════════════════════════════════════════
 ██╗     ██╗  ██╗██████╗        ██████╗ ███████╗██╗     ██╗██╗   ██╗███████╗██████╗ ██╗   ██╗
 ██║     ╚██╗██╔╝██╔══██╗       ██╔══██╗██╔════╝██║     ██║██║   ██║██╔════╝██╔══██╗╚██╗ ██╔╝
 ██║      ╚███╔╝ ██████╔╝       ██║  ██║█████╗  ██║     ██║██║   ██║█████╗  ██████╔╝ ╚████╔╝ 
 ██║      ██╔██╗ ██╔══██╗       ██║  ██║██╔══╝  ██║     ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗  ╚██╔╝  
 ███████╗██╔╝ ██╗██║  ██║       ██████╔╝███████╗███████╗██║ ╚████╔╝ ███████╗██║  ██║   ██║   
 ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝   
═══════════════════════════════════════════════════════════════════════════
                        🐺 SERVER-SIDE AUTHORITY 🐺
═══════════════════════════════════════════════════════════════════════════
```

# 📁 Server Directory

## 🎯 Purpose

**Server-side validation and authority for secure delivery processing.**

This directory contains the authoritative server logic that validates all delivery operations, manages player sessions, calculates and distributes rewards, enforces anti-exploit measures, and maintains the integrity of the economy system.

---

## 📄 File Description

### `server.lua`
**Complete server-side authority and validation**

The single-file server implementation provides comprehensive security and economic control for the delivery job system.

---

## 🔒 Core Responsibilities

### 1. Session Management
- **One Active Delivery Per Player** - Prevents multi-job exploits
- **Session State Tracking** - Monitors delivery progress
- **Session Cleanup** - Removes abandoned/completed sessions
- **Player Disconnect Handling** - Graceful session termination

```lua
-- Example session structure
activeSessions[playerId] = {
    destination = "Valentine",
    startTime = os.time(),
    rewardAmount = 150
}
```

### 2. Request Validation
- **Player Authentication** - Verifies player identity
- **State Verification** - Ensures valid session state
- **Parameter Sanitization** - Prevents malicious input
- **Distance Checks** - Server-side proximity validation
- **Cooldown Enforcement** - Rate limiting on server

### 3. Reward Calculation & Distribution
- **Dynamic Calculation** - Based on distance and config
- **Framework Integration** - LXR/RSG/VORP money systems
- **XP Distribution** - Experience point rewards (if supported)
- **Transaction Logging** - Audit trail for economy
- **Rollback Capability** - Error recovery mechanisms

### 4. Anti-Exploit Protection
- **Duplicate Request Prevention** - Blocks rapid submissions
- **Session Hijacking Prevention** - Validates ownership
- **Reward Limit Checks** - Prevents unrealistic payouts
- **Time-Based Validation** - Detects impossible completion times
- **Teleport Detection** - Identifies suspicious movement

### 5. Multi-Framework Support
- **Framework Detection** - Automatic identification
- **Unified API** - Consistent interface across frameworks
- **Player Data Access** - Framework-agnostic player retrieval
- **Money Functions** - Normalized currency operations
- **Event Registration** - Framework-specific callbacks

---

## 🔐 Security Architecture

### Defense Layers

```
┌──────────────────────────────────────────────────────┐
│                 CLIENT REQUEST                       │
└──────────────────┬───────────────────────────────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │  Rate Limit Check   │  ← First line of defense
         └─────────┬───────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │  Player Validation  │  ← Identity verification
         └─────────┬───────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │  Session Validation │  ← State checking
         └─────────┬───────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │  Distance Check     │  ← Proximity validation
         └─────────┬───────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │  Reward Calculation │  ← Economy protection
         └─────────┬───────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │  Transaction Log    │  ← Audit trail
         └─────────┬───────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │  Success Response   │
         └─────────────────────┘
```

### Key Security Features

#### ⏱️ Rate Limiting
```lua
local rateLimitCache = {}
local RATE_LIMIT = 3000 -- 3 seconds between requests
```
- Prevents spam attacks
- Reduces server load
- Protects against DoS attempts

#### 🔍 Session Integrity
```lua
-- Only one active delivery per player
if activeSessions[playerId] then
    return false, "Already have active delivery"
end
```
- One job at a time enforcement
- Session hijacking prevention
- State consistency

#### 💰 Economic Protection
```lua
-- Validate reward amounts
if calculatedReward > Config.MaxReward then
    calculatedReward = Config.MaxReward
end
```
- Maximum payout limits
- Minimum reward thresholds
- Exploit-proof calculations

#### 📊 Audit Logging
```lua
-- Log all transactions
Logger.Info(string.format(
    "Player %s completed delivery to %s for $%d",
    playerId, destination, reward
))
```
- Transaction history
- Exploit detection
- Economy monitoring

---

## 📡 Server Events

### Registered Events

#### `lxr-delivery:server:startDelivery`
**Initiates a delivery job**

**Parameters:** `destination` (string)

**Validation:**
1. Player authentication
2. No active session check
3. Valid destination check
4. Rate limit verification

**Success:** Creates session, returns confirmation
**Failure:** Returns error message

---

#### `lxr-delivery:server:completeDelivery`
**Completes a delivery and grants rewards**

**Parameters:** None (uses active session)

**Validation:**
1. Active session exists
2. Session ownership verified
3. Distance to destination validated
4. Time-based sanity checks

**Success:** Grants reward, removes session
**Failure:** Returns error, maintains session

---

#### `lxr-delivery:server:cancelDelivery`
**Cancels active delivery job**

**Parameters:** None

**Validation:**
1. Session exists
2. Player ownership

**Success:** Removes session, cleanup
**Failure:** Error notification

---

## 🔧 Configuration

Server reads from `shared/config.lua`:

### Security Settings
```lua
Config.AntiSpam = {
    Enabled = true,
    Cooldown = 3000,        -- 3 seconds
    MaxActiveSessions = 1   -- Per player
}
```

### Reward Settings
```lua
Config.Rewards = {
    BasePay = 100,
    DistanceMultiplier = 0.5,
    MaxReward = 500,
    MinReward = 50,
    IncludeXP = true,
    XPAmount = 25
}
```

### Validation Settings
```lua
Config.Validation = {
    MaxDeliveryDistance = 5.0,  -- Delivery zone radius
    MinCompletionTime = 30,     -- 30 seconds minimum
    EnableDistanceCheck = true,
    EnableTimeCheck = true
}
```

---

## 🔍 Monitoring & Debugging

### Server Console Output

**Startup:**
```
[LXR-DELIVERY] Server initialized
[LXR-DELIVERY] Framework detected: RSG-Core
[LXR-DELIVERY] Anti-exploit enabled
[LXR-DELIVERY] Ready for deliveries
```

**During Operation:**
```
[LXR-DELIVERY] Player 12 started delivery to Valentine
[LXR-DELIVERY] Player 12 completed delivery - Reward: $150
[LXR-DELIVERY] Player 34 rate limited (spam detected)
```

### Debug Commands

Enable debug mode in config:
```lua
Config.Debug = true
```

Provides verbose logging:
- Session creation/destruction
- Validation steps
- Reward calculations
- Framework operations

---

## 🧪 Testing Server Logic

### Test Checklist

- [ ] **Session Management**
  - [ ] Single session per player enforced
  - [ ] Session cleanup on completion
  - [ ] Session removal on disconnect

- [ ] **Validation**
  - [ ] Invalid destination rejected
  - [ ] Duplicate requests blocked
  - [ ] Distance validation working
  - [ ] Rate limiting active

- [ ] **Rewards**
  - [ ] Correct amounts calculated
  - [ ] Money added to player
  - [ ] XP granted (if enabled)
  - [ ] Transaction logged

- [ ] **Anti-Exploit**
  - [ ] Rapid requests blocked
  - [ ] Maximum payout enforced
  - [ ] Invalid session detected
  - [ ] Teleport attempts caught

---

## 🛠️ Framework Integration

### Supported Frameworks

#### LXR-Core (Primary)
```lua
local Player = Framework.GetPlayer(source)
Player.AddMoney('cash', amount)
```

#### RSG-Core
```lua
local Player = RSGCore.Functions.GetPlayer(source)
Player.Functions.AddMoney('cash', amount)
```

#### VORP Core
```lua
local Player = VORPcore.getUser(source).getUsedCharacter
Player.addCurrency(0, amount) -- 0 = cash
```

---

## 📊 Performance Metrics

### Target Performance
- **Event Processing:** < 5ms per request
- **Session Lookup:** O(1) hash table access
- **Memory Usage:** < 1MB for session storage
- **CPU Impact:** Negligible when idle

### Optimization Techniques
- Efficient session storage (hash tables)
- Minimal validation overhead
- Lazy framework loading
- Event-driven architecture (no loops)

---

## ⚠️ Common Issues & Solutions

### Issue: Rewards not given
**Solution:** Check framework integration, verify player object, check console for errors

### Issue: "Already have active delivery" spam
**Solution:** Session not cleaning up - check for script errors on completion

### Issue: Rate limit triggering incorrectly
**Solution:** Adjust `Config.AntiSpam.Cooldown` value

### Issue: Distance validation fails at destination
**Solution:** Increase `Config.Validation.MaxDeliveryDistance`

---

## 📞 Support

**Server-side issues?**

- Enable `Config.Debug` for verbose logging
- Check server console for error messages
- Verify framework is loaded correctly
- Test with single player first
- Report bugs: [GitHub Issues](https://github.com/iBoss21/lxr-deliveryjob/issues)

---

**🐺 The Land of Wolves | Server Authority**  
*Security First, Performance Always*
