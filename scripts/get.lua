local key = KEYS[1]
local read_key = get_key(key)
local ret = redis.call('GET', read_key)

if ret == false then
  return process_missed_key(read_key, timeout_ms)
end
return {0, ret}
