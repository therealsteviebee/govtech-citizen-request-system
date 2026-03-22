using namespace System.Net

param($Request, $TriggerMetadata)

$ErrorActionPreference = "Stop"

function Get-RequiredSetting {
    param([string]$Name)

    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Missing required application setting: $Name"
    }
    return $value
}

function Write-JsonResponse {
    param(
        [int]$StatusCode,
        [object]$BodyObject
    )

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $StatusCode
        Headers    = @{ "Content-Type" = "application/json" }
        Body       = ($BodyObject | ConvertTo-Json -Depth 10)
    })
}

try {
    $body = $Request.Body

    if ($body -is [string]) {
        $body = $body | ConvertFrom-Json
    }

    if (-not $body) {
        throw "Request body is empty."
    }

    $requiredFields = @("fullName", "email", "requestType", "location", "description")
    foreach ($field in $requiredFields) {
        if ([string]::IsNullOrWhiteSpace([string]$body.$field)) {
            throw "Missing required field: $field"
        }
    }

    $jiraBaseUrl   = Get-RequiredSetting -Name "JIRA_BASE_URL"
    $jiraEmail     = Get-RequiredSetting -Name "JIRA_EMAIL"
    $jiraApiToken  = Get-RequiredSetting -Name "JIRA_API_TOKEN"
    $jiraProject   = Get-RequiredSetting -Name "JIRA_PROJECT_KEY"
    $jiraIssueType = Get-RequiredSetting -Name "JIRA_ISSUE_TYPE"
    $slackToken    = Get-RequiredSetting -Name "SLACK_BOT_TOKEN"
    $slackChannel  = Get-RequiredSetting -Name "SLACK_CHANNEL_ID"

    $summary = "[Citizen Request] $($body.requestType) - $($body.location)"

    $descriptionLines = @(
        "Reporter Name: $($body.fullName)",
        "Reporter Email: $($body.email)",
        "Request Type: $($body.requestType)",
        "Location: $($body.location)",
        "",
        "Description:",
        "$($body.description)"
    )

    $jiraPayload = @{
        fields = @{
            project     = @{ key = $jiraProject }
            summary     = $summary
            description = ($descriptionLines -join "`n")
            issuetype   = @{ name = $jiraIssueType }
        }
    } | ConvertTo-Json -Depth 10

    $jiraAuthBytes = [System.Text.Encoding]::UTF8.GetBytes("$jiraEmail`:$jiraApiToken")
    $jiraAuthValue = [Convert]::ToBase64String($jiraAuthBytes)

    $jiraHeaders = @{
        "Authorization" = "Basic $jiraAuthValue"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }

    $jiraResponse = Invoke-RestMethod -Method Post `
        -Uri "$jiraBaseUrl/rest/api/3/issue" `
        -Headers $jiraHeaders `
        -Body $jiraPayload

    if ([string]::IsNullOrWhiteSpace([string]$jiraResponse.key)) {
        throw "Jira issue was not created successfully."
    }

    $slackPayload = @{
        channel = $slackChannel
        text    = "New citizen request created: *$($jiraResponse.key)* | $($body.requestType) | $($body.location)"
    }

    $slackHeaders = @{
        "Authorization" = "Bearer $slackToken"
    }

    $slackResponse = Invoke-RestMethod -Method Post `
        -Uri "https://slack.com/api/chat.postMessage" `
        -Headers $slackHeaders `
        -Body $slackPayload

    if (-not $slackResponse.ok) {
        throw "Slack notification failed: $($slackResponse.error)"
    }

    Write-JsonResponse -StatusCode 200 -BodyObject @{
        success   = $true
        message   = "Citizen request processed successfully."
        jiraKey   = $jiraResponse.key
        jiraId    = $jiraResponse.id
        slackSent = $true
    }
}
catch {
    Write-JsonResponse -StatusCode 400 -BodyObject @{
        success = $false
        error   = $_.Exception.Message
    }
}
