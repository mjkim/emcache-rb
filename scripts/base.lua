local arg_count = table.getn(ARGV)

local prefix_name = 'DEFAULT'

if arg_count >= 1 then
  prefix_name = ARGV[1]
end

local value = KEYS[2]

local function get_key(key)
  return prefix_name..'::{'..key..'}'
end

local function get_lock_key(key)
  return get_key(key)..'::'..'LOCK'
end
