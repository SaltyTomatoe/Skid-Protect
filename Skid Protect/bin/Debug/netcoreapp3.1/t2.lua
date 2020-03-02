--- Extract bits from an integer
--@author: Stravant

local BitWise = {}

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
	return tonumber(table.concat(arr, ""), 2)
end

local function fix(int,int2)
	return string.char(xor(int,int2))
end

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
		local debug = {
			lines = {};
		};

		chunk = {
			instructions = instructions;
			constants    = constants;
			prototypes   = prototypes;
			debug = debug;
		};

		local num;

		chunk.upvalues  = get_int8();

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
					constant = get_string():sub(1, -2);
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
	local instructions = cache.instructions;
	local constants    = cache.constants;
	local prototypes   = cache.prototypes;

	
	local stack, top
	local environment
	local IP = 1;	-- instruction pointer
	local vararg, vararg_size
	local opcode_funcs = {
	
[30] = function(instruction)	-- LOADK
			stack[instruction.A] = constants[instruction.Bx];
		end,
[11] = function(instruction)	-- GETGLOBAL
			local key = constants[instruction.Bx];
			stack[instruction.A] = environment[key];
		end,
[8] = function(instruction)	-- MOVE
			stack[instruction.A] = stack[instruction.B];
		end,
[73] = function(instruction)	-- CALL
			local A = instruction.A;
			local B = instruction.B;
			local C = instruction.C;
			local stack = stack;
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
		end,
[81] = function(instruction)	-- CONCAT
			local B = instruction.B
			local result = stack[B]
			for i = B+1, instruction.C do
				result = result .. stack[i]
			end
			stack[instruction.A] = result
		end,
[79] = function(instruction)	-- GETTABLE
			local C = instruction.C
			local stack = stack
			C = C > 255 and constants[C-256] or stack[C]
			stack[instruction.A] = stack[instruction.B][C];
		end,
[94] = function(instruction)	-- FORPREP
			local A = instruction.A
			local stack = stack

			stack[A] = stack[A] - stack[A+2]
			IP = IP + instruction.sBx
		end,
[67] = function(instruction)	-- CLOSURE
			local proto = prototypes[instruction.Bx]
			local instructions = instructions
			local stack = stack

			local indices = {}
			local new_upvals = setmetatable({},
				{
					__index = function(t, k)
						local upval = indices[k]
						return upval.segment[upval.offset]
					end,
					__newindex = function(t, k, v)
						local upval = indices[k]
						upval.segment[upval.offset] = v
					end
				}
			)
			for i = 1, proto.upvalues do
				local movement = instructions[IP]
				if movement.opcode == 0 then -- MOVE
					indices[i-1] = {segment = stack, offset = movement.B}
				elseif instructions[IP].opcode == 4 then -- GETUPVAL
					indices[i-1] = {segment = upvalues, offset = movement.B}
				end
				IP = IP + 1
			end

			local func = create_wrapper(proto, new_upvals)
			stack[instruction.A] = func
		end,
[28] = function(instruction)	-- FORLOOP
			local A = instruction.A
			local stack = stack

			local step = stack[A+2]
			local index = stack[A] + step
			stack[A] = index

			if step > 0 then
				if index <= stack[A+1] then
					IP = IP + instruction.sBx
					stack[A+3] = index
				end
			else
				if index >= stack[A+1] then
					IP = IP + instruction.sBx
					stack[A+3] = index
				end
			end
		end,
[20] = function(instruction)	-- SUB
			local B = instruction.B;
			local C = instruction.C;
			local stack, constants = stack, constants;

			B = B > 255 and constants[B-256] or stack[B];
			C = C > 255 and constants[C-256] or stack[C];

			stack[instruction.A] = B - C;
		end,
[23] = function (instruction)	-- NEWTABLE
			stack[instruction.A] = {}
		end,
[72] = function (instruction)	-- SETTABLE
			local B = instruction.B;
			local C = instruction.C;
			local stack, constants = stack, constants;

			B = B > 255 and constants[B-256] or stack[B];
			C = C > 255 and constants[C-256] or stack[C];

			stack[instruction.A][B] = C
		end,
[9] = function(instruction) -- RETURN
			--TODO: CLOSE
			local A = instruction.A;
			local B = instruction.B;
			local stack = stack;
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
		end,
[4] = function(instruction)	-- LOADBOOL
			stack[instruction.A] = instruction.B ~= 0
			if instruction.C ~= 0 then
				IP = IP + 1
			end
		end,
[55] = function(instruction)	-- TEST
			local A = stack[instruction.A];
			if (not not A) == (instruction.C == 0) then
				IP = IP + 1
			end
		end,
[1] = function(instruction)	-- JUMP
			IP = IP + instruction.sBx
		end,
	}
	local function loop()
		local instructions = instructions
		local instruction, a, b

		while true do
			instruction = instructions[IP];
			IP = IP + 1
			a, b = opcode_funcs[instruction.opcode](instruction);
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

