local force = (ARGV[2] == '*')
local lock_value = '*'
local key = KEYS[1]

if not force then
  lock_value = redis.call('GET', get_lock_key(key))
end

local ttl = 0
if arg_count >= 3 then
  ttl = tonumber(ARGV[3])
end

if lock_value ~= ARGV[2] then
  return {2, tonumber(lock_value)}
end

redis.call('SET', get_key(key), value)
redis.call('DEL', get_lock_key(key))

if ttl > 0 then
  redis.call('PEXPIRE', get_key(key), ttl)
end

return {0, 1}
