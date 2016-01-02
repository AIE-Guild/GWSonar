--[[-----------------------------------------------------------------------

The MIT License (MIT)

Copyright (c) 2015, Mark Rogaski

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]]-----------------------------------------------------------------------

--[[-----------------------------------------------------------------------

Global Variables

--]]-----------------------------------------------------------------------

GWSonar = {
    serial = 0,
    timestamp = 0,
    token = '',
    sample = {},
};


--[[-----------------------------------------------------------------------

Local Functions

--]]-----------------------------------------------------------------------

--- Write a message to the default chat frame.
-- @param ... A list of the string and arguments for substitution using the syntax of string.format.
local function Write(...)
    local msg = string.format(unpack({...}))
    DEFAULT_CHAT_FRAME:AddMessage('|cff0bda51GWSonar:|r ' .. msg)
end


--- Minimum/maximum values from a table.
-- @param t A table of numeric values.
-- @return (min, max) - Minimum value, maximum value.
--
-- Taken from http://lua-users.org/wiki/SimpleStats .
--
function MinMax(t)
    local max = -math.huge
    local min = math.huge

    for k, v in pairs(t) do
        if type(v) == 'number' then
            max = math.max(max, v)
            min = math.min(min, v)
        end
    end

    return min, max
end


--- Mean value from a table.
-- @param t A table of numeric values.
--
-- Taken from http://lua-users.org/wiki/SimpleStats .
--
function Mean(t)
    local sum = 0
    local count= 0

    for k, v in pairs(t) do
        if type(v) == 'number' then
            sum = sum + v
            count = count + 1
        end
    end

    return (sum / count)
end


--[[-----------------------------------------------------------------------

API Functions

--]]-----------------------------------------------------------------------
--
--- Send a ping request.
local function Ping()

    GWSonar.serial = GWSonar.serial + 1
    GWSonar.sample = {}
    local guid = UnitGUID('player')
    local token = string.format('REQUEST/%s/%04X', guid, GWSonar.serial)
    
    GWSonar.timestamp = GetTime()
    GreenWallAPI.SendMessage('GWSonar', token)
    return token

end


--- Generate and process ping responses.
-- @param addon The sending addon
-- @param sender The sending player
-- @param message The message data
-- @param echo True if the player is the sender
-- @param guild True if the player is in the same co-guild as the sender 
local function PingHandler(addon, sender, message, echo, guild)

    if addon == 'GWSonar' and not echo then
    
        local op, guid, serial = strsplit('/', message)
        if op == 'REQUEST' then
    
            -- Send the response
            local token = string.format('RESPONSE/%s/%s', guid, serial)
            GreenWallAPI.SendMessage('GWSonar', token)
    
        elseif op == 'RESPONSE' then
    
            -- Record response times
            local delta = GetTime() - GWSonar.timestamp
            table.insert(GWSonar.sample, delta)
            Write('ping response received from %s, %.3f second(s).', sender, delta)
    
        end

    end

end


--[[-----------------------------------------------------------------------

UI Callbacks

--]]-----------------------------------------------------------------------

function GWSonar_OnLoad(self)

    -- Register for events
    self:RegisterEvent('ADDON_LOADED')
    self:RegisterEvent('PLAYER_ENTERING_WORLD')

end

function GWSonar_OnEvent(self, event, ...)
    function apiAvailable()
        function testAPI()
            -- Raises and exception of GreenWall is loaded or is pre-1.7.
            assert(IsAddOnLoaded('GreenWall'))
            return GreenWallAPI.version
        end
        
        -- Catch any exceptions
        local found, version = pcall(testAPI)
        
        return found and version >= 1
    end

    if event == 'ADDON_LOADED' and select(1, ...) == 'GWSonar' then
        
        Write('v%s loaded.', GetAddOnMetadata('GWSonar', 'Version'))
    
    elseif event == 'PLAYER_ENTERING_WORLD' then  
    
        -- Check to ensure GreenWall is loaded and the installed version 
        -- supports the API.
        if apiAvailable() then
        
            -- Register slash command handler
            SLASH_GWSONAR1 = '/gwsonar'
            function SlashCmdList.GWSONAR(msg, editbox)
         
                if msg == 'ping' then
         
                    local token = Ping()
                    Write('ping request sent.')
         
                elseif msg == 'stats' then
         
                    local n = #GWSonar.sample
                    if n > 0 then
                        local min, max = MinMax(GWSonar.sample)
                        local avg = Mean(GWSonar.sample)
                        Write('%d response(s); min/avg/max = %.3f/%.3f/%.3f', n, min, avg, max)
                    else
                        Write('No responses')
                    end
         
                end
         
            end
            
            -- Install message handler
            GreenWallAPI.AddMessageHandler(PingHandler, 'GWSonar', 0)
            Write('installed ping handler.')
        
        else
        
            Write('GreenWall API unavailable, addon disabled.')
        
        end
    
    end

end

