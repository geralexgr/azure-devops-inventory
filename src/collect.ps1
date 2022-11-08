
$organizations= @(
    @{name="ORG_NAME";token="TOKEN"}
)


Function Get-Projects-Within-Org([string]$organization, [string]$token) {
    $projects = @()
    $base64AuthInfo= [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($token)"))
    $URL = "https://dev.azure.com/$organization/_apis/projects?api-version=6.0"
    $result = Invoke-RestMethod -Uri $URL -Headers @{authorization = "Basic $base64AuthInfo"} -Method GET -ContentType "application/json"
    foreach ($item in $result) {
        $projects+=  $item.value.name
    }
    return $projects
}

Function Get-Repos-Within-Org([string]$organization, $projects , [string]$token) {
    $repos= @()
    $base64AuthInfo= [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($token)"))
    foreach ($project in $projects) {
        $URL = "https://dev.azure.com/$organization/$project/_apis/git/repositories?api-version=6.0-preview.1"
        $result = Invoke-RestMethod -Uri $URL -Headers @{authorization = "Basic $base64AuthInfo"} -Method GET -ContentType "application/json"
        foreach ($item in $result) {
            $repos +=  $item.value.name
        }
    }
    return $repos
}

Function Get-Repos-PerProject-Within-Org([string]$organization, $projects , [string]$token) {
    $repos= @{}
    $base64AuthInfo= [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($token)"))
    foreach ($project in $projects) {
        $URL = "https://dev.azure.com/$organization/$project/_apis/git/repositories?api-version=6.0-preview.1"
        $result = Invoke-RestMethod -Uri $URL -Headers @{authorization = "Basic $base64AuthInfo"} -Method GET -ContentType "application/json"
        foreach ($item in $result) {
            $repos.Add($project,$item.value.name)
        }
    }
    return $repos
}


Function Get-Agentpools-Within-Org([string]$organization , [string]$token) {
    $pools= @()
    $base64AuthInfo= [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($token)"))
    $URL = "https://dev.azure.com/$organization/_apis/distributedtask/pools?api-version=6.0"
    $result = Invoke-RestMethod -Uri $URL -Headers @{authorization = "Basic $base64AuthInfo"} -Method GET -ContentType "application/json"
    foreach ($item in $result) {
            $pools +=  $item.value.name
    }
    return $pools
}


Function Get-Agents-Within-Org([string]$organization , [string]$token) {
    $pool_ids= @()
    $agents= @()
    $base64AuthInfo= [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($token)"))
    $URL = "https://dev.azure.com/$organization/_apis/distributedtask/pools?api-version=6.0"
    $result = Invoke-RestMethod -Uri $URL -Headers @{authorization = "Basic $base64AuthInfo"} -Method GET -ContentType "application/json"
    foreach ($item in $result) {
            $pool_ids +=  $item.value.id
    }
    foreach ($id in $pool_ids) {
        $URL = "https://dev.azure.com/$organization/_apis/distributedtask/pools/$id/agents/?api-version=6.0"
        $result = Invoke-RestMethod -Uri $URL -Headers @{authorization = "Basic $base64AuthInfo"} -Method GET -ContentType "application/json"
        foreach ($item in $result) {
            $agents +=  $item.value.name
        }
        
    }
    return $agents
}


Function Get-Pipelines-Within-Org([string]$organization, $projects , [string]$token) {
    $pipelines= @()
    $base64AuthInfo= [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($token)"))
    foreach ($project in $projects) {
        $URL = "https://dev.azure.com/$organization/$project/_apis/pipelines?api-version=6.0-preview.1"
        $result = Invoke-RestMethod -Uri $URL -Headers @{authorization = "Basic $base64AuthInfo"} -Method GET -ContentType "application/json"
        foreach ($item in $result) {
            $pipelines +=  $item.value.name
        }
    }
    return $pipelines
}



foreach ($item in $organizations) {
    Write-Host Organization: $item.name -ForegroundColor red
    Write-Host "####################" -ForegroundColor DarkYellow
    Write-Host $item.name Projects -ForegroundColor red
    Write-Host "####################" -ForegroundColor DarkYellow
    $projects = Get-Projects-Within-Org -organization $item.name -token $item.token
    Write-Output $projects
    Write-Host "####################" -ForegroundColor DarkYellow
    Write-Host $item.name Repos -ForegroundColor red
    Write-Host "####################" -ForegroundColor DarkYellow
    $repos = Get-Repos-Within-Org -organization $item.name -projects $projects -token $item.token 
    Write-Output $projects
    Write-Host "####################" -ForegroundColor DarkYellow
    Write-Host $item.name Agents -ForegroundColor red
    Write-Host "####################" -ForegroundColor DarkYellow
    $agents = Get-Agents-Within-Org -organization $item.name -token $item.token
    Write-Output $agents
    Write-Host "####################" -ForegroundColor DarkYellow
    Write-Host $item.name Pipelines -ForegroundColor red
    Write-Host "####################" -ForegroundColor DarkYellow
    $pipelines = Get-Pipelines-Within-Org -organization $item.name -projects $projects -token $item.token
    Write-Output $pipelines
}




