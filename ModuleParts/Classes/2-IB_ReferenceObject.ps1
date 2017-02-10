Class IB_ReferenceObject {
    #properties
    [String]$_ref
    #methods
	
    [String] ToString(){
        return $this._ref
    }
	static [IB_ReferenceObject] Get(
		[string]$_ref
	) {
		$URIString = "https://$script:IBgridmaster/wapi/$Global:WapiVersion/$_ref"
		$return = Invoke-RestMethod -Uri $URIString -WebSession $script:IBSession
        If ($Return) {
			return [IB_ReferenceObject]::New($return._ref)
		} else {
			return $null
		}
	}
   hidden [String] Delete(){
        $URIString = "https://$script:IBGridmaster/wapi/$Global:WapiVersion/$($this._ref)"
        $return = Invoke-RestMethod -Uri $URIString -Method Delete -WebSession $script:IBSession
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
