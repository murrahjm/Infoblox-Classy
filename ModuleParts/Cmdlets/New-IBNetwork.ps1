<#
.Synopsis
	New-IBNetwork creates an object of type DNSARecord in the Infoblox database.
.DESCRIPTION
	New-IBNetwork creates an object of type DNSARecord in the Infoblox database.  If creation is successful an object of type IB_DNSARecord is returned.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER Network
	The IP address of the network to create in CIDR format
.PARAMETER NetworkView
	The Infoblox network view to create the network in.  The provided value must match a valid view on the Infoblox.  If no view is provided the default network view is used.
.PARAMETER Comment
	Optional comment field for the network.  Can be used for notation and keyword searching by Get- cmdlets.
.EXAMPLE
    New-IBNetwork -Gridmaster $Gridmaster -Credential $Credential -Network '10.0.0.0/8' -networkview default -comment 'new network'
    
    This example creates a new network for 10.0.0.0 in the default view
.INPUTS
	System.String
.OUTPUTS
	IB_Network
#>
Function New-IBNetwork {
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [ValidateNotNullorEmpty()]
        [String]$Gridmaster,

        [Parameter(Mandatory=$True)]
        [System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True)]
        [ValidateScript({If ($_ -match '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$') {
            $True
        } else {
            Throw "$_ is not a CIDR address"
        }})]
        [String]$Network,

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
        If ($View){
            Write-Verbose "$FunctionName`:  Validating View parameter against list from Infoblox device"
            If ($IBViews.name -cnotcontains $View){
                $ViewList = $ibviews.name -join ', '
                write-error "Invalid data for View parameter.  Options are $ViewList" -ea Stop
            }
        }

    }
    PROCESS{
        If ($pscmdlet.ShouldProcess($Network)){
            $output = [IB_Network]::Create($Gridmaster, $Credential, $Network, $NetworkView, $Comment)
            $output
        }
    }
    END{}
}
