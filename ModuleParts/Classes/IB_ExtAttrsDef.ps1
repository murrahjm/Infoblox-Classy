
Class IB_ExtAttrsDef : IB_ReferenceObject {
    ##Properties
    [String]$Name
    [String]$Type
    [String]$Comment
    [String]$DefaultValue
#region Methods
    [String] ToString () {
        return $this.name
    }

    #region Create method
    static [IB_ExtAttrsDef] Create(
        [String]$GridMaster,
        [PSCredential]$Credential,
        [String]$Name,
		[String]$Type,
		[String]$Comment,
		[String]$DefaultValue
    ){
        $URIString = "https://$GridMaster/wapi/$script:WapiVersion/extensibleattributedef"
        $BodyHashTable = @{name=$Name}
        $bodyhashtable += @{type=$Type.ToUpper()}
        $bodyhashtable += @{comment=$comment}
		if ($defaultvalue){$bodyhashtable += @{default_value=$DefaultValue}}
        $return = Invoke-RestMethod -Uri $URIString -Method Post -Body $BodyHashTable -Credential $Credential
		If ($return) {
			return [IB_ExtAttrsDef]::Get($GridMaster,$Credential,$return)
		}else {
			return $Null
		}
        
    }
    #endregion
    #region Get methods
		static [IB_ExtAttrsDef] Get (
		[String]$Gridmaster,
		[PSCredential]$Credential,
		[String]$_ref
	) {
		$ReturnFields = "name,comment,default_value,type"
		$URIString = "https://$gridmaster/wapi/$script:WapiVersion/$_ref`?_return_fields=$ReturnFields"
		$return = Invoke-RestMethod -Uri $URIString -Credential $Credential
        If ($Return) {
			return [IB_ExtAttrsDef]::New($gridmaster,$credential,$return.name,$return.type,$return.comment,$return.default_value,$return._ref)
		} else {
			return $null
		}
	}

    static [IB_ExtAttrsDef[]] Get(
        [String]$GridMaster,
        [PSCredential]$Credential,
        [String]$Name,
		[String]$Type,
		[String]$Comment,
        [Bool]$Strict,
        [Int]$MaxResults
    ){
		$ReturnFields = "name,comment,default_value,type"
		$URI = "https://$Gridmaster/wapi/$Script:WapiVersion/extensibleattributedef?"
		If ($Strict){$Operator = ":="} else {$Operator = "~:="}
		If ($Name){
			$URI += "name$Operator$Name&"
		}
		If ($Type){
			$URI += "type=$($Type.ToUpper())&"
		}
		If ($comment){
			$URI += "comment$operator$comment&"
		}
        If ($MaxResults){
			$URI += "_max_results=$MaxResults&"
		}
		$URI += "_return_fields=$ReturnFields"
		write-verbose "URI String:  $URI"
        $return = Invoke-RestMethod -URI $URI -Credential $Credential
        $output = @()
		Foreach ($item in $return){
			$output += [IB_ExtAttrsDef]::New($gridmaster,$credential,$Item.name,$Item.type,$Item.comment,$Item.default_value,$Item._ref)
		}
        return $output
    }
    #endregion
    #region Set method
    hidden [void]Set(
        [String]$Name,
		[String]$Type,
		[String]$Comment,
		[String]$DefaultValue
    )
	{
        $URIString = "https://$($this.GridMaster)/wapi/$script:WapiVersion/$($this._ref)"
        $bodyHashTable = $null
        $bodyHashTable+=@{name=$Name}
        $bodyHashTable+=@{type=$Type.ToUpper()}
        $bodyHashTable+=@{comment=$comment}
		$bodyHashTable+=@{default_value=$DefaultValue}
        If ($bodyHashTable){
			$Return = Invoke-RestMethod -Uri $URIString -Method Put -Body $($bodyHashTable | ConvertTo-Json) -ContentType application/json -Credential $this.Credential
			if ($return) {
				$this._ref = $return
				$this.type = $Type
				$this.comment = $Comment
				$this.defaultvalue = $DefaultValue
			}
		}
    }
    #endregion
#endregion
#region Constructors
    IB_ExtAttrsDef(
        [String]$GridMaster,
        [PSCredential]$Credential,
        [String]$Name,
		[String]$Type,
		[String]$Comment,
		[String]$DefaultValue,
		[String]$_ref
    ){
        $this.Name         = $Name
        $this.Comment      = $Comment
        $this._ref         = $_ref
        $this.gridmaster   = $Gridmaster
        $this.credential   = $Credential
		$this.type         = $Type
		$this.DefaultValue = $DefaultValue
    }
#endregion
}
