using System;
using System.Collections.Generic;
using System.Text;

namespace Skid_Protect
{
    static class Opcodes
    {
        static public Dictionary<int, string> ops = new Dictionary<int, string>()
        {
            { 0 , "stack[instruction.A] = stack[instruction.B];" },
            { 1 , "stack[instruction.A] = constants[instruction.Bx].data;" },
            { 2 , @"stack[instruction.A] = instruction.B ~= 0
        if instruction.C ~= 0 then
            IP = IP + 1
        end" },
            { 3, @"
        for i = instruction.A, instruction.B do
            stack[i] = nil
        end" },
            { 4, @"stack[instruction.A] = upvalues[instruction.B]" },
            {5, @"stack[instruction.A] = environment[constants[instruction.Bx].data];" },
            {6, @"C = instruction.C
        
        C = C > 255 and constants[C-256].data or stack[C]
        stack[instruction.A] = stack[instruction.B][C];" },
            {7,@"environment[constants[instruction.Bx].data] = stack[instruction.A];" },
            {8,@"upvalues[instruction.B] = stack[instruction.A]" },
            {9,@" B = instruction.B;
        C = instruction.C;
       

        B = B > 255 and constants[B-256].data or stack[B];
        C = C > 255 and constants[C-256].data or stack[C];

        stack[instruction.A][B] = C" },
            {10,@"stack[instruction.A] = {}" },
            {11,@"A = instruction.A
        B = instruction.B
        C = instruction.C
        

        B = stack[B]
        C = C > 255 and constants[C-256].data or stack[C]

        stack[A+1] = B
        stack[A]   = B[C]" },
            {12,@"B = instruction.B;
        C = instruction.C;
       

        B = B > 255 and constants[B-256].data or stack[B];
        C = C > 255 and constants[C-256].data or stack[C];

        stack[instruction.A] = B+C;" },
            {13,@"B = instruction.B;
        C = instruction.C;
       

        B = B > 255 and constants[B-256].data or stack[B];
        C = C > 255 and constants[C-256].data or stack[C];

        stack[instruction.A] = B - C;" },
            {14,@"B = instruction.B;
        C = instruction.C;
       

        B = B > 255 and constants[B-256].data or stack[B];
        C = C > 255 and constants[C-256].data or stack[C];

        stack[instruction.A] = B * C;" },
            {15,@"B = instruction.B;
        C = instruction.C;
       

        B = B > 255 and constants[B-256].data or stack[B];
        C = C > 255 and constants[C-256].data or stack[C];

        stack[instruction.A] = B / C;" },
            {16,@"B = instruction.B;
        C = instruction.C;
       

        B = B > 255 and constants[B-256].data or stack[B];
        C = C > 255 and constants[C-256].data or stack[C];

        stack[instruction.A] = B % C;" },
            {17,@"B = instruction.B;
        C = instruction.C;
       

        B = B > 255 and constants[B-256].data or stack[B];
        C = C > 255 and constants[C-256].data or stack[C];

        stack[instruction.A] = B ^ C;" },
            {18,@"stack[instruction.A] = -stack[instruction.B]" },
            {19,@"stack[instruction.A] = not stack[instruction.B]" },
            {20,@"stack[instruction.A] = #stack[instruction.B]" },
            {21,@"B = instruction.B
        local result = stack[B]
        for i = B+1, instruction.C do
            result = result .. stack[i]
        end
        stack[instruction.A] = result" },
            {22,@"IP = IP + instruction.sBx" },
            {23,@"A = instruction.A
        B = instruction.B
        C = instruction.C
        

        A = A ~= 0
        if (B > 255) then B = constants[B-256].data else B = stack[B] end
        if (C > 255) then C = constants[C-256].data else C = stack[C] end
        if (B == C) ~= A then
            IP = IP + 1
        end" },
            {24,@"A = instruction.A
        B = instruction.B
        C = instruction.C
        

        A = A ~= 0
        B = B > 255 and constants[B-256].data or stack[B]
        C = C > 255 and constants[C-256].data or stack[C]
        if (B < C) ~= A then
            IP = IP + 1
        end" },
            {25,@"A = instruction.A
        B = instruction.B
        C = instruction.C
        

        A = A ~= 0
        B = B > 255 and constants[B-256].data or stack[B]
        C = C > 255 and constants[C-256].data or stack[C]
        if (B <= C) ~= A then
            IP = IP + 1
        end" },
            {26,@"local A = stack[instruction.A];
        if (not not A) == (instruction.C == 0) then
            IP = IP + 1
        end" },
            {27,@"
        local B = stack[instruction.B]

        if (not not B) == (instruction.C == 0) then
            IP = IP + 1
        else
            stack[instruction.A] = B
        end" },
            {28,@"A = instruction.A;
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
        end" },
            {29,@"A = instruction.A;
        B = instruction.B;
        C = instruction.C;
       
        local args, results;
        local top, limit, loop = top

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
                args[#args+1] = stack[i];
            end

            results = {stack[A](unpack(args, 1, limit-A))};
        else
            results = {stack[A]()};
        end

        return true, results" },
            {30,@"--TODO: CLOSE
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
        return true, output;" },
            {31,@"A = instruction.A
        

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
        end" },
            {32,@"A = instruction.A
        

        stack[A] = stack[A] - stack[A+2]
        IP = IP + instruction.sBx" },
            {33,@"A = instruction.A
        B = instruction.B
        C = instruction.C
        

        local offset = A+2
        local result = {stack[A](stack[A+1], stack[A+2])}
        for i = 1, C do
            stack[offset+i] = result[i]
        end

        if stack[A+3] ~= nil then
            stack[A+2] = stack[A+3]
        else
            IP = IP + 1
        end" },
            {34,@"A = instruction.A
        B = instruction.B
        C = instruction.C
        

        if C == 0 then
            error('NYI: extended SETLIST')
        else
            local offset = (C - 1) * 50
            local t = stack[A]

            if B == 0 then
                B = top
            end
            for i = 1, B do
                t[offset+i] = stack[A+i]
            end
        end" },
            {35,@"io.stderr:write('NYI: CLOSE')
        io.stderr:flush()" },
            {36,@"local proto = prototypes[instruction.Bx]
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

        local func = create_wrapper(proto, new_upvals)
        stack[instruction.A] = func" },
            {37,@"A = instruction.A
        B = instruction.B
        local stack, vararg = stack, vararg

        for i = A, A + (B > 0 and B - 1 or vararg_size) do
            stack[i] = vararg[i - A]
        end" }
        };

        static public Dictionary<int, string> ops_table = new Dictionary<int, string>()
        {
            {0, @"function(instruction)	-- MOVE
			stack[instruction.A] = stack[instruction.B];
		end,"},
            {1,@"function(instruction)	-- LOADK
			stack[instruction.A] = constants[instruction.Bx].data;
		end,"},
            {2,@"function(instruction)	-- LOADBOOL
			stack[instruction.A] = instruction.B ~= 0
			if instruction.C ~= 0 then
				IP = IP + 1
			end
		end,"},
            {3, @"function(instruction)	-- LOADNIL
			local stack = stack
			for i = instruction.A, instruction.B do
				stack[i] = nil
			end
		end,"},
            {4,@"function(instruction)		-- GETUPVAL
			stack[instruction.A] = upvalues[instruction.B]
		end,"},
            {5, @"function(instruction)	-- GETGLOBAL
			local key = constants[instruction.Bx].data;
			stack[instruction.A] = environment[key];
		end,"},
            {6,@"function(instruction)	-- GETTABLE
			local C = instruction.C
			local stack = stack
			C = C > 255 and constants[C-256].data or stack[C]
			stack[instruction.A] = stack[instruction.B][C];
		end," },
            {7,@"function(instruction)	-- SETGLOBAL
			local key = constants[instruction.Bx].data;
			environment[key] = stack[instruction.A];
		end," },
            {8,@"function (instruction)	-- SETUPVAL
			upvalues[instruction.B] = stack[instruction.A]
		end,"},
            {9,@"function (instruction)	-- SETTABLE
			local B = instruction.B;
			local C = instruction.C;
			local stack, constants = stack, constants;

			B = B > 255 and constants[B-256].data or stack[B];
			C = C > 255 and constants[C-256].data or stack[C];

			stack[instruction.A][B] = C
		end," },
            {10,@"function (instruction)	-- NEWTABLE
			stack[instruction.A] = {}
		end,"},
            {11,@"function (instruction)	-- SELF
			local A = instruction.A
			local B = instruction.B
			local C = instruction.C
			local stack = stack

			B = stack[B]
			C = C > 255 and constants[C-256].data or stack[C]

			stack[A+1] = B
			stack[A]   = B[C]
		end," },
            {12,@"function(instruction)	-- ADD
			local B = instruction.B;
			local C = instruction.C;
			local stack, constants = stack, constants;

			B = B > 255 and constants[B-256].data or stack[B];
			C = C > 255 and constants[C-256].data or stack[C];

			stack[instruction.A] = B+C;
		end," },
            {13,@"function(instruction)	-- SUB
			local B = instruction.B;
			local C = instruction.C;
			local stack, constants = stack, constants;

			B = B > 255 and constants[B-256].data or stack[B];
			C = C > 255 and constants[C-256].data or stack[C];

			stack[instruction.A] = B - C;
		end," },
            {14,@"function(instruction)	-- MUL
			local B = instruction.B;
			local C = instruction.C;
			local stack, constants = stack, constants;

			B = B > 255 and constants[B-256].data or stack[B];
			C = C > 255 and constants[C-256].data or stack[C];

			stack[instruction.A] = B * C;
		end," },
            {15,@"function(instruction)	--DIV
			local B = instruction.B;
			local C = instruction.C;
			local stack, constants = stack, constants;

			B = B > 255 and constants[B-256].data or stack[B];
			C = C > 255 and constants[C-256].data or stack[C];

			stack[instruction.A] = B / C;
		end," },
            {16,@"function(instruction) 	-- MOD
			local B = instruction.B;
			local C = instruction.C;
			local stack, constants = stack, constants;

			B = B > 255 and constants[B-256].data or stack[B];
			C = C > 255 and constants[C-256].data or stack[C];

			stack[instruction.A] = B % C;
		end," },
            {17,@"function(instruction)	-- POW
			local B = instruction.B;
			local C = instruction.C;
			local stack, constants = stack, constants;

			B = B > 255 and constants[B-256].data or stack[B];
			C = C > 255 and constants[C-256].data or stack[C];

			stack[instruction.A] = B ^ C;
		end," },
            {18,@"function(instruction)	-- UNM
			stack[instruction.A] = -stack[instruction.B]
		end," },
            {19,@"function(instruction)	-- NOT
			stack[instruction.A] = not stack[instruction.B]
		end," },
            {20,@"function(instruction)	-- LEN
			stack[instruction.A] = #stack[instruction.B]
		end," },
            {21,@"function(instruction)	-- CONCAT
			local B = instruction.B
			local result = stack[B]
			for i = B+1, instruction.C do
				result = result .. stack[i]
			end
			stack[instruction.A] = result
		end," },
            {22,@"function(instruction)	-- JUMP
			IP = IP + instruction.sBx
		end,"},
            {23,@"function(instruction)	-- EQ
			local A = instruction.A
			local B = instruction.B
			local C = instruction.C
			local stack, constants = stack, constants

			A = A ~= 0
			if (B > 255) then B = constants[B-256].data else B = stack[B] end
			if (C > 255) then C = constants[C-256].data else C = stack[C] end
			if (B == C) ~= A then
				IP = IP + 1
			end
		end," },
            {24,@"function(instruction)	-- LT
			local A = instruction.A
			local B = instruction.B
			local C = instruction.C
			local stack, constants = stack, constants

			A = A ~= 0
			B = B > 255 and constants[B-256].data or stack[B]
			C = C > 255 and constants[C-256].data or stack[C]
			if (B < C) ~= A then
				IP = IP + 1
			end
		end," },
            {25,@"function(instruction)	-- LT
			local A = instruction.A
			local B = instruction.B
			local C = instruction.C
			local stack, constants = stack, constants

			A = A ~= 0
			B = B > 255 and constants[B-256].data or stack[B]
			C = C > 255 and constants[C-256].data or stack[C]
			if (B <= C) ~= A then
				IP = IP + 1
			end
		end," },
            {26,@"function(instruction)	-- TEST
			local A = stack[instruction.A];
			if (not not A) == (instruction.C == 0) then
				IP = IP + 1
			end
		end," },
            {27,@"function(instruction)	-- TESTSET
			local stack = stack
			local B = stack[instruction.B]

			if (not not B) == (instruction.C == 0) then
				IP = IP + 1
			else
				stack[instruction.A] = B
			end
		end," },
            {28,@"function(instruction)	-- CALL
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
		end," },
            {29,@"function (instruction)	-- TAILCALL
			local A = instruction.A;
			local B = instruction.B;
			local C = instruction.C;
			local stack = stack;
			local args, results;
			local top, limit, loop = top

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
					args[#args+1] = stack[i];
				end

				results = {stack[A](unpack(args, 1, limit-A))};
			else
				results = {stack[A]()};
			end

			return true, results
		end," },
            {30,@"function(instruction) -- RETURN
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
		end," },
            {31,@"function(instruction)	-- FORLOOP
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
		end," },
            {32,@"function(instruction)	-- FORPREP
			local A = instruction.A
			local stack = stack

			stack[A] = stack[A] - stack[A+2]
			IP = IP + instruction.sBx
		end," },
            {33,@"function(instruction)	-- TFORLOOP
			local A = instruction.A
			local B = instruction.B
			local C = instruction.C
			local stack = stack

			local offset = A+2
			local result = {stack[A](stack[A+1], stack[A+2])}
			for i = 1, C do
				stack[offset+i] = result[i]
			end

			if stack[A+3] ~= nil then
				stack[A+2] = stack[A+3]
			else
				IP = IP + 1
			end
		end," },
            {34,@"function(instruction)	-- SETLIST
			local A = instruction.A
			local B = instruction.B
			local C = instruction.C
			local stack = stack

			if C == 0 then
				error('NYI: extended SETLIST')
			else

                local offset = (C - 1) * 50

                local t = stack[A]

				if B == 0 then

                    B = top

                end
				for i = 1, B do

                    t[offset+i] = stack[A+i]

                end

            end

        end," },
            {35,@"function(instruction)	-- CLOSE
			io.stderr:write('NYI: CLOSE')

            io.stderr:flush()

        end," },
            {36,@"function(instruction)	-- CLOSURE
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
		end," },
            {37,@"function(instruction)	-- VARARG
			local A = instruction.A
			local B = instruction.B
			local stack, vararg = stack, vararg

			for i = A, A + (B > 0 and B - 1 or vararg_size) do
				stack[i] = vararg[i - A]
			end
		end," }
        };

    }
}
