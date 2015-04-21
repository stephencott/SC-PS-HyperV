<#
	New-CloneVM
#>
function New-CloneVM {
	
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

	#Get a reference to the VM to be copied. Stop the script if there is an 
	#error
	try {
		$templateVM = Get-VM -Name $template -ErrorAction Stop
	} catch {
		Write-Host -ForeGroundColor Red "Error: Could not find template VM: $template"
		Break
	}

	#Set the path to the new VHD and the path to the Parent VHD to difference
	#Possibly add the ability to clone all Hard Disks associated to the VM
	$newVHD = "$vmPath\$vmName\$vhdPath\$vmName.vhdx"
	$parVMPath = $templateVM.HardDrives[0].Path

	Try {
		New-Item -Path $VMPath -ItemType Directory -Name $vmName
		New-Item -Path "$VMPath\$vmName" -ItemType Directory -Name $vhdPath
	} catch {
		Write-Output "Unable to create directory: $($_.ToString())"
	}

	New-VHD -Path "$vmPath\$vmName\$vhdPath\$vmName.vhdx" -ParentPath $parVMPath -Differencing

	New-VM -Name $vmName -MemoryStartupBytes $templateVM.MemoryStartup -SwitchName $templateVM.NetworkAdapters[0].SwitchName -Generation 2 -Path "$VMPath\$vmName"

	Add-VMHardDiskDrive -VMName $vmName -Path $newVHD -ControllerType SCSI

	Add-VMDvdDrive -VMName $vmName

}