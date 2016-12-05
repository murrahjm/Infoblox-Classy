add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$RGName = 'InfobloxTesting'
$location = 'SouthCentralUS'
$IBAdminPassword = "Password1234"
$SecureIBAdminPassword = $IBAdminPassword | ConvertTo-SecureString -AsPlainText -Force
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
