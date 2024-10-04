local ScoreSystemContainer = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystemContainer")
local ShortLogicalNote = require("sphere.models.RhythmModel.LogicEngine.ShortLogicalNote")

local base_load = ScoreSystemContainer.load
function ScoreSystemContainer:load()
        base_load(self)
        self.hits = { columns = {}, hitDelta = {},  noteTime = {} }
end

local base_receive = ScoreSystemContainer.receive
function ScoreSystemContainer:receive(event)
        base_receive(self, event)

        if event.name ~= "NoteState" then
               return
        end

        if (event.noteType == "ShortNote" and event.newState == "passed") or (event.noteType == "LongNote" and event.newState == "startPassedPressed") then
                local time = event.currentTime * 1000
                local hit_delta = event.deltaTime * 1000
                table.insert(self.hits.columns, tonumber(event.noteIndexType:match("%d+$")) - 1)
                table.insert(self.hits.hitDelta, hit_delta)
                table.insert(self.hits.noteTime, time - hit_delta)
        end
end

local scoreEvent = {
	name = "NoteState",
	noteType = "ShortNote",
}
function ShortLogicalNote:switchState(newState)
        local oldState = self.state
        self.state = newState

        if not self.isScorable then
            return
        end

        local timings = self.logicEngine.timings
        local timeRate = self.logicEngine:getTimeRate()
        local eventTime = self:getEventTime()
        local noteTime = self:getNoteTime()

        local lastTime = self:getLastTimeFromConfig(timings.ShortNote)
        local time = noteTime + lastTime * timeRate

        local currentTime = math.min(eventTime, time)
        local deltaTime = currentTime == time and lastTime or (currentTime - noteTime) / timeRate

        scoreEvent.noteIndex = self.index  -- required for tests
        scoreEvent.noteIndexType = self.column
        scoreEvent.currentTime = currentTime
        scoreEvent.deltaTime = deltaTime
        scoreEvent.timeRate = timeRate
        scoreEvent.notesCount = self.logicEngine.notesCount
        scoreEvent.oldState = oldState
        scoreEvent.newState = newState
        self.logicEngine:sendScore(scoreEvent)

        if not self.pressedTime and newState == "passed" then
            self.pressedTime = currentTime
        end
        if self.pressedTime and newState ~= "passed" then
            self.pressedTime = nil
        end
end
