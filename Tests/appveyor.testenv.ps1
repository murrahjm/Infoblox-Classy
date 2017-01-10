#appveyor script to build azure test environment for use by pester tests.
#also to remove the azure azure test environment after tests are complete.

Param(
    [switch]$Build,
    [Switch]$Destroy,
    [String]$ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER,
    [String]$RGName = $ENV:ResourceGroupName,
    [string]$location = $env:location

)
#login to azure with secret stuff
Disable-AzureRmDataCollection
$AzureCredential = new-object -TypeName pscredential -ArgumentList $env:azureapploginid, $($env:azurepassword | convertto-securestring -AsPlainText -force)
$AzureLoginStatus = Login-AzureRmAccount -Credential $AzureCredential -ServicePrincipal -TenantId $env:AzureTenantID
If ($AzureLoginStatus -ne $Null){
    write-output "Azure Login Successful"
} else {
    write-error "Azure Login Failed"
    return
}

If ($Build){

If (!(Get-azurermresourcegroup -name $rgname -ea 'silentlycontinue')){
    New-AzureRMResourceGroup -Name $RGName -Location $Location | Out-Null
}
$TestResult = test-AzureRmResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile "$ProjectRoot\tests\AzureDeploy.json" -virtualMachines_TestGridmaster_adminPassword $env:IBAdminPassword
If ($Testresult.count -eq 0){
    $Result = New-AzureRmResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile "$ProjectRoot\tests\AzureDeploy.json" -virtualMachines_TestGridmaster_adminPassword $env:IBAdminPassword
    If ($result.ProvisioningState -ne 'Succeeded'){
        write-error $Result
        return
    }
} else {
    write-error $TestResult.message
    return
}

} elseif ($Destroy){
    Get-azurermResourceGroup -name $rgname | remove-azurermresourcegroup -confirm:$False -Force
} else {
    throw "invalid parameters specified"
}