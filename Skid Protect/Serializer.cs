using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;

namespace Skid_Protect
{
	public class Serializer
	{
		//get_int should be get_int32 etc
		static string[] lua_opcode_types = {
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
		};
		class Opcode_Information
		{
			public int NewName { get; set; }
			public int OldName { get; set; }
			public int Type { get; set; }
			public int A { get; set; }
			public int B { get; set; }
			public int C { get; set; }
			public int Bx { get; set; }
			public int sBx { get; set; }
			public int TimesUsed { get; set; }
			public int indexIn { get; set; }
			public StringBuilder instrString { get; set; }
		}
		
		static bool big_endian = false;
		static int int_size = 4;
		static int size_t = 4;
		static bool opcodes_first = false;
		static byte[] bytecode;
		static int index = 0;
		static int MOVE_OPCODE = 0;
		static int GETUPVAL_OPCODE = 0;

		static public StringBuilder opcode_funcs = new StringBuilder();
		static private Dictionary<int, Opcode_Information> Opcodes_Used_in_Closure = new Dictionary<int, Opcode_Information>();

		static Random random = new Random();

		[MethodImpl(MethodImplOptions.AggressiveInlining)]
		public static List<int> GenerateRandom(int count, int min, int max)
		{

			if (max <= min || count < 0 ||
					(count > max - min && max - min > 0))
			{
				throw new ArgumentOutOfRangeException("Range " + min + " to " + max +
						" (" + ((Int64)max - (Int64)min) + " values), or count " + count + " is illegal");
			}

			HashSet<int> candidates = new HashSet<int>();
			for (int top = max - count; top < max; top++)
			{
				if (!candidates.Add(random.Next(min, top + 1)))
				{
					candidates.Add(top);
				}
			}
			List<int> result = candidates.ToList();
			for (int i = result.Count - 1; i > 0; i--)
			{
				int k = random.Next(i + 1);
				int tmp = result[k];
				result[k] = result[i];
				result[i] = tmp;
			}
			return result;
		}

		[MethodImpl(MethodImplOptions.AggressiveInlining)]
		static int get_int8()
		{
			int a = bytecode[index];
			index = index + 1;
			return a;
		}
		[MethodImpl(MethodImplOptions.AggressiveInlining)]
		static int get_int32()
		{
			int a = bytecode[index];
			index = index + 1;
			int b = bytecode[index];
			index = index + 1;
			int c = bytecode[index];
			index = index + 1;
			int d = bytecode[index];
			index = index + 1;
			return d * 16777216 + c * 65536 + b * 256 + a;
		}
		[MethodImpl(MethodImplOptions.AggressiveInlining)]
		static StringBuilder toInt32(int num)
		{
			int a, b, c, d;
			a = b = c = d = 0;
			while (true)
			{
				if (num >= 256)
				{
					if (num >= 65536)
					{
						if (num >= 16777216)
						{
							num -= 16777216;
							d++;
						}
						else
						{
							num -= 65536;
							c++;
						}
					}
					else
					{
						num -= 256;
						b++;
					}
				}
				else
				{
					a = num;
					break;
				}
			}
			return new StringBuilder().Append("\\").Append(a).Append("\\").Append(b).Append("\\").Append(c).Append("\\").Append(d);
		}
		[MethodImpl(MethodImplOptions.AggressiveInlining)]

		static string get_string(bool has_len = false, int len = 0)
		{
			if (has_len == false)
			{
				len = get_int32();//we're expecting this due to the fact that it should be like that
			}
			StringBuilder str = new StringBuilder(len + 4);
			if (len == 0) return str.ToString();
			for (int i = 0; i != len; i++)
			{
				str.Append((char)bytecode[index + i]);
			}
			index = index + len;
			string str2 = EncryptionLib.Rot13(str.ToString().Substring(0, str.Length - 1));
			StringBuilder r = new StringBuilder();
			byte[] a = Encoding.ASCII.GetBytes(str2);
			foreach(byte z in a)
			{
				r.Append("\\").Append(z);
			}
			return toInt32(len) + r.ToString() + "\\0";
		}

