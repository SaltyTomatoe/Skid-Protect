using System;
using System.Diagnostics;
using System.IO;
namespace Skid_Protect
{
	class Program
    {
		static string directory = Directory.GetCurrentDirectory();
		static string OS = Environment.OSVersion.Platform == PlatformID.Unix ? "/usr/bin/" : "";
		static byte[] Get_Bytecode(string file)
        {
            string code = File.ReadAllText(file);
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

			string output_file = Path.Combine(directory, "t2.lua");
			string minified_finish = Path.Combine(directory, "Output.lua");
			File.WriteAllText(output_file, Compiled_VM);

			Console.WriteLine("\nMinifying");
			Process proc = new Process
			{
				StartInfo =
						   {
							   FileName  = $"{OS}lua",
							   Arguments = "Lua/Minifier/luasrcdiet.lua --maximum --opt-entropy --opt-emptylines --opt-eols --opt-numbers --opt-whitespace --opt-locals --noopt-strings  -o \"" + minified_finish + "\" \"" + output_file + "\"",
							   UseShellExecute = false,
							   RedirectStandardError = true,
							   RedirectStandardOutput = true
						   }
			};

			string err = "";

			proc.OutputDataReceived += (sender, args) => { err += args.Data;};
			proc.ErrorDataReceived += (sender, args) => { err += args.Data;};
			proc.Start();
			proc.BeginOutputReadLine();
			proc.BeginErrorReadLine();
			proc.WaitForExit();
			//File.Delete(output_file);
			// the code that you want to measure comes here
			watch.Stop();
			var elapsedMs = watch.ElapsedMilliseconds;
			Console.WriteLine("Finished.\nElapsed Time: " + elapsedMs + "ms");
			Console.ReadKey();
            return;
        }
    }
}
