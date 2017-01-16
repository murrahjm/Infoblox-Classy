# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
    if(-not $env:ProjectRoot){$env:ProjectRoot = $PSScriptRoot}
    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $lines = '----------------------------------------------------------------------'

}

Task Default -Depends Deploy, CleanTestEnvironment

Task Init {
    $lines
    #azure login code goes here for appveyor build system
    if ($env:BuildSystem -eq 'AppVeyor'){
        Disable-AzureRmDataCollection
        $AzureCredential = new-object -TypeName pscredential -ArgumentList $env:azureapploginid, $($env:azurepassword | convertto-securestring -AsPlainText -force)
        Login-AzureRmAccount -Credential $AzureCredential -ServicePrincipal -TenantId $env:AzureTenantID -ErrorAction Stop | out-null
    }
    #
}
Task Clean -depends Init {
    $lines
    #create empty folder for module build task, delete any existing data
    If (test-path "$env:artifactroot\$env:modulename") {
        Remove-Item "$env:artifactroot\$env:modulename" -Force -Recurse
    }
    new-item -Path $env:artifactroot -name $env:ModuleName -ItemType Directory | out-null

}
Task Build -Depends Clean {
    $lines
    #build module files
    $Scripts = Get-ChildItem "$env:projectRoot\ModuleParts" -Filter *.ps1 -Recurse
    $FunctionstoExport = $(get-childitem "$env:ProjectRoot\ModuleParts\Cmdlets").name.replace('.ps1','')
    $Scripts | get-content | out-file -FilePath "$env:artifactroot\$env:ModuleName\$env:ModuleName.psm1"
    copy-item "$env:projectroot\infoblox.psd1" "$env:artifactroot\$env:modulename\$env:modulename.psd1"
    #Update module manifest
    $modulemanifestdata = @{
        Author = $env:Author
        Copyright = "(c) $((get-date).Year) $env:Author. All rights reserved."
        Path = "$env:artifactroot\$env:ModuleName\$env:ModuleName.psd1"
        FunctionsToExport = $FunctionstoExport
        RootModule = "$env:ModuleName.psm1"
        ModuleVersion = $env:ModuleVersion
    }
    Update-ModuleManifest @modulemanifestdata
}
Task BuildTestEnvironment -depends Build {
    #connect to azure and deploy test environment from azuredeploy.json
    If (!(Get-azurermresourcegroup -name $env:ResourceGroupName -ea 'silentlycontinue')){
        New-AzureRMResourceGroup -Name $env:ResourceGroupName -Location $env:Location | Out-Null
    }
    $TestResult = test-AzureRmResourceGroupDeployment -ResourceGroupName $env:ResourceGroupName -TemplateFile "$env:ProjectRoot\AzureDeploy.json" -virtualMachines_TestGridmaster_adminPassword $env:IBAdminPassword
    If ($Testresult.count -eq 0){
        $Result = New-AzureRmResourceGroupDeployment -ResourceGroupName $env:ResourceGroupName -TemplateFile "$env:ProjectRoot\AzureDeploy.json" -virtualMachines_TestGridmaster_adminPassword $env:IBAdminPassword
        If ($result.ProvisioningState -ne 'Succeeded'){
            write-error $Result
            return
        }
    } else {
        write-error $TestResult.message
        return
    }
}

Task Test -Depends BuildTestEnvironment  {
    $lines
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    # Gather test results. Store them in a variable and file
    $TestResults = Invoke-Pester -Path $env:ProjectRoot -PassThru -OutputFormat NUnitXml -OutputFile "$env:ProjectRoot\$TestFile"

    # In Appveyor?  Upload our tests! #Abstract this into a function?
    If($env:BuildSystem -eq 'AppVeyor')
    {
        (New-Object 'System.Net.WebClient').UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
            "$env:ProjectRoot\$TestFile" )
    }

    Remove-Item "$env:ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue

    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if($TestResults.FailedCount -gt 0)
    {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
    "`n"
}
Task Deploy -Depends Test {
    $lines
    if ($env:BuildSystem -eq 'AppVeyor'){
        Publish-Module -name $env:modulename -NuGetApiKey $env:PSGalleryAPIKey
    }
}

Task CleanTestEnvironment -depends Test {
    #remove azure testing resource group if it exists
    Get-azurermResourceGroup -name $env:resourceGroupname | remove-azurermresourcegroup -confirm:$False -Force
    If (test-path "$env:artifactroot\$env:modulename") {
        Remove-Item "$env:artifactroot\$env:modulename" -Force -Recurse
    }

}
