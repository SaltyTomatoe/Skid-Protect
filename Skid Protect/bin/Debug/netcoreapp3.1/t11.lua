--- Extract bits from an integer
--@author: Stravant

local floor = math.floor
local concat = table.concat
local char = string.char
local sub = string.sub
local BitShiftLeft = function(integer, count)
	return integer * (2 ^ count);
end

local ShiftRight = function  (integer, count)
	return math.floor(integer / (2 ^ count))
end

local GetBits = function  (integer, index, count)
	local bits = ShiftRight(integer, index)
	return bits % (2 ^ count)
end

local GetBitCount= function (integer)
	local count = 1
	while integer > 1 do
		integer = ShiftRight(integer, 1)
		count = count + 1
	end
	return count
end
local function xor(integerA, integerB)
	local mb = math.max(GetBitCount(integerA), GetBitCount(integerB))
	local arr = {}
	for n = 0, mb-1 do
		arr[mb - n] = (GetBits(integerA, n, 1) ~= GetBits(integerB, n, 1)) and 1 or 0
	end
	return tonumber(concat(arr, ""), 2)
end
local function ascii_base(s)
	return s:lower() == s and ('a'):byte() or ('A'):byte()
  end
  
  -- ROT13 is based on Caesar ciphering algorithm, using 13 as a key
  local function caesar_cipher(str, key)
	return (str:gsub('%a', function(s)
	  local base = ascii_base(s)
	  return string.char(((s:byte() - base + key) % 26) + base)
	end))
  end
 
  -- str     : a string to be deciphered
  -- returns : the deciphered string
  local function rot13_decipher(str) 
	return caesar_cipher(str, -13) 
  end
local function fix(int,int2)
	return char(xor(int,int2))
end
local cInfo = {
	"%%Instructions%%",
	"%%Constants%%",
	"%%Protos%%",
	"%%Upvalues%%",
}
local vm_info = {
	cInfo,
	"%%Opcode%%"
}
--//Lmao aso like, this is kidna worthless
local function get_bits(input, n, n2)
	if n2 then
		local total = 0
		local digitn = 0
		for i = n, n2 do
			total = total + 2^digitn*get_bits(input, i)
			digitn = digitn + 1
		end
		return total
	else
		local pn = 2^(n-1)
		return (input % (pn + pn) >= pn) and 1 or 0
	end
end

local function decode_bytecode(bytecode)
	local index = 1
	local big_endian = false
    local int_size;
	local size_t;
	-- Binary decoding helper functions
	local get_int8, get_int32, get_int64, get_float64, get_string;
	do
		function get_int8()
			local a = bytecode:byte(index, index);
			index = index + 1
			return a
		end
		function get_int32()
            local a, b, c, d = bytecode:byte(index, index + 3);
            index = index + 4;
            return d*16777216 + c*65536 + b*256 + a
        end
        function get_int64()
            local a = get_int32();
            local b = get_int32();
            return b*4294967296 + a;
        end
		function get_float64()
			local a = get_int32()
			local b = get_int32()
			return (-2*get_bits(b, 32)+1)*(2^(get_bits(b, 21, 31)-1023))*
			       ((get_bits(b, 1, 20)*(2^32) + a)/(2^52)+1)
		end
		function get_string(len)
			local str;
            if len then
	            str = bytecode:sub(index, index + len - 1);
	            index = index + len;
            else
                len = get_int32();
	            if len == 0 then return; end
	            str = bytecode:sub(index, index + len - 1);
	            index = index + len;
            end
            return str;
        end
	end

	local function decode_chunk(is_proto)
		local chunk;
		local instructions = {};
		local constants    = {};
		local prototypes   = {};
		--[[local debug = {
			lines = {};
		};]]

		chunk = {
			[vm_info[1][1]] = instructions;
			[vm_info[1][2]]    = constants;
			[vm_info[1][3]]   = prototypes;
			--debug = debug;
		};

		local num;

		chunk[vm_info[1][4]]  = get_int8();

        -- TODO: realign lists to 1
		-- Decode instructions
		do
			num = get_int32();
			for i = 1, num do
				local instruction = {
					-- opcode = opcode number;
					-- type   = [ABC, ABx, AsBx]
					-- A, B, C, Bx, or sBx depending on type
				};
				instruction[vm_info[2]] = (get_int8())
				local type   = get_int8()
				local data = get_int32();
				instruction.A = get_bits(data,1,7);
				if type == 1 then
					instruction.B = get_bits(data,8,16);
					instruction.C = get_bits(data,17,25);
				elseif type == 2 then
					instruction.Bx = get_bits(data,8,26);
				elseif type == 3 then
					instruction.sBx = get_bits(data,8,26) - 131071;
				end
				instructions[i] = instruction;
			end
		end

		-- Decode constants
		do
			num = get_int32();
			for i = 1, num do
				local constant
				local type = get_int8();
				if type == 1 then
					constant = (get_int8() ~= 0);
				elseif type == 3 then
					constant = get_float64();
				elseif type == 4 then
					constant = rot13_decipher(get_string():sub(1, -2));
				end

				constants[i-1] = constant;
			end
		end

		-- Decode Prototypes
		do
			num = get_int32();
			for i = 1, num do
				prototypes[i-1] = decode_chunk(true);
			end
		end

		
		return chunk;
	end

	return decode_chunk();
end

local function handle_return(...)
	local c = select("#", ...)
	local t = {...}
	return c, t
end

local function create_wrapper(cache, upvalues)
	local instructions = cache[vm_info[1][1]];
	local constants    = cache[vm_info[1][2]];
	local prototypes   = cache[vm_info[1][3]];

	
	local stack, top
	local environment
	local IP = 1;	-- instruction pointer
	local vararg, vararg_size
	local opcode_funcs = {
	--%%CLOSURE_FUNCTIONS_HERE%%--
	}
	local function loop()
		local instructions = instructions
		local instruction, a, b

		while true do
			instruction = instructions[IP];
			IP = IP + 1
			a, b = opcode_funcs[instruction[vm_info[2]]](instruction);
			if a then
				return b;
			end
		end
	end
	local function func(...)
		local local_stack = {};
		local ghost_stack = {};

		top = -1
		stack = setmetatable(local_stack, {
			__index = ghost_stack;
			__newindex = function(t, k, v)
				if k > top and v then
					top = k
				end
				ghost_stack[k] = v
			end;
		})
		local args = {...};
		vararg = {}
		vararg_size = select("#", ...) - 1
		for i = 0, vararg_size do
			local_stack[i] = args[i+1];
			vararg[i] = args[i+1]
		end

		environment = getfenv();
		IP = 1;
		local thread = coroutine.create(loop)
		local status,a, b = coroutine.resume(thread)
		
		if status then
			if b then
				return unpack(b);
			end
			return;
		else
			--[[TODO error converting
			local name = cache.name;
			local line = cache.debug.lines[IP];]]
			local err  = a:gsub("(.-:)", "");
			--[[local output = "";
			output = output .. (name and name .. ":" or "");
			output = output .. (line and line .. ":" or "");
			output = output .. b;]]
			error(err, 0);

		end
	end

	return func;
end

create_wrapper(decode_bytecode("%%Bytecode%%"))()