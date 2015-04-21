<#
	Clone-VM
#>
function Clone-VM {
	
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$TRUE)]
			[string]$vmName,
		[Parameter(Mandatory=$TRUE)]
			[string]$template,
		[string]$vmPath,
		[string]$vhdpath,
		[String]$VMHostName="$env:COMPUTERNAME"
		)

	$VMHost = Get-VMHost -computerName $VMHostName

	$vmPath = $VMHost.VirtualMachinePath
	$vhdPath = "Virtual Hard Disks"

	try {
		$templateVM = get-vm -Name $template -ErrorAction Stop
	} catch {
		Write-Host -ForeGroundColor Red "Error: Could not find template VM: $template"
		Break
	}

	Try {
		$newVHD = "$vmPath\$vmName\$vhdPath\$vmName.vhdx"
	} catch {
		"Error: Unable to create .vhdx"
	}
	$parVMPath = $templateVM.HardDrives[0].Path

	New-Item -Path $VMPath -ItemType Directory -Name $vmName

	New-Item -Path "$VMPath\$vmName" -ItemType Directory -Name $vhdPath

	New-VHD -Path "$vmPath\$vmName\$vhdPath\$vmName.vhdx" -ParentPath $parVMPath -Differencing

	New-VM -Name $vmName -MemoryStartupBytes $templateVM.MemoryStartup -SwitchName $templateVM.NetworkAdapters[0].SwitchName -Generation 2 -Path "$VMPath\$vmName"

	Add-VMHardDiskDrive -VMName $vmName -Path $newVHD -ControllerType SCSI

	Add-VMDvdDrive -VMName $vmName

}