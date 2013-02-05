param($installPath, $toolsPath, $package, $project)

Import-Module (Join-Path $toolsPath "MSBuild.psm1")

function Install-Targets ( $project, $importFile )
{
    Write-Host ("Installing Targets file import into project " + $project.Name)

    $buildProject = Get-MSBuildProject

    $buildProject.Xml.Imports | Where-Object { $_.Project -match "EmbedAssemblies.targets" } | foreach-object {
        Write-Host ("Removing old import:      " + $_.Project)
        $buildProject.Xml.RemoveChild($_) 
    }

    Write-Host ("Import will be added for: " + $importFile)
    $target = $buildProject.Xml.AddImport( $importFile )

    $project.Save() 

    Write-Host ("Import added!")
}

function Copy-MSBuildTasks ( $project ) 
{
    $solutionDir = Get-SolutionDir
    $dstToolsPath = (Join-Path $solutionDir "Tools")
    $dstTargetPath = (Join-Path $dstToolsPath "EmbedAssemblies.targets")
    $srcTargetPath = (Join-Path $toolsPath "EmbedAssemblies.targets")

    if(!(Test-Path $dstToolsPath)) {
        mkdir $dstToolsPath | Out-Null
    }

    if(!(Test-Path $dstTargetPath)) {
        Write-Host "Copying Targets files to $dstToolsPath"
        Copy-Item $srcTargetPath $dstToolsPath -Force | Out-Null
    }

    Write-Host "Don't forget to commit the Tools folder"
    return $dstTargetPath
}

function Main
{
    $targetPath = Copy-MSBuildTasks $project
    
    Install-Targets $project $targetPath
}

Main

