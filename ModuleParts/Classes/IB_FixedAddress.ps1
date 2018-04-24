Class IB_FixedAddress : IB_ReferenceObject {
    ##Properties
    [String]$Name
    [IPAddress]$IPAddress
    [String]$Comment
    [String]$NetworkView
	[String]$MAC
	[Object]$ExtAttrib
#region Methods
#region Create method
    static [IB_FixedAddress] Create(
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
        [String]$Name,
        [IPAddress]$IPAddress,
        [String]$Comment,
        [String]$NetworkView,
		[String]$MAC
    ){
        $URIString = "https://$Gridmaster/wapi/$WapiVersion/fixedaddress"
        $bodyhashtable = @{ipv4addr=$IPAddress}
        $BodyHashTable += @{name=$Name}
        $bodyhashtable += @{comment=$comment}
        If ($networkview){$bodyhashtable += @{network_view = $NetworkView}}
		$BodyHashTable += @{mac = $MAC}
		If (($MAC -eq '00:00:00:00:00:00') -or ($MAC.Length -eq 0)){
			$bodyHashTable += @{match_client='RESERVED'}
		} else {
			$bodyHashTable += @{match_client='MAC_ADDRESS'}
		}

        $return = Invoke-RestMethod -Uri $URIString -Method Post -Body $BodyHashTable -WebSession $Session
        return [IB_FixedAddress]::Get($gridmaster,$Session,$WapiVersion,$return)
        
    }
    #endregion
    #region Get methods
	static [IB_FixedAddress] Get (
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
		[String]$_ref
	) {
		$ReturnFields = "extattrs,name,ipv4addr,comment,network_view,mac"
		$URIString = "https://$Gridmaster/wapi/$WapiVersion/$_ref`?_return_fields=$ReturnFields"
		$return = Invoke-RestMethod -Uri $URIString -WebSession $Session
        If ($Return) {
			return [IB_FixedAddress]::New($return.name,
										  $return.ipv4addr,
										  $return.comment,
										  $return._ref,
										  $return.network_view,
										  $return.mac,
										  $($return.extattrs | Convertto-ExtAttrsArray))
		} else {
			return $Null
		}
	}
	static [IB_FixedAddress[]] Get(
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
		[IPAddress]$IPAddress,
		[String]$MAC,
		[String]$Comment,
		[String]$ExtAttribFilter,
		[String]$NetworkView,
		[Bool]$Strict,
		[Int]$MaxResults
	){
		$ReturnFields = "extattrs,name,ipv4addr,comment,network_view,mac"
		$URI = "https://$Gridmaster/wapi/$WapiVersion/fixedaddress?"
		If ($Strict){$Operator = ":="} else {$Operator = "~:="}
		If ($IPAddress){
			$URI += "ipv4addr=$($IPAddress.IPAddressToString)&"
		}
		If ($MAC){
			$URI += "mac=$mac&"
		}
		If ($Comment){
			$URI += "comment$operator$comment&"
		}
		If ($ExtAttribFilter){
			$URI += SearchStringToIBQuery -searchstring $ExtAttribFilter
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
        [array]$output = Foreach ($item in $return){
            [IB_FixedAddress]::New($item.name,
											  $item.ipv4addr,
											  $item.comment,
											  $item._ref,
											  $item.network_view,
											  $item.mac,
											  $($item.extattrs | convertto-extAttrsArray))
        }
        return $output
	}
    #endregion
    #region Set method
    hidden [Void] Set(
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
        [String]$Name,
        [String]$Comment,
		[String]$MAC
    ){
        $URIString = "https://$Gridmaster/wapi/$WapiVersion/$($this._ref)"
        $bodyHashTable = $null
        $bodyHashTable+=@{name=$Name}
        $bodyHashTable+=@{comment=$comment}
		$bodyHashTable+=@{mac=$MAC}
		If ($MAC -eq "00:00:00:00:00:00"){
			$bodyHashTable+=@{match_client='RESERVED'}
		} else {
			$bodyHashTable+=@{match_client='MAC_ADDRESS'}
		}
        If ($bodyHashTable){
			$return = Invoke-RestMethod -Uri $URIString -Method Put -Body $($bodyHashTable | ConvertTo-Json) -ContentType application/json -WebSession $Session
			if ($return) {
				$this._ref = $return
				$this.name = $Name
				$this.comment = $Comment
				$this.MAC = $MAC
			}
		}
    }
    #endregion
	#region AddExtAttrib method
	hidden [void] AddExtAttrib (
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
		[String]$Name,
		[String]$Value
	){
		$URIString = "https://$Gridmaster/wapi/$WapiVersion/$($this._ref)"
		New-Variable -name $Name -Value $(New-object psobject -Property @{value=$Value})
		$ExtAttr = new-object psobject -Property @{$Name=$(get-variable $Name | Select-Object -ExpandProperty Value)}
		$body = new-object psobject -Property @{"extattrs+"=$extattr}
		$JSONBody = $body | ConvertTo-Json
		If ($JSONBody){
			$Return = Invoke-RestMethod -Uri $URIString -Method Put -Body $JSONBody -ContentType application/json -WebSession $Session
			If ($Return){
				$record = [IB_FixedAddress]::Get($gridmaster,$Session,$WapiVersion,$return)
				$this.ExtAttrib = $record.extAttrib
			}
		}
	}
	#endregion
	#region RemoveExtAttrib method
	hidden [void] RemoveExtAttrib (
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
		[String]$ExtAttrib
	){
		$URIString = "https://$Gridmaster/wapi/$WapiVersion/$($this._ref)"
		New-Variable -name $ExtAttrib -Value $(New-object psobject -Property @{})
		$ExtAttr = new-object psobject -Property @{$extattrib=$(get-variable $ExtAttrib | Select-Object -ExpandProperty Value)}
		$body = new-object psobject -Property @{"extattrs-"=$extattr}
		$JSONBody = $body | ConvertTo-Json
		If ($JSONBody){
			$Return = Invoke-RestMethod -Uri $URIString -Method Put -Body $JSONBody -ContentType application/json -WebSession $Session
			If ($Return){
				$record = [IB_FixedAddress]::Get($gridmaster,$Session,$WapiVersion,$return)
				$this.ExtAttrib = $record.extAttrib
			}
		}
	}
	#endregion
#endregion
#region Constructors
    IB_FixedAddress(
        [String]$Name,
        [IPAddress]$IPAddress,
		[String]$Comment,
        [String]$_ref,
        [String]$NetworkView,
		[String]$MAC,
		[Object]$ExtAttrib
    ){
        $this.Name         = $Name
		$this.IPAddress    = $IPAddress
        $this.Comment      = $Comment
        $this._ref         = $_ref
        $this.networkview  = $NetworkView
		$this.MAC          = $MAC
		$this.ExtAttrib    = $ExtAttrib
    }
#endregion
}
