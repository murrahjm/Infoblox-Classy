Class IB_ZoneAuth : IB_ReferenceObject {
    ##Properties
    [String]$FQDN
    [String]$View
    [String]$ZoneFormat
    [String]$Comment
    [Object]$ExtAttrib
#region Create Method
    static [IB_ZoneAuth] Create(
        [String]$FQDN,
        [String]$View,
        [String]$ZoneFormat,
        [String]$Comment
    ){
        $URIString = "https://$Script:IBGridmaster/wapi/$Global:WapiVersion/zone_auth"
        $bodyhashtable = @{fqdn=$fqdn}
        If ($comment){$bodyhashtable += @{comment=$Comment}}
        If ($View){$bodyhashtable += @{view = $View}}
        If ($ZoneFormat){$bodyhashtable += @{zone_format = $zoneformat.ToUpper()}}
        $return = Invoke-RestMethod -uri $URIString -Method Post -Body $bodyhashtable -WebSession $Script:IBSession
        return [IB_ZoneAuth]::Get($return)
    }
#region Get Methods
    static [IB_ZoneAuth] Get (
        [String]$_ref
    ){
        $ReturnFields = "extattrs,fqdn,view,zone_format,comment"
        $URIstring = "https://$Script:IBGridmaster/wapi/$Global:WapiVersion/$_ref`?_return_fields=$ReturnFields"
        $Return = Invoke-RestMethod -Uri $URIstring -WebSession $Script:IBSession
        If ($Return){
            return [IB_ZoneAuth]::New($Return.FQDN,
                                         $return.view,
                                         $return.zone_format,
                                         $return.Comment,
                                         $($return.extattrs | convertto-ExtAttrsArray),
                                         $return._ref
            )
        } else {
            return $Null
        }
    }
    static [IB_ZoneAuth[]] Get(
        [String]$FQDN,
        [String]$View,
        [String]$ZoneFormat,
        [String]$Comment,
        [String]$ExtAttribFilter,
        [bool]$Strict,
        [Int]$MaxResults
    ){
        $ReturnFields = "extattrs,fqdn,view,zone_format,comment"
        $URI = "https://$Script:IBGridmaster/wapi/$Global:WapiVersion/zone_auth?"
        If ($Strict){$Operator = "="} else {$Operator = "~="}
        If ($FQDN){
            $URI += "fqdn$Operator$fqdn&"
        }
        If ($View){
            $URI += "view=$view&"
        }
        If ($ZoneFormat){
            $URI += "zone_format=$($ZoneFormat.ToUpper())&"
        }
        If ($comment){
            $URI += "comment`:$operator$comment&"
        }
        If ($ExtAttribFilter){
            $URI += SearchStringtoIBQuery -searchstring $ExtAttribFilter
        }
        If ($MaxResults){
            $URI += "_max_results=$MaxResults&"
        }
        $URI += "_return_fields=$ReturnFields"
        write-verbose "URI String:  $URI"
        $return = Invoke-RestMethod -Uri $URI -WebSession $Script:IBSession
        $output = @()
        Foreach ($Item in $Return){
            $output += [IB_ZoneAuth]::New($item.fqdn,
                                         $item.View,
                                         $item.zone_format,
                                         $item.Comment,
                                         $($item.extattrs | convertto-ExtAttrsArray),
                                         $item._ref
            )
        }
        return $Output
    }
#region Set Method
    hidden [void]Set (
        [String]$Comment
    ){
        $URIString = "https://$Script:IBGridmaster/wapi/$Global:WapiVersion/$($this._ref)"
        $bodyhashtable = @{comment=$Comment}
        If ($bodyhashtable){
            $return = Invoke-RestMethod -uri $URIString -method Put -body $($bodyhashtable | convertto-json) -contenttype application/json -WebSession $Script:IBSession
            If ($return) {
                $this._ref = $return
                $this.comment = $Comment
            }
        }
    }
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
				$record = [IB_ZoneAuth]::Get($return)
				$this.ExtAttrib = $record.extAttrib
			}
		}
	}
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
				$record = [IB_ZoneAuth]::Get($return)
				$this.ExtAttrib = $record.extAttrib
			}
		}
	}
#region Constructors
    IB_ZoneAuth(
        [String]$fqdn,
        [String]$View,
        [String]$ZoneFormat,
        [String]$Comment,
        [object]$ExtAttrib,
        [String]$_ref
    ){
        $this.fqdn       = $fqdn
        $this.View       = $view
        $this.zoneformat = $zoneformat
        $this.Comment    = $Comment
        $this.ExtAttrib  = $ExtAttrib
        $this._ref       = $_ref
    }
}