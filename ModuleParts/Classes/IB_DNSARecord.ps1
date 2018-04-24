Class IB_DNSARecord : IB_ReferenceObject {
    ##Properties
    [String]$Name
    [IPAddress]$IPAddress
    [String]$Comment
    [String]$View
    [uint32]$TTL
    [bool]$Use_TTL
	[Object]$ExtAttrib

#region Methods
    #region Create method
    static [IB_DNSARecord] Create(
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
        [String]$Name,
        [IPAddress]$IPAddress,
        [String]$Comment,
        [String]$view,
        [uint32]$TTL,
        [bool]$Use_TTL
    ){
        $URIString = "https://$Gridmaster/wapi/$Wapiversion/record:a"
        $BodyHashTable = @{name=$Name}
        $bodyhashtable += @{ipv4addr=$IPAddress}
        $bodyhashtable += @{comment=$comment}
        If ($view){$bodyhashtable += @{view = $view}}

        If ($Use_TTL){
            $BodyHashTable+= @{ttl = $TTL}
            $BodyHashTable+= @{use_ttl = $use_ttl}
        }

        $return = Invoke-RestMethod -Uri $URIString -Method Post -Body $BodyHashTable -WebSession $Session
		If ($return) {
			return [IB_DNSARecord]::Get($gridmaster,$Session,$WapiVersion,$return)
		}else {
			return $Null
		}
        
    }
    #endregion
    #region Get methods
		static [IB_DNSARecord] Get (
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
		[String]$_ref
	) {
		$ReturnFields = "extattrs,name,ipv4addr,comment,view,ttl,use_ttl"
		$URIString = "https://$Gridmaster/wapi/$Wapiversion/$_ref`?_return_fields=$ReturnFields"
		$return = Invoke-RestMethod -Uri $URIString -WebSession $Session
        If ($Return) {
			If ($return.ipv4addr.length -eq 0){$return.ipv4addr = $Null}
			return [IB_DNSARecord]::New($return.name,
										$return.ipv4addr,
										$return.comment,
										$return._ref,
										$return.view,
										$return.TTL,
										$return.use_TTL,
										$($Return.extattrs | ConvertTo-ExtAttrsArray))
		} else {
			return $null
		}
	}

    static [IB_DNSARecord[]] Get(
 		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
        [String]$Name,
		[IPAddress]$IPAddress,
		[String]$Comment,
		[String]$ExtAttribFilter,
		[String]$Zone,
        [String]$View,
        [Bool]$Strict,
        [Int]$MaxResults
    ){
		$ReturnFields = "extattrs,name,ipv4addr,comment,view,ttl,use_ttl"
		$URI = "https://$Gridmaster/wapi/$Wapiversion/record:a?"
		If ($Strict){$Operator = ":="} else {$Operator = "~:="}
		If ($Name){
			$URI += "name$Operator$Name&"
		}
		If ($IPAddress){
			$URI += "ipv4addr=$($ipaddress.IPAddressToString)&"
		}
		If ($comment){
			$URI += "comment$operator$comment&"
		}
		If ($ExtAttribFilter){
			$URI += SearchStringToIBQuery -searchstring $ExtAttribFilter
		}
		If ($Zone){
			$URI += "zone=$Zone&"
		}
		If ($View){
			$URI += "view=$view&"
		}
        If ($MaxResults){
			$URI += "_max_results=$MaxResults&"
		}
		$URI += "_return_fields=$ReturnFields"
		write-verbose "URI String:  $URI"
        $return = Invoke-RestMethod -URI $URI -WebSession $Session
		[array]$output = Foreach ($item in $return){
			If ($item.ipv4addr.length -eq 0){$item.ipv4addr = $Null}
			[IB_DNSARecord]::New($item.name,
											$item.ipv4addr,
											$item.comment,
											$item._ref,
											$item.view,
											$item.TTL,
											$item.use_TTL,
											$($item.extattrs | convertTo-ExtAttrsArray))
		}
        return $output
    }
    #endregion
    #region Set method
    hidden [void]Set(
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
        [IPAddress]$IPAddress,
        [String]$Comment,
        [uint32]$ttl,
        [bool]$use_ttl
    ){
        $URIString = "https://$Gridmaster/wapi/$Wapiversion/$($this._ref)"
        $bodyHashTable = $null
        $bodyHashTable+=@{ipv4addr=$($IPAddress.IPAddressToString)}
        $bodyHashTable+=@{comment=$comment}
        $bodyHashTable+=@{use_ttl=$use_ttl}
        If ($use_ttl){
            $bodyHashTable+=@{ttl=$ttl}
        } else {
			$bodyHashTable += @{ttl=0}
		}
        If ($bodyHashTable){
			$Return = Invoke-RestMethod -Uri $URIString -Method Put -Body $($bodyHashTable | ConvertTo-Json) -ContentType application/json -WebSession $Session
			if ($return) {
				$this._ref = $return
				$this.ipaddress = $IPAddress
				$this.comment = $Comment
				$this.use_ttl = $use_ttl
				If ($use_ttl){
					$this.ttl = $ttl
				} else {
					$this.ttl = $null
				}
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
		$URIString = "https://$Gridmaster/wapi/$Wapiversion/$($this._ref)"
		New-Variable -name $Name -Value $(New-object psobject -Property @{value=$Value})
		$ExtAttr = new-object psobject -Property @{$Name=$(get-variable $Name | Select-Object -ExpandProperty Value)}
		$body = new-object psobject -Property @{"extattrs+"=$extattr}
		$JSONBody = $body | ConvertTo-Json
		If ($JSONBody){
			$Return = Invoke-RestMethod -Uri $URIString -Method Put -Body $JSONBody -ContentType application/json -WebSession $Session
			If ($Return){
				$record = [IB_DNSARecord]::Get($gridmaster,$Session,$WapiVersion,$return)
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
		$URIString = "https://$Gridmaster/wapi/$Wapiversion/$($this._ref)"
		New-Variable -name $ExtAttrib -Value $(New-object psobject -Property @{})
		$ExtAttr = new-object psobject -Property @{$extattrib=$(get-variable $ExtAttrib | Select-Object -ExpandProperty Value)}
		$body = new-object psobject -Property @{"extattrs-"=$extattr}
		$JSONBody = $body | ConvertTo-Json
		If ($JSONBody){
			$Return = Invoke-RestMethod -Uri $URIString -Method Put -Body $JSONBody -ContentType application/json -WebSession $Session
			If ($Return){
				$record = [IB_DNSARecord]::Get($gridmaster,$Session,$WapiVersion,$return)
				$this.ExtAttrib = $record.extAttrib
			}
		}
	}
	#endregion
#endregion
#region Constructors
    IB_DNSARecord(
        [String]$Name,
        [IPAddress]$IPAddress,
        [String]$Comment,
        [String]$_ref,
        [String]$view,
        [uint32]$ttl,
        [bool]$use_ttl,
		[Object]$ExtAttrib
    ){
        $this.Name        = $Name
        $this.IPAddress   = $IPAddress
        $this.Comment     = $Comment
        $this._ref        = $_ref
        $this.view        = $view
        $this.TTL         = $ttl
        $this.use_ttl     = $use_ttl
		$this.extattrib   = $ExtAttrib
    }
#endregion
}
