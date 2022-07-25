require('luacov')
local assert = require('assert')
local flatten = require('table.flatten')
-- constants
local LightUD = require('assert.lightuserdata')
local Func = function()
end
local Coro = coroutine.create(Func)
local Empty = {}

-- test that flatten the table
local tbl = {
    [true] = false,
    [5] = {
        idx = 5,
    },
    foo = {
        bar = {
            baz = {
                str = 'str-value',
                coro = Coro,
                light = LightUD,
            },
            num = 123,
        },
        truthy = true,
        empty = Empty,
    },
    falsy = false,
    func = Func,
}
tbl.circular = {
    ref = tbl,
    description = 'this table contains this table itself, but circular references are ignored.',
}
local res = flatten(tbl)
assert.equal(res, {
    ['true'] = false,
    ['5.idx'] = 5,
    ['circular.description'] = 'this table contains this table itself, but circular references are ignored.',
    ['foo.bar.baz.str'] = 'str-value',
    ['foo.bar.baz.coro'] = Coro,
    ['foo.bar.baz.light'] = LightUD,
    ['foo.bar.num'] = 123,
    ['foo.truthy'] = true,
    ['foo.empty'] = Empty,
    ['falsy'] = false,
    ['func'] = Func,
})

-- test that flatten the table to 3 depth
res = flatten(tbl, 3)
assert.equal(res, {
    ['true'] = false,
    ['5.idx'] = 5,
    ['circular.description'] = 'this table contains this table itself, but circular references are ignored.',
    ['foo.bar.baz'] = {
        str = 'str-value',
        coro = Coro,
        light = LightUD,
    },
    ['foo.bar.num'] = 123,
    ['foo.truthy'] = true,
    ['foo.empty'] = Empty,
    ['falsy'] = false,
    ['func'] = Func,
})

-- test that flatten the empty-table
res = flatten({}, 3)
assert.equal(res, {})

-- test that throws error if tbl is not table
local err = assert.throws(flatten, true)
assert.match(err, 'tbl must be table')

-- test that throws error if maxdepth is not integer
err = assert.throws(flatten, {}, true)
assert.match(err, 'maxdepth must be integer')

-- test that throws error if encoder is not function
err = assert.throws(flatten, {}, nil, true)
assert.match(err, 'encoder must be function')

-- test that throws error if setter is not function
err = assert.throws(flatten, {}, nil, nil, true)
assert.match(err, 'setter must be function')

-- test that throws error if key2str is not function
err = assert.throws(flatten, {}, nil, nil, nil, true)
assert.match(err, 'key2str must be function')

-- test that throws error if encoder returns non-string key
err = assert.throws(flatten, {
    foo = {
        bar = 'baz',
    },
}, nil, function()
end)
assert.match(err, 'key must be string')

-- test that throws error if key2str returns non-string key
err = assert.throws(flatten, {
    foo = {
        bar = 'baz',
    },
}, nil, nil, nil, function()
    return true
end)
assert.match(err, 'key2str must returns a string')

