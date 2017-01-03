#appveyor script to build azure test environment for use by pester tests.
#also to remove the azure azure test environment after tests are complete.

Param(
    [switch]$Build,
    [Switch]$Destroy
)
#login to azure with secret stuff
Disable-AzureRmDataCollection
$AzureCredential = new-object -TypeName pscredential -ArgumentList $env:azureapploginid, $($env:azurepassword | convertto-securestring -AsPlainText -force)
Login-AzureRmAccount -Credential $AzureCredential -ServicePrincipal -TenantId $env:AzureTenantID

$RGName = $ENV:ResourceGroupName
$location = $env:location

If ($Build){

$SecureIBAdminPassword = $env:IBAdminPassword | ConvertTo-SecureString -AsPlainText -Force
If (!(Get-azurermresourcegroup $rgname -ea 'silentlycontinue')){
    $ResourceGroup = New-AzureRMResourceGroup -Name $RGName -Location $Location
}
$TestResult = test-AzureRmResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile "$Scriptlocation\AzureDeploy.json" -virtualMachines_TestGridmaster_adminPassword $SecureIBAdminPassword
If ($Testresult.count -eq 0){
    $Result = New-AzureRmResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile "$Scriptlocation\AzureDeploy.json" -virtualMachines_TestGridmaster_adminPassword $SecureIBAdminPassword
    If ($result.ProvisioningState -eq 'Succeeded'){
        $AdminCredential = new-object -TypeName system.management.automation.pscredential -ArgumentList 'admin', $SecureIBAdminPassword
        $GridmasterFQDN = "$($result.parameters.virtualMachines_TestGridmaster_name.value).$($result.parameters.location.value).cloudapp.azure.com"
        $TestEnvironment = new-object psobject -Property @{
            'GridmasterFQDN' = $GridmasterFQDN
            'AdminCredential' = $AdminCredential
        }
        return $TestEnvironment
    } else {
        write-error $Result
        return
    }
} else {
    write-error $TestResult.message
    return
}

} elseif ($Destroy){

} else {
    throw "invalid parameters specified"
}