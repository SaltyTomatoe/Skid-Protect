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
	
[99] = function(instruction)	-- LOADBOOL
			stack[instruction.A] = instruction.B ~= 0
			if instruction.C ~= 0 then
				IP = IP + 1
			end
		end,
[39] = function(instruction)	-- TEST
			local A = stack[instruction.A];
			if (not not A) == (instruction.C == 0) then
				IP = IP + 1
			end
		end,
[59] = function(instruction)	-- JUMP
			IP = IP + instruction.sBx
		end,
[45] = function(instruction)	-- GETGLOBAL
			local key = constants[instruction.Bx].data;
			stack[instruction.A] = environment[key];
		end,
[25] = function(instruction)	-- LOADK
			stack[instruction.A] = constants[instruction.Bx].data;
		end,
[32] = function(instruction)	-- CALL
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
[85] = function(instruction) -- RETURN
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
			--[[TODO error converting
			local name = cache.name;
			local line = cache.debug.lines[IP];]]
			local err  = b:gsub("(.-:)", "");
			--[[local output = "";
			output = output .. (name and name .. ":" or "");
			output = output .. (line and line .. ":" or "");
			output = output .. b;]]
			error(err, 0);

		end
	end

	return func;
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
		local instruction, a, b,A,B,C
		
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = stack[instruction.B];
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
local B = instruction.B
        local result = stack[B]
        for i = B+1, instruction.C do
            result = result .. stack[i]
        end
        stack[instruction.A] = result
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
C = instruction.C
        
        C = C > 255 and constants[C-256].data or stack[C]
        stack[instruction.A] = stack[instruction.B][C];
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = stack[instruction.B];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = stack[instruction.B];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
A = instruction.A
        

        stack[A] = stack[A] - stack[A+2]
        IP = IP + instruction.sBx
instruction = instructions[IP];IP = IP + 1
local proto = prototypes[instruction.Bx]
        local instructions = instructions
        

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
instruction = instructions[IP];IP = IP + 1
A = instruction.A
        

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
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
C = instruction.C
        
        C = C > 255 and constants[C-256].data or stack[C]
        stack[instruction.A] = stack[instruction.B][C];
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
B = instruction.B;
        C = instruction.C;
        local stack, constants = stack, constants;

        B = B > 255 and constants[B-256].data or stack[B];
        C = C > 255 and constants[C-256].data or stack[C];

        stack[instruction.A] = B - C;
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
local B = instruction.B
        local result = stack[B]
        for i = B+1, instruction.C do
            result = result .. stack[i]
        end
        stack[instruction.A] = result
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
C = instruction.C
        
        C = C > 255 and constants[C-256].data or stack[C]
        stack[instruction.A] = stack[instruction.B][C];
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = stack[instruction.B];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = {}
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = stack[instruction.B];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
A = instruction.A
        

        stack[A] = stack[A] - stack[A+2]
        IP = IP + instruction.sBx
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = stack[instruction.B];
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = stack[instruction.B];
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
local B = instruction.B
        local result = stack[B]
        for i = B+1, instruction.C do
            result = result .. stack[i]
        end
        stack[instruction.A] = result
instruction = instructions[IP];IP = IP + 1
 B = instruction.B;
        C = instruction.C;
        local stack, constants = stack, constants;

        B = B > 255 and constants[B-256].data or stack[B];
        C = C > 255 and constants[C-256].data or stack[C];

        stack[instruction.A][B] = C
instruction = instructions[IP];IP = IP + 1
A = instruction.A
        

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
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
C = instruction.C
        
        C = C > 255 and constants[C-256].data or stack[C]
        stack[instruction.A] = stack[instruction.B][C];
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
B = instruction.B;
        C = instruction.C;
        local stack, constants = stack, constants;

        B = B > 255 and constants[B-256].data or stack[B];
        C = C > 255 and constants[C-256].data or stack[C];

        stack[instruction.A] = B - C;
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
local B = instruction.B
        local result = stack[B]
        for i = B+1, instruction.C do
            result = result .. stack[i]
        end
        stack[instruction.A] = result
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
C = instruction.C
        
        C = C > 255 and constants[C-256].data or stack[C]
        stack[instruction.A] = stack[instruction.B][C];
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = stack[instruction.B];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = stack[instruction.B];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
A = instruction.A
        

        stack[A] = stack[A] - stack[A+2]
        IP = IP + instruction.sBx
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = stack[instruction.B];
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
C = instruction.C
        
        C = C > 255 and constants[C-256].data or stack[C]
        stack[instruction.A] = stack[instruction.B][C];
instruction = instructions[IP];IP = IP + 1
 B = instruction.B;
        C = instruction.C;
        local stack, constants = stack, constants;

        B = B > 255 and constants[B-256].data or stack[B];
        C = C > 255 and constants[C-256].data or stack[C];

        stack[instruction.A][B] = C
