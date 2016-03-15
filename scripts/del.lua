redis.call('DEL', get_lock_key(key))
redis.call('DEL', key)
