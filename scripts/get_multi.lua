local key_count = table.getn(KEYS)
local keys = {}
local result = {}

local index = 1
local result_index = 1
for i=1, key_count do
  local is_last = (key_count == i)

  keys[index] = get_key(KEYS[i])

  if (index % 1000) == 0 or is_last then
    local get_values = redis.call('MGET', unpack(keys))
    index = 0

    for j=1, table.getn(get_values) do
      if get_values[j] then
        result[result_index] = {0, get_values[j]}
      else
        result[result_index] = process_missed_key(KEYS[result_index], timeout_ms)
      end
      result_index = result_index + 1
    end
    keys = {}
  end

  index = index + 1
end

return result
