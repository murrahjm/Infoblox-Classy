Class IB_DNSCNameRecord : IB_ReferenceObject {
    ##Properties
    [String]$Name
    [String]$canonical
    [String]$Comment
    [String]$view
    [uint32]$TTL
    [bool]$Use_TTL
	[Object]$ExtAttrib

#region Methods
    #region Create method
    static [IB_DNSCNameRecord] Create(
        [String]$Name,
        [String]$canonical,
        [String]$Comment,
        [String]$view,
        [uint32]$TTL,
        [bool]$Use_TTL

    ){
        
        $URIString = "https://$Script:IBGridMaster/wapi/$Global:WapiVersion/record:cname"
        $BodyHashTable = @{name=$Name}
        $bodyhashtable += @{canonical=$Canonical}
        $bodyhashtable += @{comment=$comment}
        If ($View){$bodyhashtable += @{view = $view}}
        If ($use_ttl){
            $BodyHashTable += @{ttl = $ttl}
            $BodyHashTable += @{use_ttl = $use_ttl}
        }
        $return = Invoke-RestMethod -Uri $URIString -Method Post -Body $BodyHashTable -WebSession $Script:IBSession
        If ($Return) {
			return [IB_DNSCNameRecord]::Get($return)
		} else {
			return $Null
		}
    }
    #endregion
    #region Get methods
	static [IB_DNSCNameRecord] Get (
		[String]$_ref
	) {
		$ReturnFields = "extattrs,name,canonical,comment,view,ttl,use_ttl"
		$URIString = "https://$Script:IBGridmaster/wapi/$Global:WapiVersion/$_ref`?_return_fields=$ReturnFields"
		$return = Invoke-RestMethod -Uri $URIString -WebSession $Script:IBSession
        If ($return) {
			return [IB_DNSCNameRecord]::New($return.Name,
											$return.canonical,
											$return.comment,
											$return._ref,
											$return.view,
											$return.ttl,
											$return.use_ttl,
											$($Return.extattrs | ConvertTo-ExtAttrsArray))
		} else {
			return $Null
		}
	}


    static [IB_DNSCNameRecord[]] Get(
        [String]$Name,
		[String]$Canonical,
		[String]$Comment,
		[String]$ExtAttribFilter,
		[String]$Zone,
        [String]$View,
        [Bool]$Strict,
        [Int]$MaxResults
    ){
		$ReturnFields = "extattrs,name,canonical,comment,view,ttl,use_ttl"
		$URI = "https://$Script:IBGridmaster/wapi/$Global:WapiVersion/record:cname?"
		If ($Strict){$Operator = ":="} else {$Operator = "~:="}
		If ($Name){
			$URI += "name$Operator$Name&"
		}
		If ($Canonical){
			$URI += "canonical$operator$Canonical&"
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
        $return = Invoke-RestMethod -URI $URI -WebSession $Script:IBSession
        $output = @()
        Foreach ($item in $return){
                $output += [IB_DNSCNameRecord]::New($item.Name,
													$item.canonical,
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
        [String]$canonical,
        [String]$Comment,
        [uint32]$TTL,
        [bool]$Use_TTL

    ){
        $URIString = "https://$Script:IBGridmaster/wapi/$Global:WapiVersion/$($this._ref)"
        $bodyHashTable = $null
        $bodyHashTable+=@{canonical=$canonical}
        $bodyHashTable+=@{comment=$comment}
        $bodyHashTable+=@{use_ttl=$use_ttl}
        If ($use_ttl){
            $bodyHashTable+=@{ttl=$ttl}
        } else {
			$bodyHashTable += @{ttl=0}
		}

        If ($bodyHashTable){
			$return = Invoke-RestMethod -Uri $URIString -Method Put -Body $($bodyHashTable | ConvertTo-Json) -ContentType application/json -WebSession $Script:IBSession
			if ($return) {
				$this._ref = $return
				$this.canonical = $canonical
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
		[String]$Name,
		[String]$Value
	){
		$URIString = "https://$Script:IBGridmaster/wapi/$Global:WapiVersion/$($this._ref)"
		New-Variable -name $Name -Value $(New-object psobject -Property @{value=$Value})
		$ExtAttr = new-object psobject -Property @{$Name=$(get-variable $Name | Select-Object -ExpandProperty Value)}
		$body = new-object psobject -Property @{"extattrs+"=$extattr}
		$JSONBody = $body | ConvertTo-Json
		If ($JSONBody){
			$Return = Invoke-RestMethod -Uri $URIString -Method Put -Body $JSONBody -ContentType application/json -WebSession $Script:IBSession
			If ($Return){
				$record = [IB_DNSCNameRecord]::Get($return)
				$this.ExtAttrib = $record.extAttrib
			}
		}
	}
	#endregion
	#region RemoveExtAttrib method
	hidden [void] RemoveExtAttrib (
		[String]$ExtAttrib
	){
		$URIString = "https://$Script:IBGridmaster/wapi/$Global:WapiVersion/$($this._ref)"
		New-Variable -name $ExtAttrib -Value $(New-object psobject -Property @{})
		$ExtAttr = new-object psobject -Property @{$extattrib=$(get-variable $ExtAttrib | Select-Object -ExpandProperty Value)}
		$body = new-object psobject -Property @{"extattrs-"=$extattr}
		$JSONBody = $body | ConvertTo-Json
		If ($JSONBody){
			$Return = Invoke-RestMethod -Uri $URIString -Method Put -Body $JSONBody -ContentType application/json -WebSession $Script:IBSession
			If ($Return){
				$record = [IB_DNSCNameRecord]::Get($return)
				$this.ExtAttrib = $record.extAttrib
			}
		}
	}
	#endregion
#endregion

#region Constructors
    IB_DNSCNameRecord(
        [String]$Name,
        [String]$canonical,
        [String]$Comment,
        [String]$_ref,
        [String]$view,
        [uint32]$TTL,
        [bool]$Use_TTL,
		[Object]$ExtAttrib
    ){
        $this.Name        = $Name
        $this.canonical   = $canonical
        $this.Comment     = $Comment
        $this._ref        = $_ref
        $this.view        = $view
        $this.TTL         = $TTL
        $this.Use_TTL     = $use_ttl
		$this.extattrib   = $ExtAttrib
    }

#endregion
}
