Class IB_View : IB_ReferenceObject {
    ##Properties
    [String]$name
    [bool]$is_default
    [String]$Comment
	[Object]$ExtAttrib
    ##methods
    [String] ToString () {
        return $this.name
    }
	static [IB_View] Create(
		[String]$Gridmaster,
		[PSCredential]$Credential,
		[String]$Name,
		[String]$Comment
	){
		$URIString = "https://$Gridmaster/wapi/$Script:WapiVersion/view"
		$bodyhashtable = @{name=$Name}
		If ($Comment){$bodyhashtable += @{comment=$Comment}}
		$Return = Invoke-RestMethod -uri $URIString -Method Post -body $bodyhashtable -Credential $Credential
		return [IB_View]::Get($gridmaster,$Credential,$return)
	}
	static [IB_View] Get (
		[String]$Gridmaster,
		[PSCredential]$Credential,
		[String]$_ref
	) {
		$ReturnFields = "extattrs,name,is_default,comment"
		$URIString = "https://$gridmaster/wapi/$script:WapiVersion/$_ref`?_return_fields=$ReturnFields"
		$return = Invoke-RestMethod -Uri $URIString -Credential $Credential
		If ($Return) {
			return [IB_View]::New($Return.name, 
								  $Return.is_default, 
								  $Return.comment, 
								  $Return._ref, 
								  $gridmaster, 
								  $credential,
								  $($return.extattrs | ConvertTo-ExtAttrsArray))
		} else {
			return $Null
		}
				
	}


    static [IB_View[]] Get(
        [String]$GridMaster,
        [PSCredential]$Credential,
        [String]$Name,
		[String]$Is_Default,
		[String]$Comment,
		[String]$ExtAttribFilter,
        [Bool]$Strict,
        [Int]$MaxResults
    ){
		$ReturnFields = "extattrs,name,is_default,comment"
		$URI = "https://$Gridmaster/wapi/$Script:WapiVersion/view?"
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
        $return = Invoke-RestMethod -URI $URI -Credential $Credential
        $output = @()
        Foreach ($item in $return){
                $output += [IB_View]::New($item.name,
										  $Item.is_default,
										  $item.comment,
										  $item._ref,
										  $Gridmaster,
										  $credential,
										  $($item.extattrs | ConvertTo-ExtAttrsArray))
        }
        return $output
    }
    ##constructors
    #These have to exist in order for the List method to create the object instance
    IB_View(
        [String]$name,
        [bool]$is_default,
        [string]$comment,
        [string]$_ref,
		[String]$Gridmaster,
        [PSCredential]$Credential,
		[Object]$ExtAttrib
    ){
        $this.name       = $name
        $this.is_default = $is_default
        $this.Comment    = $comment
        $this._ref       = $_ref
		$this.Gridmaster = $Gridmaster
		$this.Credential = $Credential
		$this.extattrib  = $ExtAttrib
    }
}
