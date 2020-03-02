using System;
using System.Collections.Generic;
using System.Text;

namespace Skid_Protect
{
    class EncryptionLib
    {
        public static int RandomNumber(int min, int max)
        {
            Random random = new Random();
            return random.Next(min, max);
        }

        public static String Xored_Table(string word)
        {
            StringBuilder ret = new StringBuilder().Append("concat({");
            byte[] asciiBytes = Encoding.ASCII.GetBytes(word);
            foreach (byte i in asciiBytes)
            {
                int number = RandomNumber(50, 1000);
                ret.Append("fix(").Append(i ^ number).Append(",").Append(number).Append("),");
            }
            ret.Append("})");

            return ret.ToString();
        }
        public static string Xored_Number(int number)
        {
            StringBuilder ret = new StringBuilder();
            int xor_val = RandomNumber(50, 1000);
            ret.Append("xor(").Append(number ^ xor_val).Append(",").Append(xor_val).Append(")");
            return ret.ToString();
        }

        public static string Rot13(string value)
        {
            char[] array = value.ToCharArray();
            for (int i = 0; i < array.Length; i++)
            {
                int number = (int)array[i];
                if (number >= 'a' && number <= 'z')
                {
                    if (number > 'm')
                    {
                        number -= 13;
                    }
                    else
                    {
                        number += 13;
                    }
                }
                else if (number >= 'A' && number <= 'Z')
                {
                    if (number > 'M')
                    {
                        number -= 13;
                    }
                    else
                    {
                        number += 13;
                    }
                }
                array[i] = (char)number;
            }
            return new string(array);
        }

        public static List<int> Compress(byte[] uncompressed)
        {
            // build the dictionary
            Dictionary<string, int> dictionary = new Dictionary<string, int>();
            for (int i = 0; i < 256; i++)
                dictionary.Add(((char)i).ToString(), i);

            string w = string.Empty;
            List<int> compressed = new List<int>();

            foreach (byte b in uncompressed)
            {
                string wc = w + (char)b;
                if (dictionary.ContainsKey(wc))
                    w = wc;

                else
                {
                    // write w to output
                    compressed.Add(dictionary[w]);
                    // wc is a new sequence; add it to the dictionary
                    dictionary.Add(wc, dictionary.Count);
                    w = ((char)b).ToString();
                }
            }

            // write remaining output if necessary
            if (!string.IsNullOrEmpty(w))
                compressed.Add(dictionary[w]);

            return compressed;
        }

        public static string ToBase36(ulong value)
        {
            const string base36 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            var sb = new StringBuilder(13);
            do
            {
                sb.Insert(0, base36[(byte)(value % 36)]);
                value /= 36;
            } while (value != 0);
            return sb.ToString();
        }

        public static string CompressedToString(List<int> compressed)
        {
            StringBuilder sb = new StringBuilder();
            foreach (int i in compressed)
            {
                string n = ToBase36((ulong)i);

                sb.Append(ToBase36((ulong)n.Length));
                sb.Append(n);
            }

            return sb.ToString();
        }
    }
}
