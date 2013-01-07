param($installPath, $toolsPath, $package, $project)

Import-Module (Join-Path $toolsPath "MSBuild.psm1")

function Uninstall-Targets ( $project )
{
    Write-Host ("Uninstalling Targets file import from project " + $project.Name)

    $buildProject = Get-MSBuildProject

    $buildProject.Xml.Imports | Where-Object { $_.Project -match "EmbedAssemblies.targets" } | foreach-object {
        Write-Host ("Removing old import:      " + $_.Project)
        $buildProject.Xml.RemoveChild($_) 
    }

    $project.Save() 

    Write-Host ("Import removed!")
}

function Main
{
    Uninstall-Targets $project
}

Main
