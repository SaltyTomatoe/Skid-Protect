using System;
using System.Collections.Generic;
using System.Text;

namespace Skid_Protect
{
    class VM_Strings
    {
        public static string INSTRUCTIONS = @"for i = 1, get_int32() do
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
			--print(instruction.opcode,instruction.sBx)
			instructions[i] = instruction;
		end
		--if true then return end";
		public static string CONSTANTS = @"for i = 1, get_int32() do
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
		end";

	}
}
