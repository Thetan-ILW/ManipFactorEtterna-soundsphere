if not arg then
        return
end

local ResultView = require("ui.views.ResultView")
local Layout = require("ui.views.ResultView.Layout")
local gfx_util = require("gfx_util")
local spherefonts = require("sphere.assets.fonts")

local base_update_judgements = ResultView.updateJudgements

local function manipFactorString(total, left, right)
        return ("Manip factor: %i%% | L: %i%% R: %i%%"):format(total * 100, left * 100, right * 100)
end

function ResultView:updateJudgements()
        base_update_judgements(self)

        local manip_factor = require("manip_factor")
        local score_system = self.game.rhythmModel.scoreEngine.scoreSystem

        if score_system.hits then
                self.manipStr = manipFactorString(manip_factor(score_system.hits))
                return
        end

        self.manipStr = nil
end

local base_draw = ResultView.draw

local x_indent = 20

function ResultView:draw()
	base_draw(self)

        local font = spherefonts.get("Noto Sans", 32)
        local w, h = Layout:move("graphs")

        local label = self.manipStr

        if not label then
                return
        end

	local rw, rh = font:getWidth(label), font:getHeight()
	love.graphics.setColor(0, 0, 0, 0.7)
	love.graphics.rectangle("fill", w - rw - x_indent - 5, 5, rw + x_indent, rh, 5, 5)
	love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(font)
	gfx_util.printFrame(label, -x_indent / 2 - 5, 5, w, h, "right", "top")

end
