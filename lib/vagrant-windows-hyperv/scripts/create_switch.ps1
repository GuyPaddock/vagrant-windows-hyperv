#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
param (
    [string]$type = $(throw "-type is required."),
    [string]$name = $(throw "-name is required."),
    [string]$vm_id = $(throw "-vm_id is required."),
    [string]$adapter = ""
 )

# Include the following modules
$presentDir = Split-Path -parent $PSCommandPath
$modules = @()
$modules += $presentDir + "\utils\write_messages.ps1"
forEach ($module in $modules) { . $module }

try {
  $switch_exist = (Get-VMSwitch -SwitchType  "$type" `
    | Select-Object Name `
    | Where-Object { $_.name -eq $name })

  $count = 0
  $operation_pass = $false
  if (-not $switch_exist ) {
    do {
      try {
        if ($type -ne "external") {
          New-VMSwitch -Name "$name" -SwitchType "$type" -ErrorAction "stop"
        } else {
          New-VMSwitch -Name "$name" -NetAdapterName $adapter -ErrorAction "stop"
        }
        $operation_pass = $true
      } catch {
        sleep 5
      }
    }
    while (!$operation_pass -and $count -lt 5)
   }

   $resultHash = @{
     message = "OK"
   }
   Write-Output-Message $resultHash
} catch {
    $errortHash = @{
      type = "PowerShellError"
      error = "$_"
    }
    Write-Error-Message $errortHash
}
