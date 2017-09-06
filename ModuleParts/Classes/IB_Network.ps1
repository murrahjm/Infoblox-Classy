Class IB_Network : IB_ReferenceObject {
    ##Properties
    [String]$Network
    [String]$NetworkView
    [String]$NetworkContainer
    [String]$Comment
    [Object]$ExtAttrib
#region Create Method
    static [IB_Network] Create(
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
        [String]$Network,
        [String]$NetworkView,
        [String]$Comment
    ){
        $URIString = "https://$Gridmaster/wapi/$WapiVersion/network"
        $bodyhashtable = @{network=$Network}
        If ($comment){$bodyhashtable += @{comment=$Comment}}
        If ($NetworkView){$bodyhashtable += @{network_view = $NetworkView}}
        $return = Invoke-RestMethod -uri $URIString -Method Post -Body $bodyhashtable -WebSession $Session
        return [IB_Network]::Get($gridmaster,$Session,$WapiVersion,$return)
    }
#region Get Methods
    static [IB_Network] Get (
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
        [String]$_ref
    ){
        $ReturnFields = "extattrs,network,network_view,network_container,comment"
        $URIstring = "https://$Gridmaster/wapi/$WapiVersion/$_ref`?_return_fields=$ReturnFields"
        $Return = Invoke-RestMethod -Uri $URIstring -WebSession $Session
        If ($Return){
            return [IB_Network]::New($Return.Network,
                                         $return.Network_View,
                                         $return.Network_Container,
                                         $return.Comment,
                                         $($return.extattrs | convertto-ExtAttrsArray),
                                         $return._ref
            )
        } else {
            return $Null
        }
    }
    static [IB_Network[]] Get(
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
        [String]$Network,
        [String]$NetworkView,
        [String]$NetworkContainer,
        [String]$Comment,
        [String]$ExtAttribFilter,
        [bool]$Strict,
        [Int]$MaxResults
    ){
        $ReturnFields = "extattrs,network,network_view,network_container,comment"
        $URI = "https://$Gridmaster/wapi/$WapiVersion/network?"
        If ($Strict){$Operator = "="} else {$Operator = "~="}
        If ($Network){
            $URI += "network$Operator$Network&"
        }
        If ($NetworkView){
            $URI += "network_view=$Networkview&"
        }
        If ($NetworkContainer){
            $URI += "network_container=$NetworkContainer&"
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
        $return = Invoke-RestMethod -Uri $URI -WebSession $Session
        $output = @()
        Foreach ($Item in $Return){
            $output += [IB_Network]::New($item.Network,
                                         $item.Network_View,
                                         $item.Network_Container,
                                         $item.Comment,
                                         $($item.extattrs | convertto-ExtAttrsArray),
                                         $item._ref
            )
        }
        return $Output
    }
#region Set Method
    hidden [void]Set (
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
        [String]$Comment
    ){
        $URIString = "https://$Gridmaster/wapi/$WapiVersion/$($this._ref)"
        $bodyhashtable = @{comment=$Comment}
        If ($bodyhashtable){
            $return = Invoke-RestMethod -uri $URIString -method Put -body $($bodyhashtable | convertto-json) -contenttype application/json -WebSession $Session
            If ($return) {
                $this._ref = $return
                $this.comment = $Comment
            }
        }
    }
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
				$record = [IB_Network]::Get($gridmaster,$Session,$WapiVersion,$return)
				$this.ExtAttrib = $record.extAttrib
			}
		}
	}
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
				$record = [IB_Network]::Get($gridmaster,$Session,$WapiVersion,$return)
				$this.ExtAttrib = $record.extAttrib
			}
		}
	}
#region NextAvailableIP method
    hidden [String[]] GetNextAvailableIP (
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
        [String[]]$Exclude,
        [uint32]$Count
    ){
        $URIString = "https://$Gridmaster/wapi/$WapiVersion/$($this._ref)?_function=next_available_ip"
        $bodyhashtable = $null
        if ($count){$bodyhashtable += @{num = $count}}
        If ($Exclude){$bodyhashtable += @{exclude = $Exclude}}
        If ($bodyhashtable){
            return Invoke-RestMethod -uri $URIString -method Post -body $($bodyhashtable | convertto-json) -contenttype application/json -WebSession $Session
        } else {
            return $Null
        }
    }
#region Constructors
    IB_Network(
        [String]$Network,
        [String]$NetworkView,
        [String]$NetworkContainer,
        [String]$Comment,
        [object]$ExtAttrib,
        [String]$_ref
    ){
        $this.Network          = $Network
        $this.NetworkView      = $NetworkView
        $this.NetworkContainer = $NetworkContainer
        $this.Comment          = $Comment
        $this.ExtAttrib        = $ExtAttrib
        $this._ref             = $_ref
    }
}