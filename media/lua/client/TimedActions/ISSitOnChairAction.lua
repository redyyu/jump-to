
require "TimedActions/ISBaseTimedAction"

ISSitOnChairAction = ISBaseTimedAction:derive("ISSitOnChairAction")

local function getMultiplier(book)
    if SkillBook[book:getSkillTrained()] then
        if book:getLvlSkillTrained() == 1 then
            return SkillBook[book:getSkillTrained()].maxMultiplier1
        elseif book:getLvlSkillTrained() == 3 then
            return SkillBook[book:getSkillTrained()].maxMultiplier2
        elseif book:getLvlSkillTrained() == 5 then
            return SkillBook[book:getSkillTrained()].maxMultiplier3
        elseif book:getLvlSkillTrained() == 7 then
            return SkillBook[book:getSkillTrained()].maxMultiplier4
        elseif book:getLvlSkillTrained() == 9 then
            return SkillBook[book:getSkillTrained()].maxMultiplier5
        else
            return 1
            print('ERROR: book has unhandled skill level ' .. book:getLvlSkillTrained())
        end
    end
end

-- get how much % of the book we already read, then we apply a multiplier depending on the book read progress
local function checkMultiplier(book)
    -- get all our info in the map
    local trainedStuff = SkillBook[book:getSkillTrained()]
    if trainedStuff then
        -- every 10% we add 10% of the max multiplier
        local readPercent = (book:getAlreadyReadPages() / book:getNumberOfPages()) * 100
        if readPercent > 100 then
            readPercent = 100
        end
        -- apply the multiplier to the skill
        local multiplier = (math.floor(readPercent/10) * (self.maxMultiplier/10))
        if multiplier > self.character:getXp():getMultiplier(trainedStuff.perk) then
            self.character:getXp():addXpMultiplier(trainedStuff.perk, multiplier, book:getLvlSkillTrained(), book:getMaxLevelTrained())
        end
    end
end


local function checkLevel(character, book)
    if book:getNumberOfPages() <= 0 then
        return
    end
    local skillBook = SkillBook[book:getSkillTrained()]
    if not skillBook then
        return
    end
    local level = character:getPerkLevel(skillBook.perk)
    if character:HasTrait("Illiterate") or (book:getLvlSkillTrained() > level + 1) then
        book:setAlreadyReadPages(0)
        character:setAlreadyReadPages(book:getFullType(), 0)
    end
end


function ISSitOnChairAction:isValid()
    if self.character:getVehicle() or 
       not self.sitSquare or 
       not self.chair:getSprite() or 
       not self.chair:getSprite():getProperties() then
        return false
    end

    if self.book then
        if self.character:getInventory():contains(self.book) then
            local pages = self.book:getNumberOfPages() > 0 and self.book:getAlreadyReadPages() <= self.book:getNumberOfPages()
            return pages or self.book:getNumberOfPages() < 0
        else
            return false
        end
    end

    return true       
end

function ISSitOnChairAction:waitToStart()
    local facingX = self.sitSquare:getX() 
    local facingY = self.sitSquare:getY()
    local props = self.chair:getSprite():getProperties()
    local facing = props:Val("Facing")
    if facing == "S" then
        facingY = facingY + 10
    elseif facing == "E" then
        facingX = facingX + 10
    elseif facing == "W" then
        facingX = facingX - 10
    elseif facing == "N" then
        facingY = facingY - 10
    end
    self.character:faceLocation(facingX, facingY)
    return self.character:shouldBeTurning()
end


function ISSitOnChairAction:update()
    if self.character and self.character:getStats():getEndurance() < 1 then
        self.character:updateEnduranceWhileSitting()
    end
    if self.book then
        self:reading()
    end
end


function ISSitOnChairAction:animEvent(event, parameter)
    if event == "PageFlip" and self.book then
        if getGameSpeed() ~= 1 then
            return
        end
        if SkillBook[self.book:getSkillTrained()] then
            self.character:playSound("PageFlipBook")
        else
            self.character:playSound("PageFlipMagazine")
        end
    end
