--
-- Copyright (C) 2018-2022 Masatoshi Fukunaga
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
--- file-scope variables
local type = type
local next = next
local tostring = tostring
local rawequal = rawequal
local floor = math.floor
--- constants
local INF_POS = math.huge
local INF_NEG = -INF_POS

--- is_integer
--- @param n any
--- @return boolean ok
local function is_integer(n)
    return type(n) == 'number' and (n < INF_POS and n > INF_NEG) and
               rawequal(floor(n), n)
end

--- default_encoder
--- @param key any
--- @param val any
--- @return any key
--- @return any val
local function default_encoder(key, val)
    -- default do-nothing
    return key, val
end

--- default_setter
--- @param tbl table
--- @param key any
--- @param val any
local function default_setter(res, key, val)
    if type(key) ~= 'string' then
        error('key must be string')
    end
    res[key] = val
end

--- default_key2str
--- @param prefix string
--- @param key any
--- @return string
local function default_key2str(prefix, key)
    if type(key) ~= 'string' then
        key = tostring(key)
    end

    if #prefix > 0 then
        return prefix .. '.' .. key
    end
    return key
end

--- do_flatten
--- @param tbl table
--- @param encoder function
--- @param setter function
--- @param key2str function
--- @param maxdepth integer
--- @param depth integer
--- @param prefix string
--- @param circular table
--- @param res table
--- @return table res
local function do_flatten(tbl, encoder, setter, key2str, maxdepth, depth,
                          prefix, circular, res)
    local k, v = next(tbl)

    while k do
        local key = key2str(prefix, k)
        if key then
            if type(key) ~= 'string' then
                error('key2str must returns a string')
            end

            if type(v) ~= 'table' then
                setter(res, encoder(key, v))
            else
                local ref = v

                -- set value except circular referenced value
                if not circular[ref] then
                    if (maxdepth > 0 and depth >= maxdepth) then
                        -- reached to maxdepth
                        setter(res, encoder(key, v))
                    elseif not next(v) then
                        -- empty table
                        setter(res, encoder(key, v))
                    else
                        -- flatten recursively
                        circular[ref] = true
                        do_flatten(v, encoder, setter, key2str, maxdepth,
                                   depth + 1, key, circular, res)
                        circular[ref] = nil
                    end
                end
            end
        end

        k, v = next(tbl, k)
    end

    return res
end

--- flatten
--- @param tbl table
--- @param maxdepth integer
--- @param encoder function
--- @param setter function
--- @param key2str function
--- @return table res
local function flatten(tbl, maxdepth, encoder, setter, key2str)
    -- veirfy arguments
    if type(tbl) ~= 'table' then
        error('tbl must be table', 2)
    end

    if maxdepth == nil then
        maxdepth = 0
    elseif not is_integer(maxdepth) then
        error('maxdepth must be integer', 2)
    end

    -- use default encoder function
    if encoder == nil then
        encoder = default_encoder
    elseif type(encoder) ~= 'function' then
        error('encoder must be function', 2)
    end

    -- use default setter function
    if setter == nil then
        setter = default_setter
    elseif type(setter) ~= 'function' then
        error('setter must be function', 2)
    end

    -- use default key2str function
    if key2str == nil then
        key2str = default_key2str
    elseif type(key2str) ~= 'function' then
        error('key2str must be function', 2)
    end

    return do_flatten(tbl, encoder, setter, key2str, maxdepth, 1, '', {
        [tbl] = true,
    }, {})
end

return flatten
