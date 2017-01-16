<#
.Synopsis
	New-IBFixedAddress creates an object of type FixedAddress in the Infoblox database.
.DESCRIPTION
	New-IBFixedAddress creates an object of type FixedAddress in the Infoblox database.  If creation is successful an object of type IB_FixedAddress is returned.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER Name
	The Name of the device to which the IP Address is reserved.
.PARAMETER IPAddress
	The IP Address for the fixedaddress assignment.  Standard IPv4 notation applies, and a string value must be castable to an IPAddress object.
.PARAMETER MAC
	The mac address for the fixed address reservation.  Colon separated format of 00:00:00:00:00:00 is required.  If the parameter is left blank or a MAC of 00:00:00:00:00:00 is used, the address is marked as type "reserved" in the infoblox database.  If a non-zero mac address is provided the IP is reserved for the provided MAC, and the MAC must not be assigned to any other IP Address.
.PARAMETER NetworkView
	The Infoblox networkview to create the record in.  The provided value must match a valid view on the Infoblox, and the subnet for the provided IPAddress must exist in the specified view.  If no view is provided the default network view is used.
.PARAMETER Comment
	Optional comment field for the record.  Can be used for notation and keyword searching by Get- cmdlets.
.EXAMPLE
	New-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential Name Server01 -IPAddress 192.168.1.1

		Name        : Server01
		IPAddress   : 192.168.1.1
		Comment     :
		NetworkView : default
		MAC         : 00:00:00:00:00:00
		_ref        : fixedaddress/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:192.168.1.1/default

	description
	-----------
	This example creates an IP reservation for 192.168.1.1 with no comment in the default view
.EXAMPLE
	New-IBFixedAddress -Gridmaster $Gridmaster -Credential $Credential -Name Server02.domain.com -IPAddress 192.168.1.2 -comment 'Reservation for Server02' -view default -MAC '11:11:11:11:11:11'

		Name      : Server02
		IPAddress : 192.168.1.2
		Comment   : Reservation for Server02
		View      : default
		MAC       : 11:11:11:11:11:11
		_ref      : fixedaddress/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:192.168.1.2/default

	description
	-----------
	This example creates a dhcp reservation for 192.168.1.1 to the machine with MAC address 11:11:11:11:11:11
.INPUTS
	System.Net.IPAddress[]
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_FixedAddress
#>
Function New-IBFixedAddress {
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [ValidateNotNullorEmpty()]
        [String]$Gridmaster,

        [Parameter(Mandatory=$True)]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [IPAddress]$IPAddress,

		[ValidatePattern('^([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})$')]
		[String]$MAC = '00:00:00:00:00:00',

        [String]$Name,

        [String]$NetworkView,

        [String]$Comment
    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
        write-verbose "$FunctionName`:  Beginning Function"
        Write-Verbose "$FunctionName`:  Connecting to Infoblox device $gridmaster to retrieve Views"
        Try {
            $IBViews = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type NetworkView
        } Catch {
            Write-error "Unable to connect to Infoblox device $gridmaster.  Error code:  $($_.exception)" -ea Stop
        }
        If ($NetworkView){
            Write-Verbose "$FunctionName`:  Validating View parameter against list from Infoblox device"
            If ($IBViews.name -cnotcontains $NetworkView){
                $NetworkViewList = $ibviews.name -join ', '
                write-error "Invalid data for View parameter.  Options are $NetworkViewList" -ea Stop
            }
        }

    }

    PROCESS{
        If ($pscmdlet.ShouldProcess($IPAddress)){
            $output = [IB_FixedAddress]::Create($Gridmaster, $Credential, $Name, $IPAddress, $Comment, $NetworkView, $MAC)
            $output
        }
    }
    END{}
}
