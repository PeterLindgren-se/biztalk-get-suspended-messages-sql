# biztalk-get-suspended-messages-sql
Code examples on how to download, in bulk, suspended messages directly from the message box database.
The code also downloads the messages' context, and contains an example on how to load and show them.

The accompanying article is on Microsoft TechNet Wiki: https://social.technet.microsoft.com/wiki/contents/articles/54330.biztalk-server-download-suspended-messages-in-bulk-from-sql-server.aspx

The code was developed on a BizTalk Server 2013 (not the R2) and works with newer versions as well (tested on BizTalk 2020).

Usage Overview
==============
Refer to the Usage Details section below before actually following these instructions.
1. Save these files in a new location.
2. Compile the C# programs.
3. Choose either of the two SQL scripts, depending on whether you need all messages (possibly of a specific message type), or messages pertaining to a specific service instance.
4. Adjust the SQL and Powershell scripts.
5. Create a subfolder for data.
6. Run the Powershell script to retrieve the data.
7. Decompress the files using the compiled program.
8. Move away the compressed files.
9. Concatenate the fragments.
10. Optionally, view a message's context properties.
11. Done!

Usage Details
==============

1. Copy the files to a new folder, this example uses E:\tmp\get-suspended-messages\.
   Start powershell from that folder (otherwise the process' current directory will be the Windows' System32 directory).
   ```
   cd /d E:\tmp\get-suspended-messages\
   powershell
   ```

1. Compile the C# programs:
   Choose the same framework version as your BizTalk version requires, preferably compile it on the BizTalk server:
   ```
   c:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe -out:biztalk-decompress-message.exe biztalk-decompress-message.cs

   c:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe -out:biztalk-deserialize-context.exe biztalk-deserialize-context.cs -reference:c:\Windows\Microsoft.NET\assembly\GAC_MSIL\Microsoft.BizTalk.Interop.Agent\v4.0_3.0.1.0__31bf3856ad364e35\Microsoft.Biztalk.Interop.Agent.dll,c:\Windows\Microsoft.NET\assembly\GAC_MSIL\Microsoft.BizTalk.Pipeline\v4.0_3.0.1.0__31bf3856ad364e35\Microsoft.BizTalk.Pipeline.dll
   ```
   For your convenience, there is also a Visual Studio 2019 solution for the deserialization program.

1. Choose whether you need all messages, all messages of a certain message type, or all messages pertaining to a specific service instance (orchestration or messaging).

1. Edit the SQL and Powershell files:

   a) Add where-conditions in the SQL query file, for example if you only want to select a certain message type, NULL for messages with no message type; or a specific service instance ID.
   
   b) Set server/instance name and database name in the Powershell script.

1. Create a subfolder 'data' for data files:
   ```
   New-Item -Path . -Name data -Type Directory -Force
   ```

1. Run the Powershell script:
   ```
   .\biztalk-get-suspended-messages.ps1 .\biztalk-get-suspended-messages.sql .\data
   ```
   
   Or, if you are dealing with a specific suspended instance, for example an XLang Multi-Part message's parts:
   
   ```
   .\biztalk-get-suspended-messages.ps1 .\biztalk-get-suspended-messages-for-service-instance.sql .\data -UsePartID
   ```

1. Decompress the files:

   The syntax for the biztalk-decompress-message.exe program is as follows:
   
     ```
     biztalk-decompress-message.exe filename.compressed [BizTalk program files folder]
     ```
     
   The compressed-filename must end with .compressed.
   The second argument is the folder name of your BizTalk installation (where Microsoft.BizTalk.Pipeline.dll resides),
   the program defaults to "D:\Program Files (x86)\Microsoft BizTalk Server 2013".
   
   ```
   Get-ChildItem -Path .\data -Filter "*.compressed" | % { .\biztalk-decompress-message.exe $_.FullName }
   ```

1. Move the original compressed files to a subfolder, to get them out of the way for the concatenation:
   ```
   New-Item -Path .\data\ -Name compressed -Type Directory -Force
   Move-Item .\data\*.compressed -Destination .\data\compressed\
   ```

1. Concatenate the fragments (they are called \_fragment000 and upwards) to rebuild the files:
   ```
   .\concatenate-fragments.ps1 .\data\
   ```

1. Optionally, view a message's context properties:
   ```
   .\biztalk-deserialize-context.exe .\data\some-message-type_some-message-guid_fragment000.context
   ```

1. Done!
   The concatenated, complete files have the extension .out.

## References
https://www.connected-thoughts.com/2008/04/02/3-ways-of-programatically-extracting-a-message-body-from-the-biztalk-tracking-database/

https://biztalkmessages.wordpress.com/2009/05/13/unleashing-the-spool-table-well-at-least-partly/

https://maximelabelle.wordpress.com/2009/12/10/serializing-message-context-and-part-properties/

