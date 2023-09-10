local PlayerBuiltAndMovedObject = function(thump_target) -- Return true if ThumpableObject is PlayerBuilt or Moved Object
	if instanceof(thump_target, "IsoThumpable") then return true -- Pass if playerbuilt
	elseif instanceof(thump_target, "IsoBarricade") then return true-- Pass if barricade on window frame with broken/without window
	elseif instanceof(thump_target, "BarricadeAble") and not instanceof(thump_target, "IsoThumpable") then 
		if not thump_target:isBarricaded() then return false-- Pass if barricaded non-player built object
		else return true
		end
	elseif not instanceof(thump_target, "IsoThumpable") then return false-- Cancel other non-playerbuilt
	end
end

local All = function(thump_target)
	return true
end

local Nothing = function(thump_target)
	return false
end

local function GetHurtingBarricade(param1) -- Assign funtion depending on HurtingBarricade option
	if param1 == 1 then return PlayerBuiltAndMovedObject
	elseif param1 == 2 then return All
	else return Nothing
	end
end

local GameSpeedToDmgMultiplier = {1,5,20,40}
local BHZ_THUMP_DMG = SandboxVars.BarricadeHurtZombies.BarricadeDamage / 100
local BHZ_THUMP_FUNC = GetHurtingBarricade(SandboxVars.BarricadeHurtZombies.HurtingBarricade)

local function HurtZombieThumping(x, y, z, radius, volume, source)
	if instanceof(source, "IsoZombie") then
		if source:getCurrentStateName() == "ThumpState" then
			local thump_target = source:getThumpTarget()
			local thump_dmg = BHZ_THUMP_DMG
			local blood_int = 1
			if not thump_target then return; end
			local damage_multiplier = thump_target:getModData().BarricadeDamageMultiplier
			if damage_multiplier then 
				thump_dmg = thump_dmg * thump_target:getModData().BarricadeDamageMultiplier
				blood_int = blood_int * thump_target:getModData().BarricadeDamageMultiplier 
			else
				if not BHZ_THUMP_FUNC(thump_target) then return; end
			end
	        local new_z_health = source:getHealth() - (thump_dmg * GameSpeedToDmgMultiplier[getGameSpeed()])
			if new_z_health <= 0 then source:Kill(source:getCell():getFakeZombieForHit(), true) return 
			end
			source:setHealth(new_z_health)
			local sqr = source:getSquare()
			if sqr then addBloodSplat(sqr, blood_int) end;
		end
	end
end
Events.OnWorldSound.Add(HurtZombieThumping)

local function OnLoad()
	BHZ_THUMP_DMG = SandboxVars.BarricadeHurtZombies.BarricadeDamage / 100
	BHZ_THUMP_FUNC = GetHurtingBarricade(SandboxVars.BarricadeHurtZombies.HurtingBarricade)
end

Events.OnLoad.Add(OnLoad)
