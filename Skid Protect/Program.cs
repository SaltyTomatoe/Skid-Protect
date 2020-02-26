using System;
using System.Diagnostics;
using System.IO;
namespace Skid_Protect
{
	class Program
    {
		static string directory = Directory.GetCurrentDirectory();

		static byte[] Get_Bytecode(string file)
        {
            string code = File.ReadAllText(file);
			string OS = Environment.OSVersion.Platform == PlatformID.Unix ? "/usr/bin/" : "";
			string l = Path.Combine(directory, "luac.out");
			string d = Path.Combine(directory, file);
			Console.WriteLine("Checking file...\n");

			Process proc = new Process
			{
				StartInfo =
						   {
							   FileName  = $"{OS}luac",
							   Arguments = "-o \"" + l + "\" \"" + file + "\"",
							   UseShellExecute = false,
							   RedirectStandardError = true,
							   RedirectStandardOutput = true
						   }
			};

			string err = "";

			proc.OutputDataReceived += (sender, args) => { err += args.Data; };
			proc.ErrorDataReceived += (sender, args) => { err += args.Data; };

			proc.Start();
			proc.BeginOutputReadLine();
			proc.BeginErrorReadLine();
			proc.WaitForExit();

			byte[] to_return = File.ReadAllBytes(l);
			File.Delete(l);

			return to_return;
		}
        static void Main(string[] args)
        {
			var watch = System.Diagnostics.Stopwatch.StartNew();

			byte[] bytecode = Get_Bytecode("Code.lua");

			Console.WriteLine("\nSerializing Bytecode & Fixing LUA VM");

			string lbi = File.ReadAllText(Path.Combine(directory, "LBI.lua"));
			string Compiled_VM = Serializer.Serialize(bytecode,lbi);

			Console.WriteLine("\nFinished generating LUA VM");

			File.WriteAllText(Path.Combine(directory,"Output.lua"), Compiled_VM);

			// the code that you want to measure comes here
			watch.Stop();
			var elapsedMs = watch.ElapsedMilliseconds;
			Console.WriteLine("Elapsed Time: " + elapsedMs + "ms");
			Console.ReadKey();
            return;
        }
    }
}
