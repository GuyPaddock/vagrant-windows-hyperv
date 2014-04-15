#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
# Include the following modules
$Dir = Split-Path $script:MyInvocation.MyCommand.Path
. ([System.IO.Path]::Combine($Dir, "utils\write_messages.ps1"))

param (
    [string]$vm_id = $(throw "-vm_id is required.")
 )

try {
  $vm = Get-VM -Id $vm_id -ErrorAction "stop"
  $network_adapter = Get-VMNetworkAdapter Super-Win_1_1
  $resultHash = @{}
  $resultHash["switch_name"] = $network_adapter.SwitchName
  $resultHash["network_adapter"] = $network_adapter.Name
  Write-Output-Message $resultHash
} catch [Microsoft.HyperV.PowerShell.VirtualizationOperationFailedException] {
  $errortHash = @{
    type = "PowerShellError"
    error = "$_"
  }
  Write-Error-Message $errortHash
}
