using System;
using System.Diagnostics;
using System.IO;
namespace Skid_Protect
{
	class Program
    {
		static string directory = Directory.GetCurrentDirectory();
		static string OS = Environment.OSVersion.Platform == PlatformID.Unix ? "/usr/bin/" : "";
		static (bool failed,string output,byte[]bytecode) Get_Bytecode(string file)
        {
            string code = File.ReadAllText(file);
			string l = Path.Combine(directory, "luac.out");
			string d = Path.Combine(directory, file);

			byte[] to_return;

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

			if (!File.Exists(l)) {
				return (true,"Syntax Error: " + err.Substring(15,err.Length-15), null);
			} 

			to_return = File.ReadAllBytes(l);
			File.Delete(l);

			return (false,null,to_return);
		}
        static void Main(string[] args)
        {
			var watch = System.Diagnostics.Stopwatch.StartNew();

			(bool failed,string output,byte[] bytecode) = Get_Bytecode("Code.lua");

			if (failed) {
				Console.WriteLine(output); return;
			}

				Console.WriteLine("\nSerializing Bytecode & Fixing LUA VM");

			string lbi = File.ReadAllText(Path.Combine(directory, "LBI.lua"));
			string Compiled_VM = Serializer.Serialize(bytecode,lbi);

			Console.WriteLine("\nFinished generating LUA VM");

			string output_file = Path.Combine(directory, "t2.lua");
			string minified_finish = Path.Combine(directory, "Output.lua");
			string luajit = Path.Combine(directory, "Luajit/luajit.exe");
			File.WriteAllText(output_file, Compiled_VM);

			Console.WriteLine("\nMinifying");
			Process proc = new Process
			{
				StartInfo =
						   {
							   FileName  = "cmd.exe",
							   Arguments = "/C luamin -f \"" + output_file + "\"",
							   UseShellExecute = false,
							   RedirectStandardError = true,
							   RedirectStandardOutput = true
						   }
			};

			string err = "";
			string outp = "";
			proc.OutputDataReceived += (sender, args) => { outp += args.Data;};
			proc.ErrorDataReceived += (sender, args) => { err += args.Data;};
			proc.Start();
			proc.BeginOutputReadLine();
			proc.BeginErrorReadLine();
			proc.WaitForExit();
			//File.Delete(output_file);
			if(err != "")
			{
				Console.WriteLine(err);
				return;
			}
			else
			{
				File.WriteAllText(minified_finish, outp);
			}
			watch.Stop();
			var elapsedMs = watch.ElapsedMilliseconds;
			Console.WriteLine("Finished.\nElapsed Time: " + elapsedMs + "ms");
			Console.ReadKey();
            return;
        }
    }
}
