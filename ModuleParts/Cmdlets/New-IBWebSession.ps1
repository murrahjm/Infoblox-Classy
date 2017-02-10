<#
.Synopsis
	Creates a re-usable web session with the supplied gridmaster and credential object.
.DESCRIPTION
	Creates a re-usable web session with the supplied gridmaster and credential object.  Once created, subsequent infoblox cmdlets will not require the gridmaster or credential parameters.  Any cmdlet called with gridmaster and credential parameters will create call this cmdlet to create a web session, or update an existing one.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER WapiVersion
	The version of web api to use when running commands against the infoblox appliance.  This can affect the availability of certain features.  Refer to Infoblox WAPI documentation for details.
.EXAMPLE
	New-IBWebSession -Gridmaster gridmaster.domain.com -Credential $IBCred -wapiversion v2.2

	Connects to the specified infoblox gridmaster and creates a re-usable web session for subsequent commands
.INPUTS
	PSCredential
	System.String
.OUTPUTS
#>
Function New-IBWebSession {
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [ValidateNotNullorEmpty()]
        [String]$Gridmaster,

        [Parameter(Mandatory=$True)]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$False)]
        [String]$WapiVersion
    )
    If (! $WapiVersion){$WapiVersion = $Global:WapiVersion}
    $URI = "https://$gridmaster/wapi/$Wapiversion/grid"
    $IBGrid = Invoke-RestMethod -uri $URI -Credential $Credential -SessionVariable Script:IBSession
    $script:IBGridmaster = $Gridmaster
}