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
    $tasksToolsPath = (Join-Path $solutionDir "Build")
    $targetPath = (Join-Path $toolsPath "EmbedAssemblies.targets")

    if(!(Test-Path $tasksToolsPath)) {
        mkdir $tasksToolsPath | Out-Null
    }

    if(!(Test-Path (Join-Path $tasksToolsPath "EmbedAssemblies.targets"))) {
        Write-Host "Copying Targets files to $tasksToolsPath"
        Copy-Item $targetPath $tasksToolsPath -Force | Out-Null
    }

    Write-Host "Don't forget to commit the Build folder"
    return '$(SolutionDir)\Build'
}

function Main
{
    $taskPath = Copy-MSBuildTasks $project
    
    Install-Targets $project '$(SolutionDir)\Build\EmbedAssemblies.targets'
}

Main

