# Run this script to create a folder you can upload to GitHub (no node_modules).
# Right-click this file -> Run with PowerShell
# Then upload the contents of the new folder "ems-for-github" to your GitHub repo.

$source = $PSScriptRoot
$dest = Join-Path $PSScriptRoot "ems-for-github"

if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
New-Item -ItemType Directory -Path $dest | Out-Null

$exclude = @('node_modules', '.git', 'ems-for-github', '.env')
function Copy-Excluding {
  param($from, $to)
  Get-ChildItem $from -Force | ForEach-Object {
    if ($exclude -contains $_.Name) { return }
    $target = Join-Path $to $_.Name
    if ($_.PSIsContainer) {
      New-Item -ItemType Directory -Path $target -Force | Out-Null
      Copy-Excluding $_.FullName $target
    } else {
      Copy-Item $_.FullName $target -Force
    }
  }
}

Copy-Excluding $source $dest
Write-Host "Done. Folder created: $dest"
Write-Host "Upload the CONTENTS of this folder to GitHub (not the folder itself)."
explorer $dest
