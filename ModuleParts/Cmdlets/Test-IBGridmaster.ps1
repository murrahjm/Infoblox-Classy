<#
.Synopsis
    Tests for connection to accessible Infoblox Gridmaster.
.DESCRIPTION
    Tests for connection to accessible Infoblox Gridmaster.  Connects to provided gridmaster FQDN over SSL and verifies gridmaster functionality.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.Parameter Quiet
    Switch parameter to specify whether error output should be provided with more detail about the connection errors.
.EXAMPLE
    Test-IBGridmaster -Gridmaster testGM.domain.com

	This example tests the connection to testGM.domain.com and returns a True or False value based on availability.
.INPUTS
	System.String
.OUTPUTS
    Bool
#>
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
