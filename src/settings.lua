local settings = {
    sfxVolume = 1.0,
    crtEffect = "CLASSIC",
    selectedOption = 1,
    crtPresets = {
        OFF = {
            enabled = true,
            curvature = 15.0,
            scanlines = 0.0,
            vignette = 0.05
        },
        CLASSIC = {
            enabled = true,
            curvature = 10.0,
            scanlines = 800.0,
            vignette = 0.1
        },
        HEAVY = {
            enabled = true,
            curvature = 5.0,
            scanlines = 2000.0,
            vignette = 0.2
        }
    }
}

local shader = nil
local canvas = nil

-- Set default sound volume and sounds table if not already defined
if settings.sfxVolume == nil then settings.sfxVolume = 0.5 end
if settings.sounds == nil then settings.sounds = {} end

function settings.save()
    local file = io.open("settings.txt", "w")
    if file then
        file:write(string.format("sfxVolume:%f\n", settings.sfxVolume))
        file:write(string.format("crtEffect:%s\n", settings.crtEffect))
        file:close()
    end
end

function settings.load()
    local file = io.open("settings.txt", "r")
    if file then
        for line in file:lines() do
            local key, value = line:match("(%w+):(.+)")
            if key == "sfxVolume" then
                settings.sfxVolume = tonumber(value)
            elseif key == "crtEffect" then
                settings.crtEffect = value
            end
        end
        file:close()
    end
end

function settings.initializeShader()
    -- Load and setup CRT shader
    shader = love.graphics.newShader([[
        extern vec2 screen;
        extern float curvature;
        extern float scanlines;
        extern float vignette_intensity;

        vec2 curve(vec2 uv)
        {
            uv = (uv - 0.5) * 2.0;
            uv *= 1.1;
            vec2 offset = uv.yx / vec2(screen.y/screen.x, 1.0);
            uv.x *= 1.0 + pow((abs(offset.y) / curvature), 2.0);
            uv.y *= 1.0 + pow((abs(offset.x) / curvature), 2.0);
            uv = (uv / 2.0) + 0.5;
            return uv;
        }

        vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
        {
            vec2 curved_uv = curve(uv);

            if (curved_uv.x < 0.0 || curved_uv.x > 1.0 || curved_uv.y < 0.0 || curved_uv.y > 1.0)
                return vec4(0.0, 0.0, 0.0, 1.0);

            vec4 texcolor = Texel(tex, curved_uv);

            float scanline = sin(curved_uv.y * scanlines) * 0.02;
            texcolor -= scanline;

            float vignette = length(vec2(0.5, 0.5) - curved_uv) * vignette_intensity;
            texcolor -= vignette;

            return texcolor * color;
        }
    ]])

    -- Set initial shader variables based on current preset
    settings.updateShaderValues()

    -- Create canvas for post-processing
    canvas = love.graphics.newCanvas()
end

function settings.updateShaderValues()
    local preset = settings.crtPresets[settings.crtEffect]
    if preset and preset.enabled then
        shader:send('screen', {love.graphics.getWidth(), love.graphics.getHeight()})
        shader:send('curvature', preset.curvature)
        shader:send('scanlines', preset.scanlines)
        shader:send('vignette_intensity', preset.vignette)
    end
end

function settings.getShader()
    return shader
end

function settings.getCanvas()
    return canvas
end

function settings.isCrtEnabled()
    local preset = settings.crtPresets[settings.crtEffect]
    return preset and preset.enabled
end

function settings.nextCrtEffect()
    local effects = {"OFF", "CLASSIC", "HEAVY"}
    local currentIndex = 1
    for i, effect in ipairs(effects) do
        if effect == settings.crtEffect then
            currentIndex = i
            break
        end
    end
    currentIndex = currentIndex + 1
    if currentIndex > #effects then
        currentIndex = 1
    end
    settings.crtEffect = effects[currentIndex]
    settings.updateShaderValues()
end

function settings.previousCrtEffect()
    local effects = {"OFF", "CLASSIC", "HEAVY"}
    local currentIndex = 1
    for i, effect in ipairs(effects) do
        if effect == settings.crtEffect then
            currentIndex = i
            break
        end
    end
    currentIndex = currentIndex - 1
    if currentIndex < 1 then
        currentIndex = #effects
    end
    settings.crtEffect = effects[currentIndex]
    settings.updateShaderValues()
end

function settings.updateSoundVolumes(sounds)
    for _, sound in pairs(sounds) do
        sound:setVolume(settings.sfxVolume)
    end
end

-- Add sound volume adjustment functions
function settings.increaseSfxVolume()
    settings.sfxVolume = math.min(1, settings.sfxVolume + 0.1)
    settings.updateSoundVolumes(settings.sounds)
end

function settings.decreaseSfxVolume()
    settings.sfxVolume = math.max(0, settings.sfxVolume - 0.1)
    settings.updateSoundVolumes(settings.sounds)
end

_G.increaseSfxVolume = settings.increaseSfxVolume
_G.decreaseSfxVolume = settings.decreaseSfxVolume

_G.settings = settings

return settings