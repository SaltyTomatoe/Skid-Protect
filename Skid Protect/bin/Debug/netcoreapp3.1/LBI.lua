local lua_opcode_types = {
	"ABC",  "ABx", "ABC",  "ABC",
	"ABC",  "ABx", "ABC",  "ABx",
	"ABC",  "ABC", "ABC",  "ABC",
	"ABC",  "ABC", "ABC",  "ABC",
	"ABC",  "ABC", "ABC",  "ABC",
	"ABC",  "ABC", "AsBx", "ABC",
	"ABC",  "ABC", "ABC",  "ABC",
	"ABC",  "ABC", "ABC",  "AsBx",
	"AsBx", "ABC", "ABC", "ABC",
	"ABx",  "ABC",
}

local lua_opcode_names = {
	"MOVE",     "LOADK",     "LOADBOOL", "LOADNIL",
	"GETUPVAL", "GETGLOBAL", "GETTABLE", "SETGLOBAL",
	"SETUPVAL", "SETTABLE",  "NEWTABLE", "SELF",
	"ADD",      "SUB",       "MUL",      "DIV",
	"MOD",      "POW",       "UNM",      "NOT",
	"LEN",      "CONCAT",    "JMP",      "EQ",
	"LT",       "LE",        "TEST",     "TESTSET",
	"CALL",     "TAILCALL",  "RETURN",   "FORLOOP",
	"FORPREP",  "TFORLOOP",  "SETLIST",  "CLOSE",
	"CLOSURE",  "VARARG"
};

--[[
local lua_opcode_numbers = {};
for number, name in next, lua_opcode_names do
	lua_opcode_numbers[name] = number;
end
--]]

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

	local function decode_chunk()
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
				local opcode = get_int8();
				instruction.A = get_int8();
				local type   = get_int8()

				instruction.opcode = opcode;
				instruction.type   = type;

				if type == "ABC" then
					instruction.B = get_int8()
					instruction.C = get_int8()
				elseif type == "ABx" then
					instruction.Bx = get_int8()
				elseif type == "AsBx" then
					instruction.sBx = get_int8() - 131071;
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
				prototypes[i-1] = decode_chunk();
			end
		end

		-- Decode debug info
        -- Not all of which is used yet.
		--[[do
			-- line numbers
			local data = debug.lines
			num = get_int32();
			for i = 1, num do
				data[i] = get_int32();
			end

			-- locals
			num = get_int32();
			for i = 1, num do
				get_string():sub(1, -2);	-- local name
				get_int32();	-- local start PC
				get_int32();	-- local end   PC
			end

			-- upvalues
			num = get_int32();
			for i = 1, num do
				get_string();	-- upvalue name
			end
		end]]

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

	local function loop()
		local instructions = instructions
		local instruction, a, b

		--[[while true do
			instruction = instructions[IP];
			IP = IP + 1
			a, b = opcode_funcs[instruction.opcode](instruction);
			if a then
				return b;
			end
		end]]
		--%%OPCODE_FUNCTIONS_HERE%%--
	end

	local debugging = {
		get_stack = function()
			return stack;
		end;
		get_IP = function()
			return IP;
		end
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

load_bytecode = function(bytecode)
	local cache = decode_bytecode(bytecode);
	local _, func = create_wrapper(cache);
	return func;
end;

load_bytecode("%%Bytecode%%")()