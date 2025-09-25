CONST = {}
CONST.RISK={LOW='low',MEDIUM='medium',HIGH='high',EXTREME='extreme'}
CONST.FW={AUTO='AUTO',LXR='LXR',RSG='RSG',VORP='VORP'}
CONST.INTERACT={PROMPT='prompt',MURPHY='murphy',TARGET='ox_target'}
function clamp(v,a,b) if v<a then return a elseif v>b then return b else return v end end
function joaat(s) return GetHashKey(s) end
