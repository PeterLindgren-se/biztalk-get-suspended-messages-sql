param
(
  [parameter (Mandatory = $true)] [string]$QueryFileName
 ,[parameter (Mandatory = $true)] [string]$folderName
 ,[parameter (Mandatory = $false)] [switch]$UsePartID
)

Push-Location
# 0x0100000 = 1 Mbyte
$RSmessages = Invoke-Sqlcmd -ServerInstance "btscludbmsg-pr\bts-msg01,50004" -Database "BizTalkMsgBoxDb" -InputFile $QueryFileName -MaxBinaryLength 0x0100000
$RSMessagesCount = $RSmessages.Length
Write-Output "Message count: $RSMessagesCount"

$RSmessages | % {
  if ($_.nvcMessageType -ne [System.DBNull]::Value)
  {
    $messageTypePart = $_.nvcMessageType.Replace(":", "_").Replace("/", "_")
  }
  else
  {
    $messageTypePart = "no_message_type"
  }
  if ($UsePartID)
  {
    $baseFileName = ($_.nvcBodyPartName.ToString() + "_" + $messageTypePart + "_" + $_.uidPartID.ToString())
  }
  else
  {
    $baseFileName = ($_.nvcBodyPartName.ToString() + "_" + $messageTypePart + "_" + $_.uidMessageID.ToString())
  }

  #
  # BizTalk splits a large message part in a multi-part message in
  # fragments.
  #
  # Each message part is compressed before fragmentation, but if the
  # compressed size requires more than 1 fragment, the message part
  # is fragmented first and then each fragment is compressed
  # individually.
  #
  # The first fragment is alwas placed in [imgPart] in [Parts] table.
  # Furter fragments are placed in the [Fragments] table.
  #
  # Data are compressed if:
  #   numFragments == 1 && UncompressedLengthPart != DatalengthPart
  # or
  #   numFragments > 1 && UncompressedLengthFragment != DatalengthFragment
  #
  #   In this latter case, always UncompressedLengthPart > DatalengthPart,
  #   since [DatalengthPart] is the length of the  first fragment (000)
  #   while [UncompressedLengthPart] is the uncompressed length of the
  #   complete message part.
  #
  # Note: Small messages have DatalengthPart > UncompressedLengthFragment
  # (due to a compression header and algorithmic difficulties compressing
  # small amounts of data, hence "-ne" instead of "-gt" in the expression)
  #

  $isCompressed = ""
  if ( (($_.nNumFragments -eq 1) -and ($_.UncompressedLengthPart -ne $_.DatalengthPart)) -or (($_.nNumFragments -gt 1) -and ($_.UncompressedLengthFragment -ne $_.DatalengthFragment)) )
  {
    $isCompressed = ".compressed"
  }

  $fragmentNumber = 0
  $fragmentNamePart = "_fragment" + $fragmentNumber.ToString("000")
  #
  # Is this row a small message without extra fragments, or a large message including the
  # second fragment?
  # Then write the base fragment (fragment 0) from imgPart
  # (The sql query performs a left join so that we always get the base fragment in [imgPart]
  # for all rows fÃ¶r fragmented message parts)
  #
  if (($_.nNumFragments -eq 1) -or (($_.nNumFragments -gt 1) -and ($_.nFragmentNumber -eq 1)))
  {
    # skriv imgPart
    $fileName = "$baseFileName$fragmentNamePart$isCompressed"
    $bytesToWrite = $_.DatalengthPart
    Write-Output "Writing imgPart $bytesToWrite bytes to $fileName"
    [System.IO.File]::WriteAllBytes("$folderName\$fileName", $_.imgPart[0..($bytesToWrite-1)])
  }
  #
  # Does this row have a fragment, write it:
  #
  if ($_.nNumFragments -gt 1)
  {
    $fragmentNumber = $_.nFragmentNumber
    $fragmentNamePart = "_fragment" + $fragmentNumber.ToString("000")
    $fileName = "$baseFileName$fragmentNamePart$isCompressed"
    $bytesToWrite = $_.DatalengthFragment
    Write-Output "Writing imgFrag $bytesToWrite bytes to $fileName"
    [System.IO.File]::WriteAllBytes("$folderName\$fileName", $_.imgFrag[0..($bytesToWrite-1)])
  }
}
Pop-Location
