<#
.Synopsis
	New-IBDNSZone creates an object of type DNSARecord in the Infoblox database.
.DESCRIPTION
	New-IBDNSZone creates an object of type DNSARecord in the Infoblox database.  If creation is successful an object of type IB_DNSARecord is returned.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER FQDN
	The fully qualified name of the zone to create.  This should be a valid FQDN for the zone that is to be created.
.PARAMETER ZoneFormat
	The format of the zone to be created. The default value is Forward.  Valid Values are:
        •FORWARD
        •IPV4
        •IPV6

.PARAMETER View
	The Infoblox view to create the zone in.  The provided value must match a valid view on the Infoblox.  If no view is provided the default DNS view is used.
.PARAMETER Comment
	Optional comment field for the dns zone.  Can be used for notation and keyword searching by Get- cmdlets.
.EXAMPLE
	New-IBDNSZone -Gridmaster $Gridmaster -Credential $Credential -zone domain.com -zoneformat Forward -comment 'new zone'

	This example creates a forward-lookup dns zone in the default view
.EXAMPLE
	New-IBDNSZone -Gridmaster $Gridmaster -Credential $Credential  -zoneformat IPV4 -fqdn 10.in-addr-arpa

	This example creates a reverse lookup zone for the 10.0.0.0 network in the default dns view
.INPUTS
	System.String
.OUTPUTS
	IB_ZoneAuth
#>
Function New-IBDNSZone {
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory=$False)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [ValidateNotNullorEmpty()]
        [String]$Gridmaster,

        [Parameter(Mandatory=$False)]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [String]$FQDN,

        [ValidateSet('Forward','IPv4','IPv6')]
        [String]$ZoneFormat,

        [String]$View,

        [String]$Comment
    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
        write-verbose "$FunctionName`:  Beginning Function"
		If (! $script:IBSession){
			write-verbose "Existing session to infoblox gridmaster does not exist."
			If ($gridmaster -and $Credential){
				write-verbose "Creating session to $gridmaster with user $credential"
				New-IBWebSession -gridmaster $Gridmaster -Credential $Credential -erroraction Stop
			} else {
				write-error "Missing required parameters to connect to Gridmaster"
				return
			}
		}
        Write-Verbose "$FunctionName`:  Connecting to Infoblox device $script:IBgridmaster to retrieve Views"
        Try {
            $IBViews = Get-IBView -Type DNSView
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
        If ($pscmdlet.ShouldProcess($fqdn)){
            $output = [IB_ZoneAuth]::Create($FQDN, $View, $ZoneFormat, $Comment)
            $output
        }
    }
    END{}
}
