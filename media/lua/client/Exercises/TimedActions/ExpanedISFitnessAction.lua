
require "TimedActions/ISFitnessAction"

local function playExerSound(char, soundName, soundRadius, soundVolume)
    if not char:getEmitter():isPlaying(soundName) then
        -- Emitter sound in the world (zombies can hear)
        char:getEmitter():playSound(soundName)
        addSound(char, char:getX(), char:getY(), char:getZ(), soundRadius or 12, soundVolume or 6)
    end
end 


local oldWaitToStart = ISFitnessAction.waitToStart
function ISFitnessAction:waitToStart()
    local facingX = self.exeData.facingX
    local facingY = self.exeData.facingY
    print(facingX)
    print(facingY)
    print("========================")
    if facingX ~= nil and facingY ~= nil then
        self.character:faceLocation(facingX, facingY)
    end
    return self.character:shouldBeTurning() or oldWaitToStart(self)
end


local oldExeLooped = ISFitnessAction.exeLooped
function ISFitnessAction:exeLooped()

    if self.exercise == "treadmill" then
        -- gain Sprinting XP when use treadmill
        self.character:getXp():AddXP(Perks.Sprinting, self.exeData.xpMod)
    end

    oldExeLooped(self)
end


local oldUpdate = ISFitnessAction.update
function ISFitnessAction:update()
    if self.exercise == "treadmill" then
        playExerSound(self.character, "ExercisesTreadmillrun")
    elseif self.exercise == "benchpress" then
        playExerSound(self.character, "ExercisesBench")
    end
    oldUpdate(self)
end


local oldStop = ISFitnessAction.stop
function ISFitnessAction:stop()
    self:endExercise()
    oldStop(self)
end

local oldPerform = ISFitnessAction.perform
function ISFitnessAction:perform()
    self:endExercise()
    oldPerform(self)
end


function ISFitnessAction:endExercise()
    self.character:getEmitter():stopAll()
    if self.exercise == "treadmill" then
        playExerSound(self.character, "ExercisesTreadmillend")
    end
end