--!native
local Set = {}
local SetMT = {__index = Set}
export type Set = {
    [string]: boolean,
}
function Set:__add(otherSet: Set) -- union
    for k in pairs(otherSet) do
        self[k] = true
    end
    for k in pairs(self) do
        otherSet[k] = true
    end
    return self
end

function Set:__sub(otherSet: Set) -- subtract
    for k in pairs(otherSet) do
        self[k] = true
    end
    for k in pairs(self) do
        otherSet[k] = nil
    end
    return self
end

function Set:__mul(fromSet: Set) -- intersect
    local set = {}
    for k in pairs(fromSet) do
        if self[k] ~= nil then
            set[#set+1] = k
        end
    end
    return Set.new(set)
end

function Set:has(item: string): boolean
    return self[item] ~= nil
end

function Set.new(items: {string}?)
    local self = table.clone(items or {})
    setmetatable(self, SetMT)
    return self
end

return Set.new