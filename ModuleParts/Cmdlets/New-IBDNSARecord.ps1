<#
.Synopsis
	New-IBDNSARecord creates an object of type DNSARecord in the Infoblox database.
.DESCRIPTION
	New-IBDNSARecord creates an object of type DNSARecord in the Infoblox database.  If creation is successful an object of type IB_DNSARecord is returned.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER Name
	The Name of the new dns record.  This should be a valid FQDN, and the infoblox should be authoritative for the provided zone.
.PARAMETER IPAddress
	The IP Address for the new dns record.  Standard IPv4 notation applies, and a string value must be castable to an IPAddress object.
.PARAMETER View
	The Infoblox view to create the record in.  The provided value must match a valid view on the Infoblox, and the zone specified in the name parameter must be present in the specified view.  If no view is provided the default DNS view is used.
.PARAMETER Comment
	Optional comment field for the dns record.  Can be used for notation and keyword searching by Get- cmdlets.
.PARAMETER TTL
	Optional parameter to specify a record-specific TTL.  If not specified the record inherits the Grid TTL
.EXAMPLE
	New-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -Name testrecord.domain.com -IPAddress 192.168.1.1

		Name      : testrecord.domain.com
		IPAddress : 192.168.1.1
		Comment   :
		View      : default
		TTL       : 0
		Use_TTL   : False
		_ref      : record:a/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:testrecord.domain.com/default

	description
	-----------
	This example creates a dns record with no comment, in the default view, and no record-specific TTL
.EXAMPLE
	New-IBDNSARecord -Gridmaster $Gridmaster -Credential $Credential -Name TestRecord2.domain.com -IPAddress 192.168.1.2 -comment 'new record' -view default -ttl 100

		Name      : testrecord2.domain.com
		IPAddress : 192.168.1.2
		Comment   : new record
		View      : default
		TTL       : 100
		Use_TTL   : True
		_ref      : record:a/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:testrecord2.domain.com/default

	description
	-----------
	This example creates a dns record with a comment, in the default view, with a TTL of 100 to override the grid default
.INPUTS
	System.Net.IPAddress[]
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_DNSARecord
#>
Function New-IBDNSARecord {
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory=$False)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [String]$Gridmaster,

        [Parameter(Mandatory=$False)]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [String]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [IPAddress]$IPAddress,

        [String]$View,

        [String]$Comment,

        [uint32]$TTL = 4294967295

    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
        write-verbose "$FunctionName`:  Beginning Function"
		If (! $script:IBSession){
			write-verbose "Existing session to infoblox gridmaster does not exist."
			If ($gridmaster -and $Credential){
				write-verbose "Creating session to $gridmaster with user $($credential.username)"
				New-IBWebSession -gridmaster $Gridmaster -Credential $Credential -erroraction Stop
			} else {
				write-error "Missing required parameters to connect to Gridmaster" -ea Stop
			}
		} else {
			write-verbose "Existing session to $script:IBgridmaster found"
		}
        Write-Verbose "$FunctionName`:  Connecting to Infoblox device $script:IBgridmaster to retrieve Views"
        Try {
            $IBViews = Get-IBView -Type DNSView
        } Catch {
            Write-error "Unable to connect to Infoblox device $script:IBgridmaster.  Error code:  $($_.exception)" -ea Stop
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
        If ($ttl -eq 4294967295){
            $use_ttl = $False
            $ttl = $Null
        } else {
            $use_TTL = $True
        }
        If ($pscmdlet.ShouldProcess($Name)){
            $output = [IB_DNSARecord]::Create($Script:IBGridmaster,$Script:IBSession,$Global:WapiVersion,$Name, $IPAddress, $Comment, $View, $ttl, $use_ttl)
            $output
        }
    }
    END{}
}
