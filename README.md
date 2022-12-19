# biztalk-get-suspended-messages-sql
Code examples on how to download, in bulk, suspended messages directly from the message box database.

The accompanying article is on Microsoft TechNet Wiki: https://social.technet.microsoft.com/wiki/contents/articles/54330.biztalk-server-download-suspended-messages-in-bulk-from-sql-server.aspx

The code was developed on a BizTalk Server 2013 (not the R2) but should work with newer versions as well.

Usage Overview
==============
Refer to the Usage Details section below before actually following these instructions.
1. Save these files in a new location.
2. Compile the C# program.
3. Choose either of the two SQL scripts, depending on whether you need all messages (possibly of a specific message type), or messages pertaining to a specific service instance.
4. Adjust the SQL and Powershell scripts.
5. Create a subfolder for data.
6. Run the Powershell script to retrieve the data.
7. Decompress the files using the compiled program.
8. Move away the compressed files.
9. Concatenate the fragments
10. Done!

Usage Details
==============

1. Copy the files to a new folder, this example uses E:\tmp\get-suspended-messages\.
   Start powershell from that folder (otherwise the process' current directory will be the Windows' System32 directory).
```
   cd /d E:\tmp\get-suspended-messages\
   powershell
```
2. Compile the C# program:
   Choose the same framework version as your BizTalk version requires, preferably compile it on the BizTalk server:
   
   `c:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe -out:biztalk-decompress-message.exe biztalk-decompress-message.cs`

3. Edit the SQL and Powershell files:

   a) Add where-conditions in the SQL query file, for example if you only want to select a certain message type, NULL for messages with no message type; or a specific service instance ID.
   
   b) Set server/instance name and database name in the Powershell script.

4. Create a subfolder 'data' for data files:

   `New-Item -Path . -Name data -Type Directory -Force`

5. Run the Powershell script:

   `.\biztalk-get-suspended-messages.ps1 .\biztalk-get-suspended-messages.sql .\data`
   
   Or, if you are dealing with a specific suspended instance, for example an XLang Multi-Part message's parts:
   
   `.\biztalk-get-suspended-messages.ps1 .\biztalk-get-suspended-messages-for-service-instance.sql .\data -UsePartID`

6. Decompress the files:

   The syntax for the biztalk-decompress-message.exe program is as follows:
   
     `biztalk-decompress-message.exe filename.compressed [BizTalk program files folder]`
     
   The compressed-filename must end with .compressed.
   The second argument is the folder name of your BizTalk installation (where Microsoft.BizTalk.Pipeline.dll resides),
   the program defaults to "D:\Program Files (x86)\Microsoft BizTalk Server 2013".
   
   `Get-ChildItem -Path .\data -Filter "*.compressed" | % { .\biztalk-decompress-message.exe $_.FullName }`

7. Move the original compressed files to a subfolder, to get them out of the way for the concatenation:
```
   New-Item -Path .\data\ -Name compressed -Type Directory -Force
   Move-Item .\data\*.compressed -Destination .\data\compressed\
```
8. Concatenate the fragments (they are called \_fragment000 and upwards) to rebuild the files:

   `.\concatenate-fragments.ps1 .\data\`

9. Done!
   The concatenated, complete files have the extension .out.
