local force = (ARGV[2] == '*')
local lock_value = '*'

if not force then
  lock_value = redis.call('GET', lock_key)
end

local ttl = 0
if arg_count >= 3 then
  ttl = tonumber(ARGV[3])
end

if lock_value ~= ARGV[2] then
  return {2, tonumber(lock_value)}
end

redis.call('SET', key, value)
redis.call('DEL', lock_key)

if ttl > 0 then
  redis.call('PEXPIRE', key, ttl)
end

return {0, 1}
