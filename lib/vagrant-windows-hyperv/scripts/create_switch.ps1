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

  # Find the current IP address of the host. This will be used later to test the
  # network connectivity upon creating a new switch to a network adapter
  $ip = (Get-WmiObject -class win32_NetworkAdapterConfiguration -Filter 'ipenabled = "true"').ipaddress[0]

  $switch_exist = (Get-VMSwitch -SwitchType  "$type" `
    | Select-Object Name `
    | Where-Object { $_.name -eq $name })

  $max_attempts = 5
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
        $max_attempts = $max_attempts - 1
        sleep 5
      }
    }
    while (!$operation_pass -and $max_attempts -gt 0)
   }

   # On creating a new switch / a new network adapter, there are chances that
   # the network may get disconnected for a while.

   # Keep checking for network availability before exiting this script
   $max_attempts = 10
   do {
     $network_available = $false
     try {
      $ping_response = Test-Connection "$ip" -ErrorAction "stop"
      $network_available = $true
     } catch {
        $max_attempts = $max_attempts - 1
        sleep 5
     }
   }
   while (!$network_available -and $max_attempts -gt 0)

   # Add the switch to the VM's network adapter
   $vm = Get-VM -Id $vm_id -ErrorAction "stop"
    Get-VMSwitch "$name" | Where-Object { $_.SwitchType -eq "$type" } `
    | Connect-VMNetworkAdapter -VMName $vm.Name

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