instruction = instructions[IP];IP = IP + 1
A = instruction.A
        

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
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
C = instruction.C
        
        C = C > 255 and constants[C-256].data or stack[C]
        stack[instruction.A] = stack[instruction.B][C];
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
B = instruction.B;
        C = instruction.C;
        local stack, constants = stack, constants;

        B = B > 255 and constants[B-256].data or stack[B];
        C = C > 255 and constants[C-256].data or stack[C];

        stack[instruction.A] = B - C;
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
local B = instruction.B
        local result = stack[B]
        for i = B+1, instruction.C do
            result = result .. stack[i]
        end
        stack[instruction.A] = result
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = environment[constants[instruction.Bx].data];
instruction = instructions[IP];IP = IP + 1
C = instruction.C
        
        C = C > 255 and constants[C-256].data or stack[C]
        stack[instruction.A] = stack[instruction.B][C];
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
B = instruction.B;
        C = instruction.C;
        local stack, constants = stack, constants;

        B = B > 255 and constants[B-256].data or stack[B];
        C = C > 255 and constants[C-256].data or stack[C];

        stack[instruction.A] = B - C;
instruction = instructions[IP];IP = IP + 1
stack[instruction.A] = constants[instruction.Bx].data;
instruction = instructions[IP];IP = IP + 1
local B = instruction.B
        local result = stack[B]
        for i = B+1, instruction.C do
            result = result .. stack[i]
        end
        stack[instruction.A] = result
instruction = instructions[IP];IP = IP + 1
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
instruction = instructions[IP];IP = IP + 1
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
		if status and a then
			if b then
				return unpack(b);
			end
			return;
		else
			--[[TODO error converting
			local name = cache.name;
			local line = cache.debug.lines[IP];]]
			local err  = b:gsub("(.-:)", "");
			--[[local output = "";
			output = output .. (name and name .. ":" or "");
			output = output .. (line and line .. ":" or "");
			output = output .. b;]]
			error(err, 0);

		end
	end

	return func;
end

local load_bytecode = function(bytecode)
	local cache = decode_bytecode(bytecode);
	return wrap(cache);
	--return func;
end;

load_bytecode("\0\101\0\0\0\0\2\0\1\2\1\0\1\2\1\0\2\2\1\2\0\2\2\3\3\2\4\4\1\0\0\3\1\2\2\2\1\2\3\1\1\2\1\1\2\0\2\2\5\1\1\2\1\1\2\6\1\1\1\263\1\1\1\2\2\1\1\0\3\2\8\4\1\0\0\5\2\8\3\3\2\0\0\0\7\2\0\7\1\1\1\3\3\-3\0\0\0\3\2\0\4\2\9\5\2\6\5\1\5\263\5\1\1\2\5\1\5\1\6\2\10\5\1\5\6\3\1\3\1\3\2\0\4\2\11\3\1\2\1\3\2\6\3\1\3\263\3\1\1\2\1\1\3\0\3\1\0\0\4\2\8\5\1\0\0\6\2\8\4\3\9\0\0\0\8\2\4\9\1\7\0\8\1\2\2\9\2\12\10\2\4\11\1\7\0\10\1\2\2\9\1\9\10\3\1\8\9\4\3\-10\0\0\0\4\2\0\5\2\9\6\2\6\6\1\6\263\6\1\1\2\6\1\6\1\7\2\10\6\1\6\7\4\1\3\1\4\2\0\5\2\13\4\1\2\1\4\2\6\4\1\4\263\4\1\1\2\1\1\4\0\4\2\8\5\1\0\0\6\2\8\4\3\5\0\0\0\8\2\4\9\1\7\0\8\1\2\2\8\1\3\8\3\1\264\8\4\3\-6\0\0\0\4\2\0\5\2\9\6\2\6\6\1\6\263\6\1\1\2\6\1\6\1\7\2\10\6\1\6\7\4\1\3\1\4\2\0\5\2\14\6\2\6\6\1\6\263\6\1\1\2\6\1\6\2\7\2\10\6\1\6\7\4\1\3\1\0\1\1\0\15\0\0\0\4\6\0\0\0\112\114\105\110\116\0\4\32\0\0\0\73\114\111\110\66\114\101\119\32\50\58\116\109\58\32\66\101\110\99\104\109\97\114\107\45\121\32\77\101\109\101\0\3\0\0\0\0\0\106\248\64\4\13\0\0\0\73\116\101\114\97\116\105\111\110\115\58\32\0\4\9\0\0\0\116\111\115\116\114\105\110\103\0\4\17\0\0\0\67\76\79\83\85\82\69\32\116\101\115\116\105\110\103\46\0\4\3\0\0\0\111\115\0\4\6\0\0\0\99\108\111\99\107\0\3\0\0\0\0\0\0\240\63\4\6\0\0\0\84\105\109\101\58\0\4\2\0\0\0\115\0\4\18\0\0\0\83\69\84\84\65\66\76\69\32\116\101\115\116\105\110\103\46\0\4\12\0\0\0\69\80\73\67\32\71\65\77\69\82\32\0\4\18\0\0\0\71\69\84\84\65\66\76\69\32\116\101\115\116\105\110\103\46\0\4\12\0\0\0\84\111\116\97\108\32\84\105\109\101\58\0\1\0\0\0\0\7\0\0\0\99\0\1\0\0\39\0\1\0\0\59\0\3\3\0\0\0\45\0\2\0\25\1\2\1\32\0\1\2\1\85\0\1\1\0\2\0\0\0\4\6\0\0\0\112\114\105\110\116\0\4\11\0\0\0\72\101\121\32\103\97\109\101\114\46\0\0\0\0\0")()