end


function ISSitOnChairAction:start()
    self.character:setVariable("ExerciseStarted", false)
    self.character:setVariable("ExerciseEnded", true)
    self.character:setIgnoreAimingInput(true)

    if self.book then
        self:readingStart()
    end
    if self.sitSquare == self.chair:getSquare() then
        self:setActionAnim("SitOnChair")
    elseif self.sitSquare == self.character:getCurrentSquare() then
        self:setActionAnim("SitOnChairOffset")
    end
end

function ISSitOnChairAction:stop()
    if self.book then
        self:readingStop()
    end
    self:restoreMovements()
    ISBaseTimedAction.stop(self)
end

function ISSitOnChairAction:perform()
    if self.book then
        self:readingPerform()
    end
    self:restoreMovements()
    ISBaseTimedAction.perform(self)
end

function ISSitOnChairAction:new(character, chair, sitSquare)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    
    o.stopOnWalk = true
    o.stopOnRun = true
    o.character = character
    o.chair = chair
    o.sitSquare = sitSquare

    if o.book then
        local numPages
        if item:getNumberOfPages() > 0 then
            checkLevel(character, item)
            item:setAlreadyReadPages(character:getAlreadyReadPages(item:getFullType()))
            o.startPage = item:getAlreadyReadPages()
            numPages = item:getNumberOfPages()
        else
            numPages = 5
        end
        if isClient() then
            o.minutesPerPage = getServerOptions():getFloat("MinutesPerPage") or 1.0
            if o.minutesPerPage < 0.0 then o.minutesPerPage = 1.0 end
        else
            o.minutesPerPage = 2.0
        end
        local f = 1 / getGameTime():getMinutesPerDay() / 2
        time = numPages * o.minutesPerPage / f

        if(character:HasTrait("FastReader")) then
            time = time * 0.7;
        end
        if(character:HasTrait("SlowReader")) then
            time = time * 1.3;
        end

        o.maxTime = time
        o.maxMultiplier = getMultiplier(o.book)
        o.pageTimer = 0

    elseif character:getStats():getEndurance() < 1 then
        o.maxTime = (1 - character:getStats():getEndurance()) * 16000
    else
        o.useProgressBar = false
        o.maxTime = -1
    end

    o.caloriesModifier = 0.5
    o.loopedAction = not o.book
    o.ignoreHandsWounds = true
    
    return o
end


function ISSitOnChairAction:restoreMovements()
    self.character:setIgnoreAimingInput(false)
    UIManager.getSpeedControls():SetCurrentGameSpeed(1)
end


function ISSitOnChairAction:readingStart()
    if not self.book then
        return
    end
    if self.startPage then
        self:setCurrentTime(self.maxTime * (self.startPage / self.book:getNumberOfPages()))
    end
    self.book:setJobType(getText("ContextMenu_Read") ..' '.. self.book:getName())
    self.book:setJobDelta(0.0)

    if (self.book:getType() == "Newspaper") then
        self:setAnimVariable("ReadType", "newspaper")
    else
        self:setAnimVariable("ReadType", "book")
    end
    self:setActionAnim(CharacterActionAnims.Read)
    self:setOverrideHandModels(nil, self.book)
    self.character:setReading(true)
    
    self.character:reportEvent("EventRead")

    if not SkillBook[self.book:getSkillTrained()] then
        self.stats = {}
        self.stats.boredom = self.character:getBodyDamage():getBoredomLevel()
        self.stats.unhappyness = self.character:getBodyDamage():getUnhappynessLevel()
        self.stats.stress = self.character:getStats():getStress()
    end

    if SkillBook[self.book:getSkillTrained()] then
        self.character:playSound("OpenBook")
    else
        self.character:playSound("OpenMagazine")
    end
end


