local timeout_ms = 10
if arg_count >= 2 then
  timeout_ms = tonumber(ARGV[2])
end

local function process_missed_key(key, timeout_ms)
  if timeout_ms == 0 then
    return {1, nil}
  end

  local locked = redis.call('GET', get_lock_key(key))
  if locked then
    return {2, tonumber(locked)}
  else
    local lock_value = redis.call('INCR', 'COUNTER')
    redis.call('SET',get_lock_key(key), lock_value, 'PX', timeout_ms)
    return {1, lock_value}
  end
end
