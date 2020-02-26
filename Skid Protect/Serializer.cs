using System;
using System.Collections.Generic;
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

		int bitExtracted(int number, int k, int p)
		{
			return (((1 << k) - 1) & (number >> (p - 1)));
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
					if(num > 256)
					{
						if (num > 65536)
						{
							if (num> 16777216)
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
			Double get_float64()
			{
				byte[] s = new byte[8];
				for (int i = 0; i != 8; i++)
				{
					s[i] = (byte)get_int8();
				}
				return BitConverter.ToDouble(s);
			}
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

				num = get_int32();

				nBytecode.Append("\\").Append(ups);
				nBytecode.Append(toInt32(num));

				for (int i = 0; i != num; i++)
				{

					var instruction = new Opcode_Information();
				
					int data = get_int32();
					int opcode = (data & 0x3F);
					string opcode_type = lua_opcode_types[opcode];

					nBytecode.Append("\\").Append(opcode);

					instruction.A = (data >> 6) & 0xFF;
					nBytecode.Append("\\").Append(instruction.A);
					switch (opcode_type)
					{
						case "ABC":
							instruction.Type = 1;
							instruction.B = (data >> 6 + 8 + 9) & 0x1FF; //Inst B
							instruction.C = (data >> 6 + 8) & 0x1FF; // Inst C

							nBytecode.Append("\\").Append(instruction.Type);
							nBytecode.Append("\\").Append(instruction.B);
							nBytecode.Append("\\").Append(instruction.C);
							break;
						case "ABx":
							instruction.Type = 2;
							instruction.Bx = (data >> 6 + 8) & 0x3FFFF; //Inst Bx
							nBytecode.Append("\\").Append(instruction.Type);
							nBytecode.Append("\\").Append(instruction.Bx);
							break;
						case "AsBx":
							instruction.Type = 3;
							instruction.sBx = ((data >> 6 + 8) & 0x3FFFF); //sBx

							nBytecode.Append("\\").Append(instruction.Type);
							nBytecode.Append("\\").Append(instruction.sBx);
							break;
					}
				}

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
							Double data_float = get_float64();
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
		static private string format_lbi(string lbi, string bytecode, string opcodes)
		{

			lbi = lbi.Replace("%%Bytecode%%", bytecode);
			//lbi = lbi.Replace("--%%OPCODE_FUNCTIONS_HERE%%--", opcodes);
			return lbi;
		}
		static public string Serialize(byte[] a1, string a2)
		{
			StringBuilder bytecode = Serialize(a1);
			string lbi = format_lbi(a2, bytecode.ToString(), "");
			return lbi;
		}
	}
}