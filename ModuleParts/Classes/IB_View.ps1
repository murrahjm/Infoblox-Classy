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
		[Object]$Session,
		[String]$WapiVersion,
		[String]$Name,
		[String]$Comment
	){
		$URIString = "https://$Gridmaster/wapi/$WapiVersion/view"
		$bodyhashtable = @{name=$Name}
		If ($Comment){$bodyhashtable += @{comment=$Comment}}
		$Return = Invoke-RestMethod -uri $URIString -Method Post -body $bodyhashtable -WebSession $Session
		return [IB_View]::Get($gridmaster,$Session,$WapiVersion,$return)
	}
	static [IB_View] Get (
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
		[String]$_ref
	) {
		$ReturnFields = "extattrs,name,is_default,comment"
		$URIString = "https://$Gridmaster/wapi/$WapiVersion/$_ref`?_return_fields=$ReturnFields"
		$return = Invoke-RestMethod -Uri $URIString -WebSession $Session
		If ($Return) {
			return [IB_View]::New($Return.name, 
								  $Return.is_default, 
								  $Return.comment, 
								  $Return._ref, 
								  $($return.extattrs | ConvertTo-ExtAttrsArray))
		} else {
			return $Null
		}
				
	}


    static [IB_View[]] Get(
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
        [String]$Name,
		[String]$Is_Default,
		[String]$Comment,
		[String]$ExtAttribFilter,
        [Bool]$Strict,
        [Int]$MaxResults
    ){
		$ReturnFields = "extattrs,name,is_default,comment"
		$URI = "https://$Gridmaster/wapi/$WapiVersion/view?"
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
        $return = Invoke-RestMethod -URI $URI -WebSession $Session
        [array]$output = Foreach ($item in $return){
                [IB_View]::New($item.name,
										  $Item.is_default,
										  $item.comment,
										  $item._ref,
										  $($item.extattrs | ConvertTo-ExtAttrsArray))
        }
        return $output
    }
#region Set Method
    hidden [void]Set (
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
		[String]$Name,
        [String]$Comment
    ){
        $URIString = "https://$Gridmaster/wapi/$WapiVersion/$($this._ref)"
        $bodyhashtable = $null
		$bodyhashtable += @{name=$Name}
		$bodyhashtable += @{comment=$Comment}
        If ($bodyhashtable){
            $return = Invoke-RestMethod -uri $URIString -method Put -body $($bodyhashtable | convertto-json) -contenttype application/json -WebSession $Session
            If ($return) {
                $this._ref = $return
				$this.name = $Name
                $this.comment = $Comment
            }
        }
    }
#constructors
    #These have to exist in order for the List method to create the object instance
    IB_View(
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
