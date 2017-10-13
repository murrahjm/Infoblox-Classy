Class IB_lease : IB_ReferenceObject {
    ##Properties
    [String]$Name
    [String]$IPAddress
    [String]$MAC
    [String]$NetworkView
	[String]$Network
#region Methods
    #region Get methods
	static [IB_lease] Get (
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
		[String]$_ref
	) {
		$ReturnFields = "client_hostname,address,network_view,hardware,network"
		$URIString = "https://$Gridmaster/wapi/$WapiVersion/$_ref`?_return_fields=$ReturnFields"
		$return = Invoke-RestMethod -Uri $URIString -WebSession $Session
        If ($Return) {
			return [IB_lease]::New($return.client_hostname,
										  $return.address,
										  $return._ref,
										  $return.network_view,
										  $return.hardware,
										  $return.network
            )
		} else {
			return $Null
		}
	}
	static [IB_lease[]] Get(
		[String]$Gridmaster,
		[Object]$Session,
        [String]$WapiVersion,
        [String]$Name,
		[String]$IPAddress,
		[String]$MAC,
		[String]$NetworkView,
		[Bool]$Strict,
		[Int]$MaxResults
	){
		$ReturnFields = "client_hostname,address,network_view,hardware,network,starts"
		$URI = "https://$Gridmaster/wapi/$WapiVersion/lease?"
		If ($Strict){$Operator = "="} else {$Operator = "~="}
		If ($IPAddress){
			$URI += "address$operator$IPAddress&"
		}
		If ($MAC){
			$URI += "hardware$operator$MAC&"
        }
        If ($Name){
            $URI += "client_hostname$operator$Name"
        }
		If ($NetworkView){
			$URI += "network_view=$NetworkView&"
		}
		If ($MaxResults){
			$URI += "_max_results=$MaxResults&"
		}
		$URI += "_return_fields=$ReturnFields"
		write-verbose "URI String:  $URI"
		$return = Invoke-RestMethod -URI $URI -WebSession $Session
		#filter return 
        $output = @()
        Foreach ($item in $return){
            $output += [IB_lease]::New($item.client_hostname,
                                        $item.address,
                                        $item._ref,
                                        $item.network_view,
                                        $item.hardware,
                                        $item.network
                                        )
        }
        return $output
	}
    #endregion
#endregion
#region Constructors
    IB_lease(
        [String]$Name,
        [String]$IPAddress,
        [String]$_ref,
        [String]$NetworkView,
        [String]$MAC,
        [String]$Network
    ){
        $this.Name         = $Name
		$this.IPAddress    = $IPAddress
        $this._ref         = $_ref
        $this.networkview  = $NetworkView
        $this.MAC          = $MAC
        $this.Network      = $Network
    }
#endregion
}
