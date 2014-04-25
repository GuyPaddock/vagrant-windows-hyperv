#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

param (
    [string]$type = $(throw "-type is required."),
    [string]$name = $(throw "-name is required.")
 )

 # Include the following modules
$Dir = Split-Path $script:MyInvocation.MyCommand.Path
. ([System.IO.Path]::Combine($Dir, "utils\write_messages.ps1"))

try {
  if ($type -eq "external") {
    $switch_exist = Get-VMSwitch -SwitchType  "$type"
    if ($switch_exist) {
      $resptHash = @{
        message = "switch exist"
      }
      Write-Output-Message $(ConvertTo-JSON $resptHash)
      return
    }
  }

  $switch_exist = (Get-VMSwitch -SwitchType  "$type" `
    | Select-Object Name `
    | Where-Object { $_.name -eq $name })
  if ($switch_exist) {
    $resptHash = @{
      message = "switch exist"
    }
  } else {
    $resptHash = @{
      message = "switch not exist"
    }
  }
    Write-Output-Message $(ConvertTo-JSON $resptHash)
    return
} catch {
  $errortHash = @{
    type = "PowerShellError"
    error = "$_"
  }
  Write-Error-Message $(ConvertTo-JSON $errortHash)
}
