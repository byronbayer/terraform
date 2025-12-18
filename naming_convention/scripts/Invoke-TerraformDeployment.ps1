<#
.SYNOPSIS
    Simple Terraform deployment script.

.DESCRIPTION
    Runs terraform fmt, init, plan, and apply in sequence.

.PARAMETER TerraformDirectory
    Path to the directory containing Terraform files (default: ../terraform)

.PARAMETER Destroy
    Destroy infrastructure instead of creating it

.PARAMETER AutoApprove
    Skip confirmation prompt for apply

.EXAMPLE
    .\Invoke-TerraformDeployment.ps1

.EXAMPLE
    .\Invoke-TerraformDeployment.ps1 -AutoApprove

.EXAMPLE
    .\Invoke-TerraformDeployment.ps1 -Destroy -AutoApprove
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$TerraformDirectory,
    
    [Parameter(Mandatory = $false)]
    [string]$TenantId,
    
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $false)]
    [switch]$Destroy,
    
    [Parameter(Mandatory = $false)]
    [switch]$AutoApprove
)

$ErrorActionPreference = 'Stop'

# Determine terraform directory
if (-not $TerraformDirectory) {
    $TerraformDirectory = Join-Path $PSScriptRoot '..\terraform'
}

if (-not (Test-Path $TerraformDirectory)) {
    Write-Error "Terraform directory not found: $TerraformDirectory"
    exit 1
}

$action = if ($Destroy) { "Destroy" } else { "Deployment" }
Write-Host "=== Terraform $action ===" -ForegroundColor Cyan
Write-Host "Directory: $TerraformDirectory" -ForegroundColor Cyan
Write-Host ""

# Change to terraform directory
Push-Location $TerraformDirectory

try {
    # Get Azure subscription details
    if (-not $SubscriptionId) {
        $SubscriptionId = az account show --query id --output tsv
        if ([string]::IsNullOrEmpty($SubscriptionId)) {
            Write-Error "Not logged into Azure. Please run 'az login' first."
            exit 1
        }
    }
    else {
        az account set --subscription $SubscriptionId | Out-Null
    }
    
    $subscriptionName = az account show --query name --output tsv
    
    if ($TenantId) {
        Write-Host "Tenant ID: $TenantId" -ForegroundColor Cyan
    }
    Write-Host "Subscription ID: $SubscriptionId" -ForegroundColor Cyan
    Write-Host "Subscription Name: $subscriptionName" -ForegroundColor Cyan
    Write-Host ""
    
    # 1. Format
    Write-Host "[1/4] Running terraform fmt..." -ForegroundColor Yellow
    terraform fmt -recursive
    Write-Host "✓ Format complete" -ForegroundColor Green
    Write-Host ""
    
    # 2. Init
    Write-Host "[2/4] Running terraform init..." -ForegroundColor Yellow
    terraform init -upgrade
    if ($LASTEXITCODE -ne 0) { throw "Init failed" }
    Write-Host "✓ Init complete" -ForegroundColor Green
    Write-Host ""
    
    # 3. Plan
    Write-Host "[3/4] Running terraform plan..." -ForegroundColor Yellow
    if ($Destroy) {
        terraform plan -destroy -out=tfplan -var="subscription_id=$SubscriptionId"
    }
    else {
        terraform plan -out=tfplan -var="subscription_id=$SubscriptionId"
    }
    if ($LASTEXITCODE -ne 0) { throw "Plan failed" }
    Write-Host "✓ Plan complete" -ForegroundColor Green
    Write-Host ""
    
    # 4. Apply
    $applyAction = if ($Destroy) { "destroy" } else { "apply" }
    Write-Host "[4/4] Running terraform $applyAction..." -ForegroundColor Yellow
    
    if (-not $AutoApprove) {
        $confirmation = Read-Host "$applyAction this plan? (yes/no)"
        if ($confirmation -ne 'yes') {
            Write-Host "$applyAction cancelled" -ForegroundColor Yellow
            exit 0 
        }
    }
    
    terraform apply tfplan
    if ($LASTEXITCODE -ne 0) { throw "$applyAction failed" }
    Write-Host "✓ $applyAction complete" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "=== $action Complete ===" -ForegroundColor Green
}
catch {
    Write-Error "Deployment failed: $_"
    exit 1
}
finally {
    Pop-Location
}
