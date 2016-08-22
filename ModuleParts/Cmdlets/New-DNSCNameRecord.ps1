<#
.Synopsis
	New-DNSCNameRecord creates an object of type DNSCNameRecord in the Infoblox database.
.DESCRIPTION
	New-DNSCNameRecord creates an object of type DNSCNameRecord in the Infoblox database.  If creation is successful an object of type IB_DNSCNameRecord is returned.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER Name
	The Name of the new dns record.  This should be a valid FQDN, and the infoblox should be authoritative for the provided zone.
.PARAMETER Canonical
	The 'pointer' or canonical value of the new dns record.  Should be a valid FQDN, but infoblox does not need any control or authority of the zone
.PARAMETER View
	The Infoblox view to create the record in.  The provided value must match a valid view on the Infoblox, and the zone specified in the Name parameter must be present in the specified view.  If no view is provided the default DNS view is used.
.PARAMETER Comment
	Optional comment field for the dns record.  Can be used for notation and keyword searching by Get- cmdlets.
.PARAMETER TTL
	Optional parameter to specify a record-specific TTL.  If not specified the record inherits the Grid TTL
.EXAMPLE
	New-DNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -Name testalias.domain.com -Canonical testrecord.domain.com

		Name      : testalias.domain.com
		Canonical : testrecord.domain.com
		Comment   :
		View      : default
		TTL       : 0
		Use_TTL   : False
		_ref      : record:cname/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkYWR1dGwwMWNvcnAsMTAuOTYuMTA1LjE5MQ:testalias.domain.com/default

	description
	-----------
	This example creates a dns record with no comment, in the default view, and no record-specific TTL
.EXAMPLE
	New-DNSCNameRecord -Gridmaster $Gridmaster -Credential $Credential -Name Testalias2.domain.com -canonical testrecord2.domain.com -comment 'new record' -view default -ttl 100

		Name      : testalias2.domain.com
		Canonical : testrecord2.domain.com
		Comment   : new record
		View      : default
		TTL       : 100
		Use_TTL   : True
		_ref      : record:cname/ZG5zLmJpbmRfYSQuX2RlZmF1bHQuY29tLmVwcm9kLHBkZGNlcGQwMWhvdW1yaWIsMTAuNzUuMTA4LjE4MA:testalias2.domain.com/default

	description
	-----------
	This example creates a dns record with a comment, in the default view, with a TTL of 100 to override the grid default
.INPUTS
	System.Net.IPAddress[]
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_DNSCNameRecord
#>
Function New-DNSCNameRecord {
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateScript({If ($_){Test-connection -ComputerName $_ -Count 1 -Quiet}})]
        [ValidateNotNullorEmpty()]
        [String]$Gridmaster,

        [Parameter(Mandatory=$True)]
        [System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [String]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [String]$Canonical,

        [String]$View,

        [String]$Comment,

        [uint32]$TTL = 4294967295

    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
        write-verbose "$FunctionName`:  Beginning Function"
        Write-Verbose "$FunctionName`:  Connecting to Infoblox device $gridmaster to retrieve Views"
        Try {
             $IBViews = Get-InfobloxView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView
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
        If ($ttl -eq 4294967295){
            $use_ttl = $False
            $ttl = $Null
        } else {
            $use_TTL = $True
        }
        If ($pscmdlet.ShouldProcess($Name)){
            $output = [IB_DNSCNameRecord]::Create($Gridmaster, $Credential, $Name, $Canonical, $Comment, $View, $ttl, $use_ttl)
            $output
        }
    }
    
    END{}
}
