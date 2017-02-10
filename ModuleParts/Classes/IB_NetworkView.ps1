Class IB_networkview : IB_ReferenceObject {
    ##Properties
    [String]$name
    [bool]$is_default
    [String]$Comment
	[Object]$ExtAttrib
    ##methods
    [String] ToString () {
        return $this.name
    }
	static [IB_NetworkView] Create(
		[String]$Name,
		[String]$Comment
	){
		$URIString = "https://$Script:IBGridmaster/wapi/$Global:WapiVersion/networkview"
		$bodyhashtable = @{name=$Name}
		If ($Comment){$bodyhashtable += @{comment=$Comment}}
		$Return = Invoke-RestMethod -uri $URIString -Method Post -body $bodyhashtable -WebSession $Script:IBSession
		return [IB_NetworkView]::Get($return)
	}
	static [IB_networkview] Get (
		[String]$_ref
	) {
		$ReturnFields = "extattrs,name,is_default,comment"
		$URIString = "https://$Script:IBGridmaster/wapi/$Global:WapiVersion/$_ref`?_return_fields=$ReturnFields"
		$return = Invoke-RestMethod -Uri $URIString -WebSession $Script:IBSession
		If ($Return) {
			return [IB_networkview]::New($Return.name,
										 $Return.is_default, 
										 $Return.comment, 
										 $Return._ref, 
										 $($return.extattrs | ConvertTo-ExtAttrsArray))
		} else {
			return $Null
		}
				
	}
    static [IB_networkview[]] Get(
        [String]$Name,
		[String]$Is_Default,
		[String]$Comment,
		[String]$ExtAttribFilter,
        [Bool]$Strict,
        [Int]$MaxResults
    ){
		$ReturnFields = "extattrs,name,is_default,comment"
		$URI = "https://$Script:IBGridmaster/wapi/$Global:WapiVersion/networkview?"
		If ($Strict){$Operator = ":="} else {$Operator = "~:="}
		If ($Name){
			$URI += "name$Operator$Name&"
		}
		If ($Is_Default){
			$URI += "is_default=$Is_Default&"
		}
		If ($comment){
			$URI += "comment$operator$comment&"
		}
 		If ($ExtAttribFilter){
			$URI += SearchStringToIBQuery -searchstring $ExtAttribFilter
		}
       If ($MaxResults){
			$URI += "_max_results=$MaxResults&"
		}
		$URI += "_return_fields=$ReturnFields"
		write-verbose "URI String:  $URI"
        $return = Invoke-RestMethod -URI $URI -WebSession $Script:IBSession
        $output = @()
        Foreach ($item in $return){
                $output += [IB_networkview]::New($item.name,
												 $Item.is_default,
												 $item.comment,
												 $item._ref,
												 $($item.extattrs | ConvertTo-ExtAttrsArray))
        }
        return $output
    }
#region Set Method
    hidden [void]Set (
		[String]$Name,
        [String]$Comment
    ){
        $URIString = "https://$Script:IBGridmaster/wapi/$Global:WapiVersion/$($this._ref)"
        $bodyhashtable = $Null
		$bodyhashtable += @{name=$Name}
		$bodyhashtable += @{comment=$Comment}
        If ($bodyhashtable){
            $return = Invoke-RestMethod -uri $URIString -method Put -body $($bodyhashtable | convertto-json) -contenttype application/json -WebSession $Script:IBSession
            If ($return) {
                $this._ref = $return
				$this.name = $Name
                $this.comment = $Comment
            }
        }
    }
    ##constructors
    #These have to exist in order for the List method to create the object instance
    IB_networkview(
        [String]$name,
        [bool]$is_default,
        [string]$comment,
        [string]$_ref,
 		[Object]$ExtAttrib
   ){
        $this.name       = $name
        $this.is_default = $is_default
        $this.Comment    = $comment
        $this._ref       = $_ref
		$this.extattrib  = $ExtAttrib
    }
}