		static private StringBuilder Serialize()
		{
			StringBuilder nBytecode = new StringBuilder();
			List<int> Available_Opcodes = GenerateRandom(38, 0, 100);
			void decode_chunk()
			{
				//instructions!
				int num = 0;
				get_string(); //funtion name 
				get_int32();//first line 
				get_int32();//last line 

				var ups = get_int8();//chunk upvalues
				get_int8();//chunk arguments
				get_int8();//chunk varg
				get_int8();//chunk stack

				//Values
				StringBuilder instructs = new StringBuilder();
				List<Opcode_Information> InstructionList = new List<Opcode_Information>();
				StringBuilder consts = new StringBuilder();
				int instrs_Count = 0;
				//end

				nBytecode.Append("\\").Append(ups);

				num = get_int32();
				//instructs.Append(toInt32(num));
				for (int i = 0; i != num; i++)
				{

					var instruction = new Opcode_Information();
					StringBuilder newInstruction = new StringBuilder();
					int data = get_int32();
					int opcode = (data & 0x3F);
					string opcode_type = lua_opcode_types[opcode];
					//Console.WriteLine(opcode);
					int newName;
					if (Opcodes_Used_in_Closure.ContainsKey(opcode) == false)
					{
						instruction.OldName = opcode;
						newName = Available_Opcodes.First<int>();
						instruction.NewName = newName;
						Available_Opcodes.Remove(newName);
						Opcodes_Used_in_Closure.Add(opcode, instruction);
					}
					else
					{
						newName = Opcodes_Used_in_Closure[opcode].NewName;
						instruction.OldName = opcode;
					}

					if (opcode == 0) { MOVE_OPCODE = newName; }

					if (opcode == 4) { GETUPVAL_OPCODE = newName; }

					newInstruction.Append("\\").Append(newName);

					instruction.indexIn = i;
					instruction.A = (data >> 6) & 0xFF;
					StringBuilder bin = new StringBuilder();
					switch (opcode_type)
					{
						case "ABC":
							instruction.Type = 1;
							instruction.B = (data >> 6 + 8 + 9) & 0x1FF; //Inst B
							instruction.C = (data >> 6 + 8) & 0x1FF; // Inst C

							newInstruction.Append("\\").Append(instruction.Type);

							bin.Append(Convert.ToString(instruction.C, 2).PadLeft(9, '0'));
							bin.Append(Convert.ToString(instruction.B, 2).PadLeft(9, '0'));
							bin.Append(Convert.ToString(instruction.A, 2).PadLeft(7, '0'));
							newInstruction.Append(toInt32(Convert.ToInt32(bin.ToString(), 2)));
							break;
						case "ABx":
							instruction.Type = 2;
							instruction.Bx = (data >> 6 + 8) & 0x3FFFF; //Inst Bx
							newInstruction.Append("\\").Append(instruction.Type);

							bin.Append(Convert.ToString(instruction.Bx, 2).PadLeft(18, '0'));
							bin.Append(Convert.ToString(instruction.A, 2).PadLeft(7, '0'));
							newInstruction.Append(toInt32(Convert.ToInt32(bin.ToString(), 2)));
							break;
						case "AsBx":
							instruction.Type = 3;

							instruction.sBx = ((data >> 6 + 8) & 0x3FFFF); //sBx
							newInstruction.Append("\\").Append(instruction.Type);
							bin.Append(Convert.ToString(instruction.sBx, 2).PadLeft(18, '0'));
							bin.Append(Convert.ToString(instruction.A, 2).PadLeft(7, '0'));
							newInstruction.Append(toInt32(Convert.ToInt32(bin.ToString(), 2)));
							break;
					}
					instruction.instrString = newInstruction;
					//Console.WriteLine(InstructionList.Count + 1);
					InstructionList.Add(instruction);
					//Console.WriteLine(nBytecode.ToString() + " " + opcode_type);
				}
				int amount = InstructionList.Count;
				bool isFirst = true;
				int d = 0;
				List<int> nums = GenerateRandom(amount, 0, amount);// Available_Opcodes.First<int>()
				Dictionary<int, StringBuilder> rePositionedFunctions = new Dictionary<int, StringBuilder>();
				List<StringBuilder> JMPCalls = new List<StringBuilder>();

				//"print hi" == (getglobal print => loadk hi => call => return nil)
				foreach (var item in InstructionList)
				{
					instrs_Count++;
					d++;
					if (ObfuscationSettings.CFObfuscation && false)//&& random.NextDouble() > 0.5)
					{
						int jmp_To = nums.First<int>(); //where we insert the instruction
						nums.RemoveAt(0);//don't allow duplicates

						Console.WriteLine(item.OldName + " | " + jmp_To);
						rePositionedFunctions[jmp_To] = item.instrString;

						var instruction = new Opcode_Information();
						StringBuilder newInstruction = new StringBuilder();
						int opcode = 38;
						//Console.WriteLine(opcode);
						int newName;
						if (Opcodes_Used_in_Closure.ContainsKey(opcode) == false)
						{
							instruction.OldName = opcode;
							newName = opcode;// Available_Opcodes.First<int>();
							instruction.NewName = newName;
							Available_Opcodes.Remove(newName);
							Opcodes_Used_in_Closure.Add(opcode, instruction);
						}
						else
						{
							newName = Opcodes_Used_in_Closure[opcode].NewName;
							instruction.OldName = opcode;
						}
						newInstruction.Append("\\").Append(newName);


						instruction.A = 0;
						StringBuilder bin = new StringBuilder();
						instruction.Type = 3;

						//calculate jmp
						
						instruction.sBx = 131071 + jmp_To;
						newInstruction.Append("\\").Append(instruction.Type);
						bin.Append(Convert.ToString(instruction.sBx, 2).PadLeft(18, '0'));
						bin.Append(Convert.ToString(instruction.A, 2).PadLeft(7, '0'));
						newInstruction.Append(toInt32(Convert.ToInt32(bin.ToString(), 2)));
						instruction.instrString = newInstruction;
						//Console.WriteLine(InstructionList.Count + 1);
						JMPCalls.Add(newInstruction);

						d++;
						instrs_Count++;
					}
					else
					{
						instructs.Append(item.instrString);
					}
					isFirst = false;
				}
				if (ObfuscationSettings.CFObfuscation)
				{
					int i = 0;
					foreach(var jmp_call in JMPCalls)
					{
						var func = rePositionedFunctions[i];
						Console.WriteLine(jmp_call + " - " + func);
						instructs.Append(jmp_call).Append(func);
						i++;
					}
				}


				//Console.WriteLine(nBytecode.ToString());

				//Constants next!
				num = get_int32();
				consts.Append(toInt32(num));
				for (int i = 0; i != num; i++)
				{
					int type = get_int8(); //type of constant 

					consts.Append("\\").Append(type);
					switch (type)
					{
						case 1:
							//bool data_bool = (get_int8() != 0);
							consts.Append("\\").Append(get_int8());
							break;
						case 3:
							//get float
							for (int x = 0; x != 8; x++)
							{
								consts.Append("\\").Append(get_int8());
							}
							break;
						case 4:
							consts.Append(get_string());
							//if (unfiltered.Length - 2 < 0)
							//{

							//}
							//string data_string = unfiltered.Substring(1, unfiltered.Length - 2);
							break;
					}
				}

				//randomize stuff 
				opcodes_first = true;//random.NextDouble() > 0.5;
				if (opcodes_first)
				{
					nBytecode.Append(toInt32(instrs_Count) + instructs.ToString());
					nBytecode.Append(consts.ToString());
				}
				else
				{
					nBytecode.Append(consts.ToString());
					nBytecode.Append(instructs.ToString());
				}
				

				//prototypes
				num = get_int32();
				nBytecode.Append(toInt32(num));
				for (int i = 0; i != num; i++)
				{
					decode_chunk();
				}

				//DEBUG INFOOOOOO MY FAVORITE!
				num = get_int32();
				for (int i = 0; i != num; i++)
				{
					get_int32(); // line numbers
				}

				//locals
				num = get_int32();
				for (int i = 0; i != num; i++)
				{
					get_string(); // local name 
					get_int32(); //start of pc 
					get_int32(); // end of pc 
				}

				//upvalues
				num = get_int32();
				for (int i = 0; i != num; i++)
				{
					get_string();//upvalue name 
				}
				//debug info end
			}

			//headerrrrr
			get_string(true, 4); // should be \27Lua -- Header thing 
			get_int8(); //0x51 Version Control
			get_int8(); //Official Bytecode
			big_endian = (get_int8() == 0); // big endian 
			int_size = get_int8();//int size 
			size_t = get_int8();//size t size 

			get_string(true, 3);// \4\8\0
			decode_chunk();
			return nBytecode;
		}
		static private string format_lbi(string lbi, string bytecode, string opcodes, string opcodes_Closure)
		{

			lbi = lbi.Replace("%%Bytecode%%", bytecode);
			lbi = lbi.Replace("--%%OPCODE_FUNCTIONS_HERE%%--", opcodes);
			lbi = lbi.Replace("--%%CLOSURE_FUNCTIONS_HERE%%--", opcodes_Closure);
			lbi = lbi.Replace("--//Lmao so like, this is kidna worthless", "local lmao_so_this_kinda_worthless = " + EncryptionLib.Xored_Table("Lmao so like, this is kidna worthless"));
			lbi = lbi.Replace("\"instructions\"", EncryptionLib.Xored_Table("instructions"));
			lbi = lbi.Replace("\"constants\"", EncryptionLib.Xored_Table("constants"));
			lbi = lbi.Replace("\"prototypes\"", EncryptionLib.Xored_Table("prototypes"));
			lbi = lbi.Replace("\"opcode\"", EncryptionLib.Xored_Table("opcode"));
			lbi = lbi.Replace("MOVE_OPCODE", MOVE_OPCODE.ToString());
			lbi = lbi.Replace("GETUPVAL_OPCODE", GETUPVAL_OPCODE.ToString());

			if (ObfuscationSettings.discardReturn)
			{
				lbi = lbi.Replace("--return ", "");
			}
			else
			{
				lbi = lbi.Replace("--return ", "return ");
			}

			if (opcodes_first)
			{
				lbi = lbi.Replace("--VM STRING ONE", VM_Strings.INSTRUCTIONS);
				lbi = lbi.Replace("--VM STRING TWO", VM_Strings.CONSTANTS);
			}
			else
			{
				lbi = lbi.Replace("--VM STRING ONE", VM_Strings.CONSTANTS);
				lbi = lbi.Replace("--VM STRING TWO", VM_Strings.INSTRUCTIONS);
			}
			return lbi;
		}
		static public string Serialize(byte[] a1, string a2)
		{
			bytecode = a1;
			StringBuilder bytes = Serialize();
			StringBuilder opcodes_Closure = new StringBuilder();
			int f1 = 0;
			//format the used ops in closure
			foreach (var item in Opcodes_Used_in_Closure.Values)
			{
				if (f1 == 0)
				{
					opcodes_Closure.Append("\n if instruction[opco] == " + item.NewName + " then \n").Append(Opcodes.ops[item.OldName]);
				}
				else
				{
					opcodes_Closure.Append("\n elseif instruction[opco] == " + item.NewName + " then \n").Append(Opcodes.ops[item.OldName]);
				}
				f1++;
				if (f1 == Opcodes_Used_in_Closure.Count)
				{
					opcodes_Closure.Append("\n end");
				}
			}
			//end
			string lbi = format_lbi(a2, bytes.ToString(), opcode_funcs.ToString(),opcodes_Closure.ToString());
			return lbi;
		}
	}
}