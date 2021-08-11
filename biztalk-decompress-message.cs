using System;
using System.IO;
using System.Reflection;

public class MyClass
{
	public static void DecompressFile(string inputFilename, string outputFilename, Type compressionStreamsType)
	{
		var compressedInputStream = File.OpenRead(inputFilename);
        var decompressedStream = (Stream)compressionStreamsType.InvokeMember("Decompress", BindingFlags.Public | BindingFlags.InvokeMethod | BindingFlags.Static, null, null, new object[] { (object)compressedInputStream });
		
		int decompressedLength = (int)decompressedStream.Length;
		BinaryReader reader = new BinaryReader(decompressedStream);
		var messageBody = reader.ReadBytes(decompressedLength);
		FileStream outputFS = File.OpenWrite(outputFilename);
		outputFS.Write(messageBody, 0, decompressedLength);
		outputFS.Flush();
		outputFS.Close();
		WL(String.Format("Wrote {0} bytes to {1}", decompressedLength, outputFilename));
		compressedInputStream.Close();
	}
	
	#region Helper methods
	
	public static int Main(string[] args)
	{
		try
		{
			WL("Decompressing BizTalk message parts/fragments");
			if (args.Length < 1 || args.Length > 2)
			{
				WL("Syntax: biztalk-decompress-message.exe filename.compressed [BizTalk program files folder]\r\nThe compressed-filename must end with .compressed");
				return 1;
			}
			string inputFilename = args[0];
			string extension = Path.GetExtension(inputFilename);
			if (extension != ".compressed")
			{
				WL("Supplied file does not end with .compressed");
				return 2;
			}
			if (!File.Exists(inputFilename))
			{
				WL("Supplied file does not exist: " + inputFilename);
				return 3;
			}
			string outputFilename = Path.GetFileNameWithoutExtension(inputFilename);
			if (String.IsNullOrEmpty(outputFilename))
			{
				WL("Supplied file was only extension");
				return 4;
			}
			outputFilename = Path.Combine(Path.GetDirectoryName(inputFilename), outputFilename);
			
			string BizTalkFolder = @"D:\Program Files (x86)\Microsoft BizTalk Server 2013";
			if (args.Length == 2)
			{
				BizTalkFolder = args[1];
			}
			
			Assembly pipelineAssembly = Assembly.LoadFrom(Path.Combine(BizTalkFolder, "Microsoft.BizTalk.Pipeline.dll"));
			Type compressionStreamsType = pipelineAssembly.GetType("Microsoft.BizTalk.Message.Interop.CompressionStreams", true);
			
			DecompressFile(inputFilename, outputFilename, compressionStreamsType);
			return 0;
		}
		catch (Exception e)
		{
			string error = string.Format("---\nThe following error occurred while executing the program:\n{0}\n---", e.ToString());
			Console.WriteLine(error);
			return 9;
		}
		finally
		{
		}
	}


	private static void WL(object text, params object[] args)
	{
		Console.WriteLine(text.ToString(), args);	
	}

	
	private static void RL()
	{
		Console.ReadLine();	
	}

	
	private static void Break() 
	{
		System.Diagnostics.Debugger.Break();
	}

	#endregion
}