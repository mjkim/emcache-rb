local arg_count = table.getn(ARGV)

local prefix_name = 'DEFAULT'

if arg_count >= 1 then
  prefix_name = ARGV[1]
end

local key = prefix_name..'::{'..KEYS[1]..'}'
local value = KEYS[2]

local lock_key = key..'::'..'LOCK'
