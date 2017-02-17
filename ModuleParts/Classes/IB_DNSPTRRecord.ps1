Class IB_DNSPTRRecord : IB_ReferenceObject {
    ##Properties
    [IPAddress]$IPAddress
    [String]$PTRDName
    [String]$Name
    [String]$Comment
    [String]$view
    [uint32]$TTL
    [bool]$Use_TTL
	[Object]$ExtAttrib

#region Methods
    #region Create method
    static [IB_DNSPTRRecord] Create(
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
        [String]$PTRDName,
        [IPAddress]$IPAddress,
        [String]$Comment,
        [String]$view,
        [uint32]$TTL,
        [bool]$Use_TTL

    ){
        $URIString = "https://$Gridmaster/wapi/$WapiVersion/record:ptr"
        $BodyHashTable = @{ipv4addr=$($IPAddress.IPAddressToString)}
        $bodyhashtable += @{ptrdname=$PTRDName}
        $bodyhashtable += @{comment=$comment}
        If ($View){$bodyhashtable += @{view = $view}}
        If ($use_TTL){
            $BodyHashTable+= @{ttl=$ttl}
            $bodyhashtable+= @{use_ttl=$use_ttl}
        }
        $return = Invoke-RestMethod -Uri $URIString -Method Post -Body $BodyHashTable -WebSession $Session
        If ($Return) {
			return [IB_DNSPTRRecord]::Get($gridmaster,$Session,$WapiVersion,$return)
		} else {
			return $Null
		}
    }
    #endregion
    #region Get methods
	static [IB_DNSPTRRecord] Get (
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
		[String]$_ref
	) {
		$ReturnFields = "extattrs,name,ptrdname,ipv4addr,comment,view,ttl,use_ttl"
		$URIString = "https://$Gridmaster/wapi/$WapiVersion/$_ref`?_return_fields=$ReturnFields"
		$return = Invoke-RestMethod -Uri $URIString -WebSession $Session
        If ($Return) {
			If ($return.ipv4addr.length -eq 0){$return.ipv4addr = $Null}
			return [IB_DNSPTRRecord]::New($return.ptrdname,
										  $return.ipv4addr,
										  $return.Name,
										  $return.comment,
										  $return._ref,
										  $return.view,
										  $return.ttl,
										  $return.use_ttl,
										  $($return.extattrs | ConvertTo-ExtAttrsArray))
		} else {
			return $Null
		}
	}

    static [IB_DNSPTRRecord[]] Get(
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
        [String]$Name,
		[IPAddress]$IPAddress,
		[String]$PTRdname,
		[String]$Comment,
		[String]$ExtAttribFilter,
		[String]$Zone,
        [String]$View,
        [Bool]$Strict,
        [Int]$MaxResults
    ){
		$ReturnFields = "extattrs,name,ptrdname,ipv4addr,comment,view,ttl,use_ttl"
		$URI = "https://$Gridmaster/wapi/$WapiVersion/record:ptr?"
		If ($Strict){$Operator = ":="} else {$Operator = "~:="}
		If ($Name){
			$URI += "name$Operator$Name&"
		}
		If ($IPAddress){
			$URI += "ipv4addr=$($ipaddress.IPAddressToString)&"
		}
		If ($PTRdname){
			$URI += "ptrdname$operator$PTRdname&"
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
        $output = @()
        Foreach ($item in $return){
				If ($item.ipv4addr.length -eq 0){$item.ipv4addr = $Null}
                $output += [IB_DNSPTRRecord]::New($item.ptrdname,
												  $item.ipv4addr,
												  $item.name,
												  $item.comment,
												  $item._ref,
												  $item.view,
												  $item.ttl,
												  $item.use_ttl,
												  $($item.extattrs | ConvertTo-ExtAttrsArray))
        }
        return $output
    }
    #endregion
    #region Set method
    hidden [Void] Set(
 		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
        [String]$PTRDName,
        [String]$Comment,
        [uint32]$ttl,
        [bool]$use_ttl
    ){
        $URIString = "https://$Gridmaster/wapi/$WapiVersion/$($this._ref)"
        $bodyHashTable = $null
        $bodyHashTable+=@{ptrdname=$PTRDName}
        $bodyHashTable+=@{comment=$comment}
        $bodyHashTable+=@{use_ttl=$use_ttl}
        If ($use_ttl){
            $bodyHashTable+=@{ttl=$ttl}
        } else {
			$bodyHashTable += @{ttl=0}
		}

        If ($bodyHashTable){
			$return = Invoke-RestMethod -Uri $URIString -Method Put -Body $($bodyHashTable | ConvertTo-Json) -ContentType application/json -WebSession $Session
			if ($return) {
				$this._ref = $return
				$this.ptrdname = $PTRDName
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
		$URIString = "https://$Gridmaster/wapi/$WapiVersion/$($this._ref)"
		New-Variable -name $Name -Value $(New-object psobject -Property @{value=$Value})
		$ExtAttr = new-object psobject -Property @{$Name=$(get-variable $Name | Select-Object -ExpandProperty Value)}
		$body = new-object psobject -Property @{"extattrs+"=$extattr}
		$JSONBody = $body | ConvertTo-Json
		If ($JSONBody){
			$Return = Invoke-RestMethod -Uri $URIString -Method Put -Body $JSONBody -ContentType application/json -WebSession $Session
			If ($Return){
				$record = [IB_DNSPTRRecord]::Get($gridmaster,$Session,$WapiVersion,$return)
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
				$record = [IB_DNSPTRRecord]::Get($gridmaster,$Session,$WapiVersion,$return)
				$this.ExtAttrib = $record.extAttrib
			}
		}
	}
	#endregion
#endregion
#region Constructors
    IB_DNSPTRRecord(
        [String]$PTRDName,
        [IPAddress]$IPAddress,
        [String]$Name,
        [String]$Comment,
        [String]$_ref,
        [String]$view,
        [uint32]$TTL,
        [bool]$Use_ttl,
		[Object]$ExtAttrib
    ){
        $this.PTRDName    = $PTRDName
        $this.ipaddress   = $IPAddress
        $this.Name        = $Name
        $this.Comment     = $Comment
        $this._ref        = $_ref
        $this.view        = $view
        $this.ttl         = $TTL
        $this.Use_TTL     = $Use_ttl
		$this.extattrib   = $ExtAttrib
    }
#endregion
}
