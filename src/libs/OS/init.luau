--!native
local File = require(script.File)

local random = Random.new()

local real_os = os
local os_api = {}
function os_api:__index(key: string): any
    return real_os[key]
end

local os = {
    tmp = File.DynamicPath,

    path = File.new,
    remove = File.remove,
    fread = File.read_file,
    fwrite = File.write_file,
    tmpname = function(size: number?)
        local stream = ''
        for _ = 1, (size or 16) do
            stream ..= string.char(random:NextInteger(33,122))
        end
        return stream
    end,
    execute = function()
        error("cannot run bash (unsupported)")
    end,
    exit = function()
        error("cannot run bash (unsupported)")
    end,
    setlocale = function()
        error("not native")
    end,
}
setmetatable(os, os_api)
export type os = typeof(real_os) & typeof(os)
return table.freeze(os) :: os