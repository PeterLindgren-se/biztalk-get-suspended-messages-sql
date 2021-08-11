# biztalk-get-suspended-messages-sql
Code examples on how to download, in bulk, suspended messages directly from the message box database.

The code was developed on a BizTalk Server 2013 (not the R2) but should work with newer versions as well.

Usage Overview
==============
Refer to the Usage Details section below before actually following these instructions.
1. Save these files in a new location.
2. Compile the C# program.
3. Adjust the SQL and Powershell scripts.
4. Create a subfolder for data.
5. Run the Powershell script to retrieve the data.
6. Decompress the files using the compiled program.
7. Move away the compressed files.
8. Concatenate the fragments
9. Done!

Usage Details
==============

1. Copy the files to a new folder, this example uses E:\tmp\get-suspended-messages\.
   Start powershell from that folder (otherwise the process' current directory will be the Windows' System32 directory).
   
   cd /d E:\tmp\get-suspended-messages\
   powershell

2. Compile the C# program:
   Choose the same framework version as your BizTalk version requires, preferably compile it on the BizTalk server:
   
   c:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe -out:biztalk-decompress-message.exe biztalk-decompress-message.cs

3. Edit the SQL and Powershell files:

   a) Add where-conditions in the SQL query file, for example if you only want to select a certain message type. NULL for messages with no message type.
   
   b) Set server/instance name and database name in the Powershell script.

4. Create a subfolder 'data' for data files:

   New-Item -Path . -Name data -Type Directory -Force

5. Run the Powershell script:

   .\biztalk-get-suspended-messages.ps1 .\biztalk-get-suspended-messages.sql .\data

6. Decompress the files:

   The syntax for the biztalk-decompress-message.exe program is as follows:
   
     biztalk-decompress-message.exe filename.compressed [BizTalk program files folder]
     
   The compressed-filename must end with .compressed.
   The second argument is the folder name of your BizTalk installation (where Microsoft.BizTalk.Pipeline.dll resides),
   the program defaults to "D:\Program Files (x86)\Microsoft BizTalk Server 2013".
   
   Get-ChildItem -Path .\data -Filter "*.compressed" | % { .\biztalk-decompress-message.exe $_.FullName }

7. Move the original compressed files to a subfolder, to get them out of the way for the concatenation:

   New-Item -Path .\data\ -Name compressed -Type Directory -Force
   
   Move-Item .\data\*.compressed -Destination .\data\compressed\
   
8. Concatenate the fragments (they are called _fragment000 and upwards) to rebuild the files:

   .\concatenate-fragments.ps1 .\data\

9. Done!
   The concatenated, complete files have the extension .out.
