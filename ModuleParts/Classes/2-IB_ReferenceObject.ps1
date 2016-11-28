Class IB_ReferenceObject {
    #properties
    hidden [String]$gridmaster
    hidden [System.Management.Automation.Credential()]$credential
    [String]$_ref
    #methods
	
    [String] ToString(){
        return $this._ref
    }
	static [IB_ReferenceObject] Get(
		[String]$Gridmaster,
		[PSCredential]$Credential,
		[string]$_ref
	) {
		$URIString = "https://$gridmaster/wapi/$Global:WapiVersion/$_ref"
		$return = Invoke-RestMethod -Uri $URIString -Credential $Credential
        If ($Return) {
			return [IB_ReferenceObject]::New($Gridmaster,$Credential,$return._ref)
		} else {
			return $null
		}
	}
   hidden [String] Delete(){
        $URIString = "https://$($this.GridMaster)/wapi/$Global:WapiVersion/$($this._ref)"
        $return = Invoke-RestMethod -Uri $URIString -Method Delete -Credential $this.Credential
        return $return
    }
    #constructors
    IB_ReferenceObject(){}
    IB_ReferenceObject(
		[String]$Gridmaster,
		[PSCredential]$Credential,
		[String]$_ref
	){
		$this.gridmaster = $Gridmaster
		$this.credential = $Credential
		$this._ref = $_ref
	}
}
