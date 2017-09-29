#script to wedge in between appveyor.yml and psake.ps1
#basically sets all the variables that psake.ps1 expects, checks for dependant modules, then runs psake.ps1
#other build systems can have their own shim script.

$env:BuildSystem = 'Appveyor'
$env:ProjectRoot = $env:APPVEYOR_BUILD_FOLDER
$env:ArtifactRoot = $env:APPVEYOR_BUILD_FOLDER
$env:Author = $env:APPVEYOR_ACCOUNT_NAME
$env:Moduleversion = $env:APPVEYOR_BUILD_VERSION
$DependentModules = @('Pester','Psake','PlatyPS')
Foreach ($Module in $DependentModules){
    If (-not (get-module $module -ListAvailable)){
        install-module -name $Module -Scope CurrentUser
    }
    import-module $module -ErrorAction Stop
}
invoke-psake "$PSScriptRoot\psake.ps1"
