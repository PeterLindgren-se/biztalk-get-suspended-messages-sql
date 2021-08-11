param
(
  [parameter (Mandatory = $true)] [string]$folderName
)

# First, create the main file with the first (and possibly only) fragment:
Get-ChildItem .\data\*_fragment000 | ForEach-Object {
  $dataDir = $_.Directory
  $isMatch = $_.Name -match '(.*)_fragment000'
  $mainName = $Matches[1].ToString() + ".out"
  Write-Host "First fragment of $dataDir\$mainName"
  Copy-Item $_.FullName -Destination $dataDir\$mainName
}
# Then, concatenate the other possible fragments in order:
Get-ChildItem .\data\*_fragment??? -Exclude *_fragment000 | Sort-Object | ForEach-Object {
  $dataDir = $_.Directory
  $isMatch = $_.Name -match '(.*)_fragment(\d{3})'
  $mainName = $Matches[1].ToString() + ".out"
  $fragmentNo = $Matches[2].ToString()
  Write-Host "Adding fragment $fragmentNo to $dataDir\$mainName"
  Get-Content $_.FullName -Raw -Encoding Byte | Add-Content $dataDir\$mainName -Encoding Byte
}