#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

param (
    [string]$type = $(throw "-type is required."),
    [string]$name = $(throw "-name is required."),
    [string]$vm_id = $(throw "-vm_id is required.")
 )

try {
# Add the switch to the VM's network adapter
   $vm = Get-VM -Id $vm_id -ErrorAction "stop"
    Get-VMSwitch "$name" | Where-Object { $_.SwitchType -eq "$type" } `
    | Connect-VMNetworkAdapter -VMName $vm.Name

   $resultHash = @{
     message = "OK"
   }
   Write-Output-Message $(ConvertTo-JSON $resultHash)
 }
 catch {
  $errortHash = @{
    type = "PowerShellError"
    error = "$_"
  }
  Write-Error-Message $(ConvertTo-JSON $errortHash)
 }
