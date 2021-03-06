-- Copyright (C) 2017-2018 by chrono

-- curl 127.1:83/shared

local shmem = ngx.shared.shmem

shmem:flush_all()

-- write

local ok, err, f

ok, err, f = shmem:set("num", 1, 0.01)
assert(ok and not f)

ok, err = shmem:add("num", 1)
assert(not ok)

ok, err, f = shmem:replace("num", 2)
assert(ok)

ok, err, f = shmem:replace("ver", 1)
assert(not ok)

ok, err = shmem:add("ver", 1, 0, 1)
assert(ok)

-- read

local v, flags = shmem:get("ver")
--ngx.say("value is ", v or "-")
--ngx.say("value is ", flags or "-")
assert(v == 1 and flags == 1)

ngx.sleep(0.2)

local v, err, stale = shmem:get_stale("num")
assert(v == 2)
--ngx.say("value is ", v or "-")
ngx.say("stale is ", stale or "-")

-- incr
local v = shmem:incr("count", 1, 0)
assert(v == 1)

local v = shmem:incr("count", 5)
assert(v == 6)

local v = shmem:incr("x", 0.1, -10)
assert(v == -9.9)
local v = shmem:incr("x", 9.9)
assert(v == 0)

-- list
local len = shmem:lpush('list', 'a')
assert(len == 1)

local len = shmem:rpush('list', 'z')

local len = shmem:llen('list')
assert(len == 2)

local v = shmem:lpop('list')
assert(v == 'a')

local v = shmem:rpop('list')
assert(v == 'z')

local v = shmem:rpop('list')
assert(not v)

-- expire

local ok, err = shmem:set("data", 100, 0.02)
--ngx.sleep(0.01)
local ttl = shmem:ttl("data")
ngx.say("ttl is : ", ttl)

ngx.sleep(0.03)
local v, _, stale = shmem:get_stale("data")
ngx.say("stale is ", stale or "-")

local ok, err = shmem:expire("data", 0.1)
local ttl = shmem:ttl("data")
ngx.say("ttl is : ", ttl)


-- others
ngx.say(shmem:get_keys())

local bytes = shmem:capacity()
assert(bytes == 1024*1024)

local bytes = shmem:free_space()
ngx.say(bytes / 1024)

ngx.say('hello ngx.shared')
