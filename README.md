# lua-table-flatten

[![test](https://github.com/mah0x211/lua-table-flatten/actions/workflows/test.yml/badge.svg)](https://github.com/mah0x211/lua-table-flatten/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/mah0x211/lua-table-flatten/branch/master/graph/badge.svg)](https://codecov.io/gh/mah0x211/lua-table-flatten)


flatten a table into a table of specified depth.


## Installation

```sh
luarocks install table-flatten
```

---

## res = flatten( tbl [, maxdepth [, encoder [, setter [, key2str]]]] )

returns a flattened table.

**Parameters**

- `tbl:table`: target table.
- `maxdepth:integer`: maximum depth to flatten. `nil` or `0` or less are unlimited. (default: `0`)
- `encoder:function`: function that encode the `key` and `value` to the string.
- `setter:function`: function that sets the `key` and `value` pair to result table.
- `key2str:function`: function that generates `key` from table-name/field-key pair.

**Returns**

- `res:table`: a flattened table.


## encoder function

the declaration of the `encoder` function is as follows;

### key, val = encoder( key, val )

**Parameters**

- `key:string`: a key string in dot notation.
- `val:any`: a value of `key`.

**Returns**

- `key:any`: used as a `key` of flattened table.
- `val:any`: used as a value of `key`.


## setter function

the declaration of the `setter` function is as follows;

### setter( res, key, val )

**Parameters**

- `res:table`: a result table.
- `key:string`: a key string.
- `val:any`: a value of `key`.


## key2str function

the declaration of the `key2str` function is as follows;

### key = key2str( tname, key )

**Parameters**

- `tname:string`: a table name, or `nil` if a root table.
- `key:any`: a key.

**Returns**

- `key:string?`: used as a `key` of current field. if `nil`, ignore the field-value.


## Usage

```lua
local flatten = require('table.flatten')
-- you must install dump module from https://github.com/mah0x211/lua-dump 
-- or luarocks install dump
local dump = require('dump') 

local tbl = {
    foo = {
        bar = {
            baz = {
                str = 'str-value',
                coro = coroutine.create(function()end)
            },
            num = 123,
        },
        truthy = true,
        empty = {}
    },
    falsy = false,
    func = function() end
}
tbl.circular = {
    description = 'this table contains this table itself, but circular references are ignored.',
    ref = tbl,
}

for depth = 0, 4 do
    print( 'depth#' .. depth .. ' ' .. dump( flatten( tbl, depth ) ) )
end

-- depth#0 {
--     ["circular.description"] = "this table contains this table itself, but circular references are ignored.",
--     ["foo.bar.baz.coro"] = "thread: 0x0004f758",
--     ["foo.bar.baz.str"] = "str-value",
--     ["foo.bar.num"] = 123,
--     ["foo.empty"] = {},
--     ["foo.truthy"] = true,
--     falsy = false,
--     func = "function: 0x0004f7c8"
-- }
-- depth#1 {
--     circular = {
--         description = "this table contains this table itself, but circular references are ignored.",
--         ref = {
--             circular = "<Circular table: 0x0004f7e8>",
--             falsy = false,
--             foo = {
--                 bar = {
--                     baz = {
--                         coro = "thread: 0x0004f758",
--                         str = "str-value"
--                     },
--                     num = 123
--                 },
--                 empty = {},
--                 truthy = true
--             },
--             func = "function: 0x0004f7c8"
--         }
--     },
--     falsy = false,
--     foo = {
--         bar = {
--             baz = {
--                 coro = "thread: 0x0004f758",
--                 str = "str-value"
--             },
--             num = 123
--         },
--         empty = {},
--         truthy = true
--     },
--     func = "function: 0x0004f7c8"
-- }
-- depth#2 {
--     ["circular.description"] = "this table contains this table itself, but circular references are ignored.",
--     ["foo.bar"] = {
--         baz = {
--             coro = "thread: 0x0004f758",
--             str = "str-value"
--         },
--         num = 123
--     },
--     ["foo.empty"] = {},
--     ["foo.truthy"] = true,
--     falsy = false,
--     func = "function: 0x0004f7c8"
-- }
-- depth#3 {
--     ["circular.description"] = "this table contains this table itself, but circular references are ignored.",
--     ["foo.bar.baz"] = {
--         coro = "thread: 0x0004f758",
--         str = "str-value"
--     },
--     ["foo.bar.num"] = 123,
--     ["foo.empty"] = {},
--     ["foo.truthy"] = true,
--     falsy = false,
--     func = "function: 0x0004f7c8"
-- }
-- depth#4 {
--     ["circular.description"] = "this table contains this table itself, but circular references are ignored.",
--     ["foo.bar.baz.coro"] = "thread: 0x0004f758",
--     ["foo.bar.baz.str"] = "str-value",
--     ["foo.bar.num"] = 123,
--     ["foo.empty"] = {},
--     ["foo.truthy"] = true,
--     falsy = false,
--     func = "function: 0x0004f7c8"
-- }
```
