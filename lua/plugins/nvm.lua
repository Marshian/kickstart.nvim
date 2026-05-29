-- Standalone nvm.nvim replacement
-- Reads .nvmrc or ~/.nvm/alias/default and updates PATH accordingly
local M = {}

local nvmrc = '.nvmrc'
local alias_path = os.getenv('HOME') .. '/.nvm/alias'
local default_node = alias_path .. '/default'
local nvm_path = os.getenv('HOME') .. '/.nvm/versions/node/'

local function file_exists(name)
    local f = io.open(name, 'r')
    if f then
        io.close(f)
        return true
    end
    return false
end

local function resolve(version)
    version = string.gsub(version, '^%s*(.-)%s*$', '%1')
    local file = io.open(alias_path .. '/' .. version, 'rb')
    if not file then
        return nil
    end
    local content = file:read('*a')
    file:close()
    return content
end

local function get_version()
    local file = io.open(nvmrc, 'rb')
    if not file then
        file = io.open(default_node, 'rb')
        if not file then
            return nil
        end
    else
        file:close()
        file = io.open(default_node, 'rb')
        if not file then
            return nil
        end
    end

    local version = file:read('*a')
    file:close()

    while version and not string.match(version, '[0-9]') do
        version = resolve(version)
        if not version then
            return nil
        end
    end

    if not version then
        return nil
    end

    if string.sub(version, 1, 1) ~= 'v' then
        version = 'v' .. version
    end

    return string.gsub(version, '^%s*(.-)%s*$', '%1')
end

local function get_path(version)
    return nvm_path .. version .. '/bin/'
end

local function check_installed(version)
    return file_exists(get_path(version) .. 'node')
end

local function activate()
    local version = get_version()
    if version then
        if not check_installed(version) then
            vim.notify('Required Node.js ' .. version .. ' is not installed, please install it', vim.log.levels.ERROR)
        else
            vim.notify('Using Node.js ' .. version)
            vim.env.PATH = get_path(version) .. ':' .. vim.env.PATH
        end
    end
end

local function deactivate()
    local version = get_version()
    if version then
        vim.env.PATH = string.gsub(vim.env.PATH, get_path(version) .. ':', '')
    end
end

local function enter()
    if file_exists(nvmrc) or file_exists(default_node) then
        activate()
    end
end

local function leave()
    if file_exists(nvmrc) or file_exists(default_node) then
        deactivate()
    end
end

function M.setup()
    vim.api.nvim_create_autocmd('DirChangedPre', {
        callback = leave,
    })
    vim.api.nvim_create_autocmd('VimLeavePre', {
        callback = leave,
    })
    vim.api.nvim_create_autocmd('DirChanged', {
        callback = enter,
    })
    vim.api.nvim_create_autocmd('VimEnter', {
        callback = enter,
    })
end

return M
