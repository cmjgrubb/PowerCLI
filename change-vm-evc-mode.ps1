<#
Author: CMJ Grubb
Date: 12/10/2021

Description: This script will accept the name of the VM, shut it down, change the EVC mode, and then power it back up.
#>

# Site-specific variables
## vCenter hostname or IP
$vcenter_server = 'vcenter.fcsa-water.local'

## Desired EVC Mode
$evc_mode = 'intel-broadwell'


# Prompt user for VM name
$vm_name = Read-Host 'Enter VM name: '

# Connect to Vcenter
$first_time = Read-Host 'Is this the first VM of the session? (y/n) '
if(($first_time -eq 'y') -or ($first_time -eq 'Y'))
{
    Connect-VIServer -Server $vcenter_server
}

# Print current EVC mode
Write-Host 'Current EVC mode:'
Get-VM -Name $vm_name | select Name,HardwareVersion,@{Name='EvcMode';Expression={$_.ExtensionData.Runtime.MinRequiredEVCModeKey}}

# Shutdown VM and pause the script
Shutdown-VMGuest -VM $vm_name -Confirm:$false
Start-Sleep -Seconds 30

# Change EVC Mode
$vm = Get-VM -Name $vm_name
$featureMasks = $global:DefaultVIServer.ExtensionData.Capability.SupportedEVCMode | Where-Object {$_.key -eq $evc_mode} | Select-Object -ExpandProperty FeatureMask
$vm.ExtensionData.ApplyEvcModeVM_Task($featureMasks,$true)

# Start VM
Start-VM $vm_name

# Print updated EVC mode
Write-Host 'Updated EVC mode:'
Get-VM -Name $vm_name | select Name,HardwareVersion,@{Name='EvcMode';Expression={$_.ExtensionData.Runtime.MinRequiredEVCModeKey}}
