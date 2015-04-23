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
		[String]$VMHostName="$env:COMPUTERNAME",
		[Int]$gen=2
		)

	$VMHost = Get-VMHost -computerName $VMHostName
	$vmConType = Get-VMHardDiskDrive -VMName $VMHostName | Select-Object -ExpandProperty ControllerType

	$vmPath = $VMHost.VirtualMachinePath
	$vhdPath = "Virtual Hard Disks"

	#Get a reference to the VM to be copied. Stop the script if there is an error
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
		New-VHD -Path "$vmPath\$vmName\$vhdPath\$vmName.vhdx" `
			-ParentPath $parVMPath `
			-Differencing `
			-ErrorAction Stop
	} Catch {
		Write-Output "Unable to create VHD: $vmPath\$vmName\$vhdPath\$vmName.vhdx"
	}

	Try {
		New-VM -Name $vmName `
			-MemoryStartupBytes $templateVM.MemoryStartup `
			-SwitchName $templateVM.NetworkAdapters[0].SwitchName `
			-Generation $gen `
			-Path "$VMPath" `
			-ErrorAction Stop
	} Catch {
		Write-Output "Unable to create VM: $vmName at path $vmPath"
	}


	Add-VMHardDiskDrive -VMName $vmName -Path $newVHD -ControllerType $vmConType

	Add-VMDvdDrive -VMName $vmName

}