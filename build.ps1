#builds module artifact for uploading to appveyor.  basically just concats all the module parts, adds a folder and psd1 file and zips it.
#called by appveyor.yml build step

$ModuleName = $ENV:ModuleName
$ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER
#create module folder
new-item -Path $ProjectRoot -name $ModuleName

#concat moduleparts files
$Scripts = Get-ChildItem "$projectRoot\ModuleParts" -Filter *.ps1 -Recurse
$FunctionstoExport = $(get-childitem).name.replace('.ps1','')
$Scripts | get-content | out-file -FilePath "$projectRoot\$ModuleName\$ModuleName.psm1"

#Update module manifest
$modulemanifestdata = @{
    Author = $ENV:APVEYOR_ACCOUNT_NAME
    Copyright = "(c) $((get-date).Year) $ENV:APVEYOR_ACCOUNT_NAME. All rights reserved."
    Path = "$projectRoot\$ModuleName\$ModuleName.psd1"
    FunctionsToExport = $FunctionstoExport
    RootModule = "$ModuleName.psm1"
    ModuleVersion = $ENV:APPVEYOR_BUILD_VERSION

}
Update-ModuleManifest @modulemanifestdata
