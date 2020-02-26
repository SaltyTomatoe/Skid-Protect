local floor = math.floor
local function bxor(a,b)
    local r = 0
    for i = 0, 31 do
      local x = a / 2 + b / 2
      if x ~= floor (x) then
        r = r + 2^i
      end
      a = floor (a / 2)
      b = floor (b / 2)
    end
    return r
end

local bitwise = {
    xor = bxor
}

return bitwise