--!native
local constants = require(script.Parent.Parent.Parent.private.constants)

local ExistingPaths = {}
local FilePath = {}
FilePath.__metatable = "This metatable is locked!"
local function get_raw_dir(path: string): {string}
    return string.split(string.gsub(path, '\n\t\0', ''), '/')--remove null-terminated strings!
end

local function make_file_path<T>(filesContainer: {}, path: T, source: string): T
    local file = FilePath.new(path, source)
    filesContainer[path] = file
    return file
end

local function find_path(file_paths: {string}, make_file: boolean?): any
    local cur_file = ExistingPaths[file_paths[1]]
    if cur_file then
        for n = 2, #file_paths do
            local container, source = cur_file._files, cur_file._source
            local sub_path = file_paths[n]
            if not sub_path then
                break
            end
            cur_file = cur_file._files[sub_path]
            if not cur_file and make_file then
                cur_file = make_file_path(container, sub_path, source)
            elseif not make_file then
                break
            end
        end
    end
    return cur_file
end

function FilePath:__tostring()
    return tostring(self._value)
end

function FilePath:__index(_key: string): any
    error("cannot index a file path", 3)
end

function FilePath:__newindex(_key: string, _value: any)
    error("cannot assign values to a file path", 3)
end

function FilePath.new<T>(path: T, _fileParent: string?): T
    local file_paths = get_raw_dir(path)
    assert(#file_paths[1] > 0, "ancestry path cannot be an empty-string")
    local path_count = #file_paths
    for m = path_count, 1, -1 do
        if #file_paths[m] <= 0 then
            table.remove(file_paths, m)
        end
    end
    local existing_path = find_path(path)
    if existing_path then
        return existing_path
    end 
    local cursor = file_paths[#file_paths]
    local is_file = #string.sub(cursor, (select(2, string.find(cursor, '^[^.]+')) or 0)+2) > 0

    local self = {
        _source = file_paths[1] :: string,
        _files = {} :: {[string]: string},
        _parent = _fileParent :: string,
        _value = if is_file then constants.Placeholders.NEVER else constants.Placeholders.EMPTY :: any,
        _is_file = is_file,
    }
    local cur_file = self
    for n = 2, path_count do
        local sub_path = file_paths[n]
        if not sub_path then
            break
        end
        local sub_file = FilePath.new(sub_path, cur_file._source)
        cur_file._files[sub_path] = sub_file
        cur_file = sub_file
    end
    setmetatable(self, FilePath)
    ExistingPaths[self._source] = self
    return self
end

function FilePath.remove(path: string)
    local foundFile = 
end

function FilePath.read_file(path: string): any
    local file_paths = get_raw_dir(path)
    return assert(find_path(file_paths, false), `{file_paths[#file_paths]} does not exist!`)._value
end

function FilePath.write_file(path: string, value: any)
    local file_paths = get_raw_dir(path)
    local cur_file = find_path(file_paths, true)
    assert(#string.sub(cur_file._source, (select(2, string.find(cur_file._source, '^[^.]+')) or 0)+2) > 0, "cannot write a file without an extension")
    if type(value) == "nil" then
        value = constants.Placeholders.NEVER
    end
    cur_file._value = value
end
FilePath.DynamicPath = FilePath.new('tmp/')

function FilePath()
    
end

return table.freeze(FilePath)