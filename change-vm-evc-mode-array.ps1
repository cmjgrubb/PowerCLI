<#
Author: CMJ Grubb
Date: 12/10/2021

Description: This script will iterate through a list of hostnames, shutting each down, changing the EVC mode, and then powering it back up.
#>

# Site-specific variables
## VM names in vCenter
$vm_name = @('admin', 'DC2')

## vCenter hostname or IP
$vcenter_server = 'vcenter.fcsa-water.local'

## Desired EVC Mode
$evc_mode = 'intel-broadwell'


# Connect to Vcenter
Connect-VIServer -Server $vcenter_server

foreach($node in $vm_name)
{
    # Shutdown VM and pause the script
    Shutdown-VMGuest -VM $node -Confirm:$false
    Start-Sleep -Seconds 60

    # Change EVC Mode
    $vm = Get-VM -Name $node
    $featureMasks = $global:DefaultVIServer.ExtensionData.Capability.SupportedEVCMode | Where-Object {$_.key -eq $evc_mode} | Select-Object -ExpandProperty FeatureMask
    $vm.ExtensionData.ApplyEvcModeVM_Task($featureMasks,$true)

    # Start VM
    Start-VM $node
}
