Class IB_ReferenceObject {
    #properties
    [String]$_ref
    #methods
	
    [String] ToString(){
        return $this._ref
    }
	static [IB_ReferenceObject] Get(
		[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion,
		[string]$_ref
	) {
		$URIString = "https://$Gridmaster/wapi/$WapiVersion/$_ref"
		$return = Invoke-RestMethod -Uri $URIString -WebSession $Session
        If ($Return) {
			return [IB_ReferenceObject]::New($return._ref)
		} else {
			return $null
		}
	}
   hidden [String] Delete(
       	[String]$Gridmaster,
		[Object]$Session,
		[String]$WapiVersion
   ){
        $URIString = "https://$Gridmaster/wapi/$WapiVersion/$($this._ref)"
        $return = Invoke-RestMethod -Uri $URIString -Method Delete -WebSession $Session
        return $return
    }
    #constructors
    IB_ReferenceObject(){}
    IB_ReferenceObject(
		[String]$_ref
	){
		$this._ref = $_ref
	}
}
