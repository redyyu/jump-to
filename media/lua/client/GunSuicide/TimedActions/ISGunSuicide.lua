require "TimedActions/ISBaseTimedAction"

ISGunSuicide = ISBaseTimedAction:derive("ISGunSuicide")

local OneHandGun = {
	shotTime = 0.3,
	maxTime = 75,
	anim = {
		"Suicide_OneHand_1",
		"Suicide_OneHand_2",
		"Suicide_OneHand_3",
	}
}

local TwoHandGun = {
	shotTime = 0.5,
	maxTime = 120,
	anim = {
		"Suicide_TwoHand",
	}
}


function ISGunSuicide:isValid()
	return true
end

function ISGunSuicide:update()
	local game_speed = UIManager.getSpeedControls():getCurrentGameSpeed()
    if game_speed ~= 1 then
        UIManager.getSpeedControls():SetCurrentGameSpeed(1)
    end

	if self:getJobDelta() > 0 and not self.isOff then
		self.character:splatBloodFloorBig();
		self.isOff = true;
	end

	if self:getJobDelta() >= self.shotTime and not self.isStartSound then
		self.character:getEmitter():playSound(self.gun:getSwingSound())
		self.isStartSound = true;
	end
end

function ISGunSuicide:start()
	if self.anim then
		self:setActionAnim(self.anim)
	end
end

function ISGunSuicide:perform()
	self.gun:setCurrentAmmoCount(math.max(self.gun:getCurrentAmmoCount() - self.gun:getAmmoPerShoot(), 0))
	local rand_seed = 3
	if self.gun:isRequiresEquippedBothHands() then
		rand_seed = 69
	end
	if ZombRand(rand_seed) > 0 then
		self.character:getBodyDamage():setInfectionLevel(0)
		self.character:Kill(self.character)
	else
		self.character:getBodyDamage():AddDamage(BodyPartType.Head, ZombRand(69, 96))
		self.character:getBodyDamage():SetWounded(BodyPartType.Head, true)
	end
	
	ISBaseTimedAction.perform(self)
end

function ISGunSuicide:new(character, gun)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.useProgressBar = false
	o.character = character
	o.gun = gun

	if gun:isRequiresEquippedBothHands() then
		o.anim = TwoHandGun.anim[1]
		o.shotTime = TwoHandGun.shotTime
		o.maxTime = TwoHandGun.maxTime
	else
		o.anim = OneHandGun.anim[1 + ZombRand(#OneHandGun.anim)]
		o.shotTime = OneHandGun.shotTime
		o.maxTime = OneHandGun.maxTime
	end

	return o
end




