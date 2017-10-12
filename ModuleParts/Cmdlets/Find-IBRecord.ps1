Function Find-IBRecord {
    [CmdletBinding(DefaultParameterSetName = 'globalSearchbyIP')]
    Param(
        [Parameter(Mandatory=$False)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [String]$Gridmaster,

        [Parameter(Mandatory=$False)]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName='globalSearchbyString')]
        [String]$SearchString,

		[Parameter(ParameterSetName='globalSearchbyString')]
		[String]$RecordType='*',

        [Parameter(ParameterSetName='globalSearchbyString')]
        [Switch]$Strict,

        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName='globalSearchbyIP')]
        [IPAddress]$IPAddress,

        [Int]$MaxResults

    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
        write-verbose "$FunctionName`:  Beginning Function"
		If (! $script:IBSession){
			write-verbose "Existing session to infoblox gridmaster does not exist."
			If ($gridmaster -and $Credential){
				write-verbose "Creating session to $gridmaster with user $($credential.username)"
				New-IBWebSession -gridmaster $Gridmaster -Credential $Credential -erroraction Stop  | out-null
			} else {
				write-error "Missing required parameters to connect to Gridmaster" -ea Stop
			}
		} else {
			write-verbose "Existing session to $script:IBGridmaster found"
		}
        Write-Verbose "$FunctionName`:  Connecting to Infoblox device $script:IBgridmaster to retrieve Views"
        Try {
		get-ibview -Type dnsview | out-null
        } Catch {
            Write-error "Unable to connect to Infoblox device $script:IBgridmaster.  Error code:  $($_.exception)" -ea Stop
        }
        if ($pscmdlet.ParameterSetName -eq 'globalSearchbyString'){
			If ($Strict){
				$uribase = "https://$script:IBgridmaster/wapi/$Script:IBWapiVersion/search?search_string:="

			} else {
				$uribase = "https://$script:IBgridmaster/wapi/$Script:IBWapiVersion/search?search_string~:="

			}
		} elseif ($pscmdlet.ParameterSetName -eq 'globalSearchbyIP'){
			$uribase = "https://$script:IBgridmaster/wapi/$Script:IBWapiVersion/search?address="
		}
		
	}


    PROCESS{
		If ($SearchString){
			$URI = "$uribase$SearchString"
		} elseif ($IPAddress){
			$URI = "$uribase$($ipaddress.IPAddresstoString)"
		}
		If ($MaxResults){
			$Uri += "&_max_results=$MaxResults"
		}
		Write-verbose "$FunctionName`:  URI String`:  $uri"

		$output = Invoke-RestMethod -Uri $URI -WebSession $script:IBSession
		write-verbose "$FunctionName`:  Found the following objects before filtering:"
		$output | ForEach-Object{write-verbose "`t`t$($_._ref)"}
		write-verbose "$FunctionName`:  Found the following objects after filtering:"
		If ($output){
			foreach ($item in $output.where{$_._ref -like "$recordtype/*"}){
				write-verbose "`t`t$($item._ref)"
				Get-IBRecord -_ref $item._ref
			}
		}

    }
    END{}
}
