Function Test-IBGridmaster {
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [String]$Gridmaster,
        
        [Switch]$Quiet
    )
    $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
    write-verbose "$FunctionName`:  Beginning Function"
		Try {
            write-verbose "$FunctionName`:  Attempting connection to https://$gridmaster/wapidoc/"
            $data = invoke-webrequest -uri "https://$gridmaster/wapidoc/" -UseBasicParsing
            If ($Data){
                If ($Data.rawcontent -like "*Infoblox WAPI Documentation*"){
                    return $True
                } else {
                    If (! $Quiet){write-error "invalid data returned from $Gridmaster.  Not a valid Infoblox device"}
                    return $False
                }
            } else {
                if (! $Quiet){write-error "No data returned from $gridmaster.  Not a valid Infoblox device"}
                return $False
            }
		} Catch {
			if (! $Quiet){Write-error "Unable to connect to Infoblox device $gridmaster.  Error code:  $($_.exception)" -ea Stop}
            return $False
		}
}