function ISSitOnChairAction:reading()
    if not self.book then
        return
    end

    self.pageTimer = self.pageTimer + getGameTime():getMultiplier()
    self.book:setJobDelta(self:getJobDelta())

    if self.book:getNumberOfPages() > 0 then
        local pagesRead = math.floor(self.book:getNumberOfPages() * self:getJobDelta())
        self.book:setAlreadyReadPages(pagesRead)
        if self.book:getAlreadyReadPages() > self.book:getNumberOfPages() then
            self.book:setAlreadyReadPages(self.book:getNumberOfPages())
        end
        self.character:setAlreadyReadPages(self.book:getFullType(), self.book:getAlreadyReadPages())
    end
    if SkillBook[self.book:getSkillTrained()] then
        if self.book:getLvlSkillTrained() > self.character:getPerkLevel(SkillBook[self.book:getSkillTrained()].perk) + 1 or self.character:HasTrait("Illiterate") then
            if self.pageTimer >= 200 then
                self.pageTimer = 0
                local txtRandom = ZombRand(3)
                if txtRandom == 0 then
                    self.character:Say(getText("IGUI_PlayerText_DontGet"))
                elseif txtRandom == 1 then
                    self.character:Say(getText("IGUI_PlayerText_TooComplicated"))
                else
                    self.character:Say(getText("IGUI_PlayerText_DontUnderstand"))
                end
                if self.book:getNumberOfPages() > 0 then
                    self.character:setAlreadyReadPages(self.book:getFullType(), 0)
                    self:forceStop()
                end
            end
        elseif self.book:getMaxLevelTrained() < self.character:getPerkLevel(SkillBook[self.book:getSkillTrained()].perk) + 1 then
            if self.pageTimer >= 200 then
                self.pageTimer = 0
                local txtRandom = ZombRand(2)
                if txtRandom == 0 then
                    self.character:Say(getText("IGUI_PlayerText_KnowSkill"))
                else
                    self.character:Say(getText("IGUI_PlayerText_BookObsolete"))
                end
            end
        else
            checkMultiplier(self)
        end
    end

    -- Playing with longer day length reduces the effectiveness of morale-boosting
    -- literature, like Comic Book.
    local bodyDamage = self.character:getBodyDamage()
    local stats = self.character:getStats()
    if self.stats and (self.book:getBoredomChange() < 0.0) then
        if bodyDamage:getBoredomLevel() > self.stats.boredom then
            bodyDamage:setBoredomLevel(self.stats.boredom)
        end
    end
    if self.stats and (self.book:getUnhappyChange() < 0.0) then
        if bodyDamage:getUnhappynessLevel() > self.stats.unhappyness then
            bodyDamage:setUnhappynessLevel(self.stats.unhappyness)
        end
    end
    if self.stats and (self.book:getStressChange() < 0.0) then
        if stats:getStress() > self.stats.stress then
            stats:setStress(self.stats.stress)
        end
    end
end


function ISSitOnChairAction:readingStop()
    if not self.book then
        return
    end
    if self.book:getNumberOfPages() > 0 and self.book:getAlreadyReadPages() >= self.book:getNumberOfPages() then
        self.book:setAlreadyReadPages(self.book:getNumberOfPages())
    end
    self.character:setReading(false)
    self.book:setJobDelta(0.0)
    if SkillBook[self.book:getSkillTrained()] then
        self.character:playSound("CloseBook")
    else
        self.character:playSound("CloseMagazine")
    end
    ISBaseTimedAction.stop(self)
end



function ISSitOnChairAction:readingPerform()
    if not self.book then
        return
    end
    self.character:setReading(false)
    self.book:getContainer():setDrawDirty(true)
    self.book:setJobDelta(0.0)
    if self.book:getTeachedRecipes() and not self.book:getTeachedRecipes():isEmpty() then
        self.character:getAlreadyReadBook():add(self.book:getFullType())
    end
    if not SkillBook[self.book:getSkillTrained()] then
        self.character:ReadLiterature(self.book)
    elseif self.book:getAlreadyReadPages() >= self.book:getNumberOfPages() then
        self.book:setAlreadyReadPages(0)
    end
    if SkillBook[self.book:getSkillTrained()] then
        self.character:playSound("CloseBook")
    else
        self.character:playSound("CloseMagazine")
    end
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end