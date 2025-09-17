local common = {}

-- Font management
function common.loadFonts()
    local fonts = {}
    fonts.title = love.graphics.newFont("assets/fonts/IBM_VGA_8x16.ttf", 32)
    fonts.button = love.graphics.newFont("assets/fonts/IBM_VGA_8x16.ttf", 16)

    -- Set fonts to use nearest-neighbor filtering for a crisp retro look
    fonts.title:setFilter("nearest", "nearest")
    fonts.button:setFilter("nearest", "nearest")

    return fonts
end

-- Canvas setup
function common.setupCanvas(settings)
    local canvas = settings.getCanvas()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.75, 0.85, 0.65) -- LCD green background
    return canvas
end

-- Button widget
local Button = {}
Button.__index = Button

function Button:new(x, y, width, height, text)
    local instance = setmetatable({}, Button)
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height
    instance.text = text
    instance.selected = false
    instance.hovered = false
    return instance
end

function Button:draw(fonts, isSelected, isHovered)
    local isSelected = isSelected or self.selected
    local isHovered = isHovered or self.hovered

    -- Pixel-perfect 1px border
    love.graphics.setLineWidth(1)
    love.graphics.setColor(0.2, 0.2, 0.2)
    if isSelected or isHovered then
        -- Inverted fill with 2px pop effect when selected
        local pop = isSelected and 2 or 0
        love.graphics.rectangle('fill', self.x - pop, self.y - pop, self.width + 2*pop, self.height + 2*pop)
        love.graphics.setColor(0.75, 0.85, 0.65)
    else
        love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
        love.graphics.setColor(0.2, 0.2, 0.2)
    end

    local font = fonts.button or love.graphics.getFont()
    love.graphics.setFont(font)
    local textWidth = font:getWidth(self.text)
    local textX = self.x + (self.width - textWidth) / 2
    local textY = self.y + (self.height - font:getHeight()) / 2
    love.graphics.print(self.text, textX, textY)
end

function Button:isMouseOver(mouseX, mouseY)
    return mouseX >= self.x and mouseX <= self.x + self.width and
           mouseY >= self.y and mouseY <= self.y + self.height
end

function Button:getBounds()
    return {
        x = self.x,
        y = self.y,
        width = self.width,
        height = self.height
    }
end

common.Button = Button

-- Slider widget
local Slider = {}
Slider.__index = Slider

function Slider:new(x, y, width, height, value, min, max)
    local instance = setmetatable({}, Slider)
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height
    instance.value = value or 0
    instance.min = min or 0
    instance.max = max or 1
    instance.selected = false
    instance.hovered = false
    return instance
end

function Slider:draw(fonts, isSelected, isHovered)
    local isSelectedState = isSelected or self.selected
    local isHoveredState = isHovered or self.hovered
    local highlight = isSelectedState or isHoveredState
    local dark = {0.2, 0.2, 0.2}
    local accent = {0.9, 1.0, 0.7}

    love.graphics.setLineWidth(1)
    love.graphics.setColor(dark)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    local range = self.max - self.min
    local normalized = 0
    if range > 0 then
        normalized = (self.value - self.min) / range
    end
    normalized = math.max(0, math.min(1, normalized))

    local step = 0.1
    local stepped = math.floor(normalized / step + 0.5) * step
    stepped = math.max(0, math.min(1, stepped))

    local fillWidth = stepped * self.width
    local fillPixels = math.max(0, fillWidth - 2)

    if fillPixels > 0 then
        love.graphics.setColor(highlight and accent or dark)
        love.graphics.rectangle('fill', self.x + 1, self.y + 1, fillPixels, self.height - 2)
    end

    local knobWidth = 8
    local knobHeight = self.height + 4
    local knobX = self.x + normalized * self.width - knobWidth / 2
    knobX = math.max(self.x - knobWidth / 2, math.min(self.x + self.width - knobWidth / 2, knobX))
    local knobY = self.y - 2

    love.graphics.setColor(highlight and accent or dark)
    love.graphics.rectangle('fill', knobX, knobY, knobWidth, knobHeight)
end

function Slider:isMouseOver(mouseX, mouseY)
    local knobWidth = 8
    local knobHeight = self.height + 6

    local range = self.max - self.min
    local normalized = 0
    if range > 0 then
        normalized = (self.value - self.min) / range
    end
    normalized = math.max(0, math.min(1, normalized))

    local knobX = self.x + normalized * self.width - knobWidth / 2
    knobX = math.max(self.x - knobWidth / 2, math.min(self.x + self.width - knobWidth / 2, knobX))
    local knobY = self.y - 3

    return (mouseX >= self.x and mouseX <= self.x + self.width and
            mouseY >= self.y and mouseY <= self.y + self.height) or
           (mouseX >= knobX and mouseX <= knobX + knobWidth and
            mouseY >= knobY and mouseY <= knobY + knobHeight)
end

function Slider:setValueFromMouse(x)
    if self.width <= 0 then
        return
    end

    local range = self.max - self.min
    if range <= 0 then
        self.value = self.min
        return
    end

    local normalized = (x - self.x) / self.width
    normalized = math.max(0, math.min(1, normalized))
    self.value = self.min + normalized * range