create_wrapper(decode_bytecode("\0\98\0\0\0\30\2\0\0\0\0\11\2\129\0\0\0\30\2\2\1\0\0\11\2\131\1\0\0\8\1\4\0\0\0\73\1\3\1\2\0\81\1\2\1\3\0\73\1\1\1\1\0\11\2\129\0\0\0\30\2\2\2\0\0\73\1\1\1\1\0\11\2\129\2\0\0\79\1\129\0\6\1\73\1\129\0\2\0\8\1\130\0\0\0\30\2\131\3\0\0\8\1\4\0\0\0\30\2\133\3\0\0\94\3\131\0\0\1\67\2\7\0\0\0\73\1\135\0\1\0\28\3\3\254\255\0\11\2\131\0\0\0\30\2\4\4\0\0\11\2\133\2\0\0\79\1\133\2\6\1\73\1\133\0\2\0\20\1\133\2\1\0\30\2\134\4\0\0\81\1\133\2\6\0\73\1\131\1\1\0\11\2\131\0\0\0\30\2\4\5\0\0\73\1\3\1\1\0\11\2\131\2\0\0\79\1\131\1\6\1\73\1\131\0\2\0\8\1\129\1\0\0\23\1\3\0\0\0\30\2\132\3\0\0\8\1\5\0\0\0\30\2\134\3\0\0\94\3\4\4\0\1\11\2\136\1\0\0\8\1\137\3\0\0\73\1\8\1\2\0\30\2\137\5\0\0\11\2\138\1\0\0\8\1\139\3\0\0\73\1\10\1\2\0\81\1\137\4\10\0\72\1\3\4\9\0\28\3\132\250\255\0\11\2\132\0\0\0\30\2\5\4\0\0\11\2\134\2\0\0\79\1\6\3\6\1\73\1\134\0\2\0\20\1\6\3\1\0\30\2\135\4\0\0\81\1\6\3\7\0\73\1\132\1\1\0\11\2\132\0\0\0\30\2\5\6\0\0\73\1\4\1\1\0\11\2\132\2\0\0\79\1\4\2\6\1\73\1\132\0\2\0\8\1\1\2\0\0\30\2\132\3\0\0\8\1\5\0\0\0\30\2\134\3\0\0\94\3\4\2\0\1\11\2\136\1\0\0\8\1\137\3\0\0\73\1\8\1\2\0\79\1\136\1\8\0\72\1\131\131\8\0\28\3\132\252\255\0\11\2\132\0\0\0\30\2\5\4\0\0\11\2\134\2\0\0\79\1\6\3\6\1\73\1\134\0\2\0\20\1\6\3\1\0\30\2\135\4\0\0\81\1\6\3\7\0\73\1\132\1\1\0\11\2\132\0\0\0\30\2\133\6\0\0\11\2\134\2\0\0\79\1\6\3\6\1\73\1\134\0\2\0\20\1\6\3\2\0\30\2\135\4\0\0\81\1\6\3\7\0\73\1\132\1\1\0\9\1\128\0\0\0\14\0\0\0\3\0\0\0\0\0\106\248\64\4\6\0\0\0\112\114\105\110\116\0\4\13\0\0\0\73\116\101\114\97\116\105\111\110\115\58\32\0\4\9\0\0\0\116\111\115\116\114\105\110\103\0\4\17\0\0\0\67\76\79\83\85\82\69\32\116\101\115\116\105\110\103\46\0\4\3\0\0\0\111\115\0\4\6\0\0\0\99\108\111\99\107\0\3\0\0\0\0\0\0\240\63\4\6\0\0\0\84\105\109\101\58\0\4\2\0\0\0\115\0\4\18\0\0\0\83\69\84\84\65\66\76\69\32\116\101\115\116\105\110\103\46\0\4\12\0\0\0\69\80\73\67\32\71\65\77\69\82\32\0\4\18\0\0\0\71\69\84\84\65\66\76\69\32\116\101\115\116\105\110\103\46\0\4\12\0\0\0\84\111\116\97\108\32\84\105\109\101\58\0\1\0\0\0\0\7\0\0\0\4\1\0\0\0\0\55\1\0\0\0\0\1\3\0\1\0\1\11\2\0\0\0\0\30\2\129\0\0\0\73\1\0\1\1\0\9\1\128\0\0\0\2\0\0\0\4\6\0\0\0\112\114\105\110\116\0\4\11\0\0\0\72\101\121\32\103\97\109\101\114\46\0\0\0\0\0"))()