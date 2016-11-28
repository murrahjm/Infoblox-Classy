<#
.Synopsis
	Performs a full search of all Infoblox records matching the supplied value.
.DESCRIPTION
	Performs a full search of all Infoblox records matching the supplied value.  Returns defined objects for defined record types, and IB_ReferenceObjects for undefined types.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER IPAddress
	The IP Address to search for.  Standard IPv4 notation applies, and a string value must be castable to an IPAddress object.
.PARAMETER MaxResults
	The maximum number of results to return from the query.  A positive value will truncate the results at the specified number.  A negative value will throw an error if the query returns more than the specified number.
.PARAMETER SearchString
	A string to search for.  Will return any record with the matching string anywhere in a matching string property.  Use with -Strict to match only the exact string.
.PARAMETER Strict
	A switch to specify whether the search of the Name field should be exact, or allow partial word searches or regular expression matching.
.PARAMETER RecordType
	A filter for record searching.  By default this cmdlet will search all record types.  Use this parameter to search for only a specific record type.  Can only be used with a string search.  Note this parameter is not validated, so value must be the correct syntax for the infoblox to retrieve it.
.EXAMPLE
	Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -IPAddress '192.168.101.1'

	This example retrieves all records with IP Address of 192.168.101.1
.EXAMPLE
	Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -SearchString 'Test' -Strict

	This example retrieves all records with the exact name 'Test'
.EXAMPLE
	Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -SearchString 'Test' -RecordType 'record:a'

	This example retrieves all dns a records that have 'test' in the name.
.EXAMPLE
	Find-IBRecord -Gridmaster $Gridmaster -Credential $Credential -RecordType 'fixedaddress'

	This example retrieves all fixedaddress records in the infoblox database
.INPUTS
	System.Net.IPAddress[]
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_FixedAddress
	IB_DNSARecord
	IB_DNSCNameRecord
	IB_DNSPTRRecord
	IB_ReferenceObject
#>
Function Find-IBRecord {
    [CmdletBinding(DefaultParameterSetName = 'globalSearchbyIP')]
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [ValidateNotNullorEmpty()]
        [String]$Gridmaster,

        [Parameter(Mandatory=$True)]
        [System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName='globalSearchbyString')]
        [String]$SearchString,

		[Parameter(ParameterSetName='globalSearchbyString')]
		[String]$RecordType,

        [Parameter(ParameterSetName='globalSearchbyString')]
        [Switch]$Strict,

        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName='globalSearchbyIP')]
        [IPAddress]$IPAddress,

		[String]$Type,

        [Int]$MaxResults

    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
        write-verbose "$FunctionName`:  Beginning Function"
        Write-Verbose "$FunctionName`:  Connecting to Infoblox device $gridmaster to retrieve Views"
        Try {
            $IBViews = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView
        } Catch {
            Write-error "Unable to connect to Infoblox device $gridmaster.  Error code:  $($_.exception)" -ea Stop
        }
        if ($pscmdlet.ParameterSetName -eq 'globalSearchbyString'){
			If ($Strict){
				$uribase = "https://$gridmaster/wapi/$Global:WapiVersion/search?search_string:="

			} else {
				$uribase = "https://$gridmaster/wapi/$Global:WapiVersion/search?search_string~:="

			}
		} elseif ($pscmdlet.ParameterSetName -eq 'globalSearchbyIP'){
			$uribase = "https://$gridmaster/wapi/$Global:WapiVersion/search?address="
		}
		
	}


    PROCESS{
		If ($SearchString){
			$URI = "$uribase$SearchString"
			If ($RecordType){$URI += "&objtype=$recordtype"}
		} elseif ($IPAddress){
			$URI = "$uribase$($ipaddress.IPAddresstoString)"
		}
		If ($MaxResults){
			$Uri += "&_max_results=$MaxResults"
		}
		If ($Type){
			$Uri += "&objtype=$Type"
		}
		Write-verbose "$FunctionName`:  URI String`:  $uri"

		$output = Invoke-RestMethod -Uri $URI -Credential $Credential
		write-verbose "$FunctionName`:  Found the following objects:"
		foreach ($item in $output){
			write-verbose "`t`t$($item._ref)"
		}
		Foreach ($item in $output){
			Get-IBRecord -Gridmaster $Gridmaster -Credential $Credential -_ref $item._ref
		}

    }
    END{}
}
