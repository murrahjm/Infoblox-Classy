#builds module artifact for uploading to appveyor.  basically just concats all the module parts, adds a folder and psd1 file and zips it.
#called by appveyor.yml build step
Param(
    $ModuleName = $Env:ModuleName,
    $ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER,
    $Author = $ENV:APPVEYOR_ACCOUNT_NAME,
    $ModuleVersion = $ENV:APPVEYOR_BUILD_VERSION
)
#create module folder
new-item -Path $ProjectRoot -name $ModuleName -ItemType Directory

#build module files
$Scripts = Get-ChildItem "$projectRoot\ModuleParts" -Filter *.ps1 -Recurse
$FunctionstoExport = $(get-childitem "$ProjectRoot\ModuleParts\Cmdlets").name.replace('.ps1','')
$Scripts | get-content | out-file -FilePath "$projectRoot\$ModuleName\$ModuleName.psm1"
copy-item "$projectroot\infoblox.psd1" "$projectroot\$modulename\$modulename.psd1"
#Update module manifest
$modulemanifestdata = @{
    Author = $Author
    Copyright = "(c) $((get-date).Year) $Author. All rights reserved."
    Path = "$projectRoot\$ModuleName\$ModuleName.psd1"
    FunctionsToExport = $FunctionstoExport
    RootModule = "$ModuleName.psm1"
    ModuleVersion = $ModuleVersion
}
Update-ModuleManifest @modulemanifestdata
