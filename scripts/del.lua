redis.call('DEL', lock_key)
redis.call('DEL', key)
