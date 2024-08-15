using System;
using System.IO;
using Microsoft.BizTalk.Agent.Interop;
using Microsoft.BizTalk.Component.Interop;
using Microsoft.BizTalk.Message.Interop;

/// <summary>
/// https://github.com/PeterLindgren-se/biztalk-get-suspended-messages-sql
/// </summary>
namespace biztalk_deserialize_context
{
    class Program
    {
        static int Main(string[] args)
        {
            if (args.Length == 0)
            {
				WL("Must supply a file name.");
				return 1;
            }
			String inputFilename = args[0];

			if (!File.Exists(inputFilename))
			{
				WL("Supplied file does not exist: " + inputFilename);
				return 3;
			}

			Stream stream = File.OpenRead(args[0]);
			IBaseMessageContext context = ((IBTMessageAgentFactory)((IBTMessageAgent)new BTMessageAgent())).CreateMessageContext();
			((IPersistStream)context).Load(stream);

			WL("Context properties count: " + context.CountProperties);

			for (int i = 0; i < context.CountProperties; i++)
			{
				object propValue = context.ReadAt(i, out String propName, out String propNamespace);
				String strNameAndType = propNamespace + "#" + propName + " (type " + propValue.GetType().ToString() + ")";

				if (propValue.GetType() != typeof(String[]))
				{
					WL(strNameAndType + " = '" + propValue.ToString() + "'");
				} 
				else
                {
					int j = 0;
                    foreach (var str in (propValue as String[]))
                    {
						WL(strNameAndType + "[" + j.ToString() + "] = '" + str + "'");
						j++;
					}
				}
			}
			stream.Close();
			return 0;
		}

		private static void WL(String text)
		{
			Console.WriteLine(text);
		}
	}
}
