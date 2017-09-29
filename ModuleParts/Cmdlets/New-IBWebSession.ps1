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
        [String]$WapiVersion='v2.2'
    )
    $URI = "https://$gridmaster/wapi/$Wapiversion/grid"
    write-verbose "URIString:  $URI"
    Invoke-RestMethod -uri $URI -Credential $Credential -SessionVariable Script:IBSession | out-null
    $script:IBGridmaster = $Gridmaster
    $script:IBWapiVersion = $WapiVersion
    new-object psobject -property @{
        'IBSession' = $script:IBSession
        'IBGridmaster' = $script:IBGridmaster
        'IBWapiVersion' = $script:IBWapiVersion
    }
}
