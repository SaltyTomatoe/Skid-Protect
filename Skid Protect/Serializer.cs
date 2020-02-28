using System;
using System.Collections.Generic;
using System.Linq;
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
		}
		
		static bool big_endian = false;
		static int int_size = 4;
		static int size_t = 4;

		static public StringBuilder opcode_funcs = new StringBuilder();
		static private Dictionary<int, Opcode_Information> Opcodes_Used_in_Closure = new Dictionary<int, Opcode_Information>();

		static Random random = new Random();

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
		int bitExtracted(int number, int k, int p)
		{
			return (((1 << k) - 1) & (number >> (p - 1)));
		}

		public static string ByteConvert(int num)
		{
			int[] p = new int[8];
			string pa = "";
			for (int ii = 0; ii <= 7; ii = ii + 1)
			{
				p[7 - ii] = num % 2;
				num = num / 2;
			}
			for (int ii = 0; ii <= 7; ii = ii + 1)
			{
				pa += p[ii].ToString();
			}
			return pa;
		}
		//private int get_int;
		//private int get_size_t;

		static private int get_byte(string a)
		{
			byte[] stuff = ASCIIEncoding.ASCII.GetBytes(a);
			return (int)stuff[0];
		}

		static private StringBuilder Serialize(byte[] bytecode)
		{
			StringBuilder nBytecode = new StringBuilder();
			List<int> Available_Opcodes = GenerateRandom(38, 0, 100);
			int index = 0;
			int get_int8()
			{
				int a = bytecode[index];
				index = index + 1;
				return a;
			}
			int get_int32()
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
			StringBuilder toInt32(int num)
			{
				int a, b, c, d;
				a = b = c = d = 0;
				while (true)
				{
					if(num >= 256)
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
			//Double get_float64()
			//{
			//	byte[] s = new byte[8];
			//	for (int i = 0; i != 8; i++)
			//	{
			//		s[i] = (byte)get_int8();
			//	}
			//	return BitConverter.ToDouble(s);
			//}
			StringBuilder get_string(bool has_len = false, int len = 0)
			{
				if (has_len == false)
				{
					len = get_int32();//we're expecting this due to the fact that it should be like that
				}
				StringBuilder str = new StringBuilder(len + 4);
				str.Append(toInt32(len));
				if (len == 0) return str;
				for (int i = 0; i != len; i++)
				{
					str.Append("\\").Append(bytecode[index + i]);
				}
				index = index + len;
				return str;
			}

			void decode_chunk(bool is_proto = false)
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

				num = get_int32();

				nBytecode.Append("\\").Append(ups);
				nBytecode.Append(toInt32(num));

				for (int i = 0; i != num; i++)
				{

					var instruction = new Opcode_Information();
				
					int data = get_int32();
					int opcode = (data & 0x3F);
					string opcode_type = lua_opcode_types[opcode];

					if (is_proto == false)
					{
						opcode_funcs.Append("\ninstruction = instructions[IP];IP = IP + 1\n").Append(Opcodes.ops[opcode]);
					}
					else
					{
						instruction.OldName = opcode;
						var newName = Available_Opcodes.First<int>();
						instruction.NewName = newName;
						Available_Opcodes.Remove(newName);
						if (Opcodes_Used_in_Closure.ContainsKey(opcode) == false)
						{
							Opcodes_Used_in_Closure.Add(opcode, instruction);
						}
						nBytecode.Append("\\").Append(newName);
					}

					instruction.A = (data >> 6) & 0xFF;
					StringBuilder bin = new StringBuilder();
					switch (opcode_type)
					{
						case "ABC":
							instruction.Type = 1;
							instruction.B = (data >> 6 + 8 + 9) & 0x1FF; //Inst B
							instruction.C = (data >> 6 + 8) & 0x1FF; // Inst C

							nBytecode.Append("\\").Append(instruction.Type);

							bin.Append(Convert.ToString(instruction.C, 2).PadLeft(9, '0'));
							bin.Append(Convert.ToString(instruction.B, 2).PadLeft(9, '0'));
							bin.Append(Convert.ToString(instruction.A, 2).PadLeft(7, '0'));
							nBytecode.Append(toInt32(Convert.ToInt32(bin.ToString(), 2)));
							break;
						case "ABx":
							instruction.Type = 2;
							instruction.Bx = (data >> 6 + 8) & 0x3FFFF; //Inst Bx
							nBytecode.Append("\\").Append(instruction.Type);

							bin.Append(Convert.ToString(instruction.Bx, 2).PadLeft(18, '0'));
							bin.Append(Convert.ToString(instruction.A, 2).PadLeft(7, '0'));
							nBytecode.Append(toInt32(Convert.ToInt32(bin.ToString(), 2)));
							break;
						case "AsBx":
							instruction.Type = 3;

							instruction.sBx = ((data >> 6 + 8) & 0x3FFFF) - 131071; //sBx
							nBytecode.Append("\\").Append(instruction.Type);
							
							bin.Append(Convert.ToString(instruction.Bx, 2).PadLeft(18, '0'));
							bin.Append(Convert.ToString(instruction.A, 2).PadLeft(7, '0'));
							nBytecode.Append(toInt32(Convert.ToInt32(bin.ToString(), 2)));
							break;
					}
					//Console.WriteLine(nBytecode.ToString() + " " + opcode_type);
				}

				//Console.WriteLine(nBytecode.ToString());

				//Constants next!
				num = get_int32();
				nBytecode.Append(toInt32(num));
				for (int i = 0; i != num; i++)
				{
					int type = get_int8(); //type of constant 

					nBytecode.Append("\\").Append(type);
					switch (type)
					{
						case 1:
							//bool data_bool = (get_int8() != 0);
							nBytecode.Append("\\").Append(get_int8());
							break;
						case 3:
							//get float
							for (int x = 0; x != 8; x++)
							{
								nBytecode.Append("\\").Append(get_int8());
							}
							break;
						case 4:
							StringBuilder unfiltered = get_string();
							nBytecode.Append(unfiltered.ToString());
							//if (unfiltered.Length - 2 < 0)
							//{

							//}
							//string data_string = unfiltered.Substring(1, unfiltered.Length - 2);
							break;
					}
				}

				//prototypes
				num = get_int32();
				nBytecode.Append(toInt32(num));
				for (int i = 0; i != num; i++)
				{
					decode_chunk(true);
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
			return lbi;
		}
		static public string Serialize(byte[] a1, string a2)
		{
			StringBuilder bytecode = Serialize(a1);
			StringBuilder opcodes_Closure = new StringBuilder();
			//format the used ops in closure
			foreach (var item in Opcodes_Used_in_Closure.Values)
			{
				opcodes_Closure.Append("\n[" + item.NewName + "] = ").Append(Opcodes.ops_table[item.OldName]);
			}
			//end
			string lbi = format_lbi(a2, bytecode.ToString(), opcode_funcs.ToString(),opcodes_Closure.ToString());
			return lbi;
		}
	}
}