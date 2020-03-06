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
  local function dec_constants(val) 
	if(type(val)~="string")then return val end
	return caesar_cipher(val, -13) 
  end
local function fix(int,int2)
	return char(xor(int,int2))
end

--//Lmao sss so like, this is kidna worthless
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
			instructions = instructions;
			constants    = constants;
			prototypes   = prototypes;
		};

		chunk.upvalues  = get_int8();

		for i = 1, get_int32() do
			local instruction = {
				-- opcode = opcode number;
				-- type   = [ABC, ABx, AsBx]
				-- A, B, C, Bx, or sBx depending on type
			};
			instruction.opcode = (get_int8())
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
			print(instruction.opcode,instruction.sBx)
			instructions[i] = instruction;
		end
		if true then return end
		for i = 1, get_int32() do
			local constant
			local type = get_int8();
			if type == 1 then
				constant = (get_int8() ~= 0);
			elseif type == 3 then
				constant = get_float64();
			elseif type == 4 then
				constant = get_string():sub(1, -2);
			end
			constants[i-1] = constant;
		end

		-- Decode Prototypes
		for i = 1, get_int32() do
			prototypes[i-1] = decode_chunk(true);
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
local insts = concat({fix(285,372),fix(778,868),fix(190,205),fix(256,372),fix(557,607),fix(998,915),fix(595,560),fix(1008,900),fix(831,854),fix(196,171),fix(57,87),fix(276,359),})
local consts = concat({fix(21,118),fix(371,284),fix(839,809),fix(440,459),fix(296,348),fix(339,306),fix(161,207),fix(764,648),fix(362,281),})
local protos = concat({fix(216,168),fix(290,336),fix(631,536),fix(698,718),fix(524,611),fix(743,659),fix(507,386),fix(211,163),fix(958,987),fix(148,231),})
local opco = concat({fix(17,126),fix(458,442),fix(43,72),fix(259,364),fix(201,173),fix(536,637),})
local function create_wrapper(cache, upvalues)
	local instructions = cache[insts];
	local constants    = cache[consts];
	local prototypes   = cache[protos];

	
	local stack, top
	local environment
	local IP = 1;	-- instruction pointer
	local vararg, vararg_size
	local function loop()
		local instructions = instructions
		local instruction, a, b

		while true do
			instruction = instructions[IP];
			IP = IP + 1
			
 if instruction[opco] == 5 then 
stack[instruction.A] = environment[dec_constants(constants[instruction.Bx])];
 elseif instruction[opco] == 1 then 
stack[instruction.A] = dec_constants(constants[instruction.Bx])
 elseif instruction[opco] == 28 then 
A = instruction.A;
        B = instruction.B;
        C = instruction.C;
       
        local args, results;
        local limit, loop

        args = {};
        if B ~= 1 then
            if B ~= 0 then
                limit = A+B-1;
            else
                limit = top
            end

            loop = 0
            for i = A+1, limit do
                loop = loop + 1
                args[loop] = stack[i];
            end

            limit, results = handle_return(stack[A](unpack(args, 1, limit-A)))
        else
            limit, results = handle_return(stack[A]())
        end

        top = A - 1

        if C ~= 1 then
            if C ~= 0 then
                limit = A+C-2;
            else
                limit = limit+A
            end

            loop = 0;
            for i = A, limit do
                loop = loop + 1;
                stack[i] = results[loop];
            end
        end
 elseif instruction[opco] == 30 then 
--TODO: CLOSE
        A = instruction.A;
        B = instruction.B;
       
        local limit;
        local loop, output;

        if B == 1 then
            return true;
        end
        if B == 0 then
            limit = top
        else
            limit = A + B - 2;
        end

        output = {};
        local loop = 0
        for i = A, limit do
            loop = loop + 1
            output[loop] = stack[i];
        end
        return true, output;
 elseif instruction[opco] == 22 then 
IP = IP + instruction.sBx
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

return create_wrapper(decode_bytecode("\0\4\0\0\0\5\2\0\0\0\0\1\2\129\0\0\0\22\3\197\255\255\0\30\1\128\0\0\0\22\3\197\0\0\1\28\1\0\1\1\0\22\3\69\254\255\0\2\0\0\0\4\6\0\0\0\99\101\118\97\103\0\4\2\0\0\0\46\0\0\0\0\0"))()