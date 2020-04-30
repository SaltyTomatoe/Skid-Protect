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
                else
                {
                    Console.WriteLine("Outside of unicode: " + number + " " + (char)number);

                }
                array[i] = (char)number;
            }
            return new string(array);
        }

        

    }
}