end

function Slider:getValue()
    return self.value
end

function Slider:setValue(value)
    if self.max > self.min then
        self.value = math.min(self.max, math.max(self.min, value))
    else
        self.value = self.min
    end
end

function Slider:getBounds()
    return {
        x = self.x,
        y = self.y,
        width = self.width,
        height = self.height
    }
end

common.Slider = Slider

-- Toggle widget
local Toggle = {}
Toggle.__index = Toggle

function Toggle:new(x, y, width, height, value, options)
    local instance = setmetatable({}, Toggle)
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height
    instance.value = value or 1
    instance.options = options or {'ON', 'OFF'}
    instance.selected = false
    instance.hovered = false
    return instance
end

function Toggle:draw(fonts, isSelected, isHovered)
    local isSelectedState = isSelected or self.selected
    local isHoveredState = isHovered or self.hovered
    local highlight = isSelectedState or isHoveredState
    local dark = {0.2, 0.2, 0.2}
    local accent = {0.9, 1.0, 0.7}

    love.graphics.setLineWidth(1)
    if isSelectedState then
        love.graphics.setColor(dark)
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    end

    love.graphics.setColor(dark)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    if highlight then
        love.graphics.setColor(accent)
        love.graphics.rectangle("line", self.x - 1, self.y - 1, self.width + 2, self.height + 2)
    end

    local font = fonts.button or love.graphics.getFont()
    love.graphics.setFont(font)
    love.graphics.setColor(highlight and accent or dark)
    local text = self.options[self.value]
    local textWidth = font:getWidth(text)
    local textX = self.x + (self.width - textWidth) / 2
    local textY = self.y + (self.height - font:getHeight()) / 2
    love.graphics.print(text, textX, textY)

    if highlight then
        love.graphics.setColor(accent)
        local midY = self.y + self.height / 2
        love.graphics.polygon('fill',
            self.x - 14, midY,
            self.x - 6, midY - 5,
            self.x - 6, midY + 5
        )
        love.graphics.polygon('fill',
            self.x + self.width + 14, midY,
            self.x + self.width + 6, midY - 5,
            self.x + self.width + 6, midY + 5
        )
    end
end

function Toggle:isMouseOver(mouseX, mouseY)
    return mouseX >= self.x and mouseX <= self.x + self.width and
           mouseY >= self.y and mouseY <= self.y + self.height
end

function Toggle:next()
    self.value = self.value + 1
    if self.value > #self.options then
        self.value = 1
    end
end

function Toggle:previous()
    self.value = self.value - 1
    if self.value < 1 then
        self.value = #self.options
    end
end

function Toggle:getValue()
    return self.value
end

function Toggle:setValue(value)
    local clamped = math.max(1, math.min(#self.options, value))
    self.value = clamped
end

function Toggle:getValueText()
    return self.options[self.value]
end

function Toggle:getBounds()
    return {
        x = self.x,
        y = self.y,
        width = self.width,
        height = self.height
    }
end

common.Toggle = Toggle

-- State Manager
local StateManager = {}
StateManager.__index = StateManager

function StateManager:new()
    local instance = setmetatable({}, StateManager)
    instance.selection = 1
    return instance
end

function StateManager:getSelection()
    return self.selection
end

function StateManager:setSelection(selection)
    self.selection = selection
end

function StateManager:moveUp(max)
    self.selection = self.selection - 1
    if self.selection < 1 then
        self.selection = max
    end
end

function StateManager:moveDown(max)
    self.selection = self.selection + 1
    if self.selection > max then
        self.selection = 1
    end
end

common.StateManager = StateManager

-- Focus Manager
local FocusManager = {}
FocusManager.__index = FocusManager

function FocusManager:new(items)
    local instance = setmetatable({}, FocusManager)
    instance.items = items or {}
    instance.focusIndex = 1
    return instance
end

function FocusManager:addItem(item)
    table.insert(self.items, item)
end

function FocusManager:moveUp()
    self.focusIndex = self.focusIndex - 1
    if self.focusIndex < 1 then
        self.focusIndex = #self.items
    end
end

function FocusManager:moveDown()
    self.focusIndex = self.focusIndex + 1
    if self.focusIndex > #self.items then
        self.focusIndex = 1
    end
end

function FocusManager:getFocusedItem()
    return self.items[self.focusIndex]
end

function FocusManager:getFocusIndex()
    return self.focusIndex
end

function FocusManager:setFocusIndex(index)
    if index >= 1 and index <= #self.items then
        self.focusIndex = index
    end
end

function FocusManager:getItemCount()
    return #self.items
end

common.FocusManager = FocusManager

-- Helper function to check if mouse is over an area
function common.isMouseOver(x, y, area)
    return x >= area.x and x <= area.x + area.width and
           y >= area.y and y <= area.y + area.height
end

-- Helper function to safely play a sound
function common.playSound(sounds, soundName)
    if sounds and sounds[soundName] then
        sounds[soundName]:stop()
        sounds[soundName]:play()
    end
end

return common