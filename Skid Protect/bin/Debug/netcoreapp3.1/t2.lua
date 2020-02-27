--- Extract bits from an integer
--@author: Stravant
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
				if(is_proto == true)then
					instruction.opcode = (get_int8())
				end
				instruction.A = get_int8();
				local type   = get_int8()
				instruction.type   = type;

				if type == 1 then
					instruction.B = get_int8()
					instruction.C = get_int8()
				elseif type == 2 then
					instruction.Bx = get_int8()
				elseif type == 3 then
					instruction.sBx = get_int32();
				end

				instructions[i] = instruction;
			end
		end

		-- Decode constants
		do
			num = get_int32();
			for i = 1, num do
				local constant = {
					-- type = constant type;
					-- data = constant data;
				};
				local type = get_int8();
				constant.type = type;

				if type == 1 then
					constant.data = (get_int8() ~= 0);
				elseif type == 3 then
					constant.data = get_float64();
				elseif type == 4 then
					constant.data = get_string():sub(1, -2);
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
	
[68] = function(instruction)	-- GETGLOBAL
			local key = constants[instruction.Bx].data;
			stack[instruction.A] = environment[key];
		end,
[98] = function(instruction)	-- LOADK
			stack[instruction.A] = constants[instruction.Bx].data;
		end,
[8] = function(instruction)	-- CALL
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
[21] = function(instruction) -- RETURN
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

	local debugging = {
		
	};

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
		local a, b = coroutine.resume(thread)
		
		if a then
			if b then
				return unpack(b);
			end
			return;
		else
			--TODO error converting
			local name = cache.name;
			local line = cache.debug.lines[IP];
			local err  = b:gsub("(.-:)", "");
			local output = "";
			output = output .. (name and name .. ":" or "");
			output = output .. (line and line .. ":" or "");
			output = output .. b;
			error(output, 0);

		end
	end

	return debugging, func;
end

local function wrap(cache, upvalues)
	local instructions = cache.instructions;
	local constants    = cache.constants;
	local prototypes   = cache.prototypes;

	
	local stack, top
	local environment
	local IP = 1;	-- instruction pointer
	local vararg, vararg_size

	local function loop()
		local instructions = instructions
		local instruction, a, b
		
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
local stack = stack
        for i = instruction.A, instruction.B do
            stack[i] = nil
        end
instruction = instructions[IP];IP = IP + 1
environment[constants[instruction.Bx].data] = stack[instruction.A];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
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

        local _, func = create_wrapper(proto, new_upvals)
        stack[instruction.A] = func
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = stack[instruction.B];
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
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
	end

	local debugging = {
		
	};

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
		if status and a then
			if b then
				return unpack(b);
			end
			return;
		else
			--TODO error converting
			local name = cache.name;
			local line = cache.debug.lines[IP];
			local err  = b:gsub("(.-:)", "");
			local output = "";
			output = output .. (name and name .. ":" or "");
			output = output .. (line and line .. ":" or "");
			output = output .. b;
			error(output, 0);

		end
	end

	return debugging, func;
end

local load_bytecode = function(bytecode)
	local cache = decode_bytecode(bytecode);
	local _, func = wrap(cache);
	return func;
end;

load_bytecode("\0\18\0\0\0\0\2\0\1\2\1\0\1\2\1\0\1\0\0\0\2\2\0\2\0\1\2\3\2\2\4\3\2\2\2\1\2\0\0\1\0\1\0\2\0\1\2\5\0\1\2\1\0\2\0\1\1\0\0\1\1\1\1\0\1\1\0\6\0\0\0\4\6\0\0\0\112\114\105\110\116\0\4\3\0\0\0\120\100\0\4\11\0\0\0\108\111\97\100\115\116\114\105\110\103\0\4\5\0\0\0\69\82\82\58\0\4\6\0\0\0\112\99\97\108\108\0\4\3\0\0\0\58\41\0\1\0\0\0\0\4\0\0\0\68\0\2\0\98\1\2\1\8\0\1\2\1\21\0\1\1\0\2\0\0\0\4\6\0\0\0\112\114\105\110\116\0\4\3\0\0\0\120\100\0\0\0\0\0")()