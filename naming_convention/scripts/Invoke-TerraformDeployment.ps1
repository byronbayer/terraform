<#
.SYNOPSIS
    Terraform deployment automation with init, validate, plan, and apply operations.

.DESCRIPTION
    This module provides functions to automate Terraform workflow with proper error handling,
    logging, and plan visualization using DOT/Graphviz.

.PARAMETER Action
    The action to perform: init, validate, plan, apply, full, or destroy

.PARAMETER TerraformDirectory
    Path to the directory containing Terraform files

.PARAMETER SubscriptionId
    Azure subscription ID (auto-detected if not provided)

.PARAMETER AutoApprove
    Skip confirmation prompts for apply

.PARAMETER Destroy
    Run terraform destroy instead of apply

.PARAMETER Variables
    Additional Terraform variables as a hashtable

.EXAMPLE
    .\Invoke-TerraformDeployment.ps1 -Action plan

.EXAMPLE
    .\Invoke-TerraformDeployment.ps1 -Action apply -AutoApprove

.EXAMPLE
    .\Invoke-TerraformDeployment.ps1 -Action destroy -AutoApprove

.NOTES
    Author: DevOps Team
    Version: 2.0
    Requires: Terraform, Azure CLI, Graphviz (optional)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('init', 'validate', 'plan', 'apply', 'full', 'destroy')]
    [string]$Action = 'plan',
    
    [Parameter(Mandatory = $false)]
    [string]$TerraformDirectory,
    
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $false)]
    [switch]$AutoApprove,
    
    [Parameter(Mandatory = $false)]
    [switch]$Destroy,
    
    [Parameter(Mandatory = $false)]
    [hashtable]$Variables = @{}
)

#region Configuration
$script:Config = @{
    TenantId = '567f2a71-ca0a-4079-b1cf-f21458585a03'
    ErrorActionPreference = 'Stop'
}
#endregion

#region Core Functions

function Write-TerraformLog {
    <#
    .SYNOPSIS
        Write formatted log messages to console.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Console output with colors
    switch ($Level) {
        'Success' { Write-Host $logMessage -ForegroundColor Green }
        'Warning' { Write-Host $logMessage -ForegroundColor Yellow }
        'Error' { Write-Host $logMessage -ForegroundColor Red }
        default { Write-Host $logMessage -ForegroundColor Cyan }
    }
}

function Invoke-TerraformCommand {
    <#
    .SYNOPSIS
        Execute a Terraform command with error handling and logging.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,
        
        [Parameter(Mandatory = $true)]
        [string]$Description,
        
        [Parameter(Mandatory = $false)]
        [switch]$StreamOutput
    )
    
    Write-TerraformLog "Starting: $Description" -Level Info
    Write-TerraformLog "Command: $Command" -Level Info
    
    try {
        if ($StreamOutput) {
            # Stream output directly to console for real-time feedback
            Invoke-Expression $Command
            $exitCode = $LASTEXITCODE
        }
        else {
            # Capture both stdout and stderr
            $output = Invoke-Expression $Command 2>&1 | Out-String
            $exitCode = $LASTEXITCODE
            
            # Always show the output for visibility
            if ($output) {
                Write-Host $output
            }
        }
        
        if ($exitCode -ne 0) {
            Write-TerraformLog "Failed: $Description (Exit Code: $exitCode)" -Level Error
            throw "Terraform command failed with exit code $exitCode"
        }
        
        Write-TerraformLog "Completed: $Description" -Level Success
        return $output
    }
    catch {
        Write-TerraformLog "Exception: $_" -Level Error
        throw
    }
}

function New-TerraformPlanVisualization {
    <#
    .SYNOPSIS
        Generate DOT graph and visualizations from Terraform plan.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PlanFile,
        
        [Parameter(Mandatory = $true)]
        [string]$PlanJsonFile,
        
        [Parameter(Mandatory = $true)]
        [string]$OutputDirectory
    )
    
    $dotFile = Join-Path $OutputDirectory 'tfplan.dot'
    $svgFile = Join-Path $OutputDirectory 'tfplan.svg'
    $pngFile = Join-Path $OutputDirectory 'tfplan.png'
    $summaryFile = Join-Path $OutputDirectory 'tfplan-summary.txt'
    
    Write-TerraformLog "Generating plan visualization..." -Level Info
    
    try {
        # Generate DOT graph from plan
        Write-TerraformLog "Creating Terraform graph in DOT format..." -Level Info
        $graphOutput = terraform graph -plan="$PlanFile" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Set-Content -Path $dotFile -Value $graphOutput -Encoding UTF8
            Write-TerraformLog "DOT graph saved to: $dotFile" -Level Success
            
            # Check if Graphviz is installed
            $graphvizInstalled = $null -ne (Get-Command dot -ErrorAction SilentlyContinue)
            
            if ($graphvizInstalled) {
                Write-TerraformLog "Graphviz detected. Generating SVG and PNG visualizations..." -Level Info
                
                # Generate SVG
                try {
                    & dot -Tsvg "$dotFile" -o "$svgFile" 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Write-TerraformLog "SVG graph saved to: $svgFile" -Level Success
                    }
                }
                catch {
                    Write-TerraformLog "Failed to generate SVG: $_" -Level Warning
                }
                
                # Generate PNG
                try {
                    & dot -Tpng "$dotFile" -o "$pngFile" 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Write-TerraformLog "PNG graph saved to: $pngFile" -Level Success
                    }
                }
                catch {
                    Write-TerraformLog "Failed to generate PNG: $_" -Level Warning
                }
                
                # Open the SVG file if it exists
                if (Test-Path $svgFile) {
                    Start-Process $svgFile
                    Write-TerraformLog "Opened visualization in default browser" -Level Success
                }
            }
            else {
                Write-TerraformLog "Graphviz not found. Install it to generate SVG/PNG from DOT file." -Level Warning
                Write-TerraformLog "Download from: https://graphviz.org/download/" -Level Info
                Write-TerraformLog "Or install via: winget install graphviz" -Level Info
                Write-TerraformLog "DOT file can be visualized at: https://dreampuf.github.io/GraphvizOnline/" -Level Info
            }
        }
        else {
            Write-TerraformLog "Failed to generate graph. Falling back to JSON summary..." -Level Warning
        }
        
        # Generate text summary from JSON
        $planData = Get-Content $PlanJsonFile -Raw | ConvertFrom-Json
        
        # Count changes
        $creates = 0
        $updates = 0
        $deletes = 0
        $noOps = 0
        
        if ($planData.resource_changes) {
            foreach ($change in $planData.resource_changes) {
                $actions = $change.change.actions
                if ($actions -contains 'create') { $creates++ }
                elseif ($actions -contains 'delete' -and $actions -contains 'create') { $updates++ }
                elseif ($actions -contains 'update') { $updates++ }
                elseif ($actions -contains 'delete') { $deletes++ }
                else { $noOps++ }
            }
        }
        
        # Create summary report
        $summary = @"
=== Terraform Plan Summary ===
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Resource Changes:
  + Create:  $creates
  ~ Update:  $updates
  - Delete:  $deletes
  = No-Op:   $noOps

Total Changes: $($creates + $updates + $deletes)

"@

        if ($planData.resource_changes -and ($creates + $updates + $deletes) -gt 0) {
            $summary += "Detailed Changes:`n`n"
            
            foreach ($change in $planData.resource_changes) {
                $actions = $change.change.actions
                $resourceType = $change.type
                $resourceName = $change.address
                
                if ($actions -contains 'create') {
                    $summary += "  [+] CREATE: $resourceType - $resourceName`n"
                }
                elseif ($actions -contains 'delete' -and $actions -contains 'create') {
                    $summary += "  [±] REPLACE: $resourceType - $resourceName`n"
                }
                elseif ($actions -contains 'update') {
                    $summary += "  [~] UPDATE: $resourceType - $resourceName`n"
                }
                elseif ($actions -contains 'delete') {
                    $summary += "  [-] DELETE: $resourceType - $resourceName`n"
                }
            }
        }
        else {
            $summary += "No infrastructure changes detected.`n"
        }
        
        Set-Content -Path $summaryFile -Value $summary -Encoding UTF8
        Write-TerraformLog "Text summary saved to: $summaryFile" -Level Success
        
        # Display summary in console
        Write-Host "`n$summary" -ForegroundColor Cyan
        
        return @{
            Creates = $creates
            Updates = $updates
            Deletes = $deletes
            NoOps = $noOps
        }
    }
    catch {
        Write-TerraformLog "Failed to generate plan visualization: $_" -Level Warning
        return $null
    }
}

function Invoke-TerraformDeployment {
    <#
    .SYNOPSIS
        Execute Terraform deployment workflow.
    
    .DESCRIPTION
        Automates Terraform init, validate, plan, and apply operations with proper
        error handling, logging, and visualization.
    
    .EXAMPLE
        Invoke-TerraformDeployment -Action plan
    
    .EXAMPLE
        Invoke-TerraformDeployment -Action apply -AutoApprove
    
    .EXAMPLE
        Invoke-TerraformDeployment -Action full -TerraformDirectory "C:\terraform\project"
    
    .EXAMPLE
        Invoke-TerraformDeployment -Action destroy -AutoApprove
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('init', 'validate', 'plan', 'apply', 'full', 'destroy')]
        [string]$Action = 'plan',
        
        [Parameter(Mandatory = $false)]
        [string]$TerraformDirectory,
        
        [Parameter(Mandatory = $false)]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory = $false)]
        [switch]$AutoApprove,
        
        [Parameter(Mandatory = $false)]
        [switch]$Destroy,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$Variables = @{}
    )
    
    # Determine terraform directory
    if (-not $TerraformDirectory) {
        $TerraformDirectory = Join-Path $PSScriptRoot '..\terraform'
    }
    
    if (-not (Test-Path $TerraformDirectory)) {
        throw "Terraform directory not found: $TerraformDirectory"
    }
    
    # Setup paths
    $planFile = Join-Path $TerraformDirectory 'tfplan'
    $planJsonFile = Join-Path $TerraformDirectory 'tfplan.json'
    
    Clear-Host
    Write-TerraformLog "=== Terraform Deployment ===" -Level Info
    Write-TerraformLog "Action: $Action" -Level Info
    Write-TerraformLog "Directory: $TerraformDirectory" -Level Info
    
    # Change to terraform directory
    Push-Location $TerraformDirectory
    
    try {
        # Get Azure context
        if (-not $SubscriptionId) {
            $SubscriptionId = az account show --query id --output tsv
            $subscriptionName = az account show --query name --output tsv
            
            if ([string]::IsNullOrEmpty($SubscriptionId)) {
                throw "Not logged into Azure. Please run 'az login' first."
            }
            
            Write-TerraformLog "Tenant ID: $($script:Config.TenantId)" -Level Info
            Write-TerraformLog "Subscription ID: $SubscriptionId" -Level Info
            Write-TerraformLog "Subscription Name: $subscriptionName" -Level Info
        }
        else {
            # Set the Azure CLI context to the provided subscription
            Write-TerraformLog "Setting Azure CLI context to subscription: $SubscriptionId" -Level Info
            az account set --subscription $SubscriptionId
            $subscriptionName = az account show --query name --output tsv
            Write-TerraformLog "Subscription Name: $subscriptionName" -Level Info
        }
        
        # Add subscription_id to variables
        $Variables['subscription_id'] = $SubscriptionId
        
        # Build variable arguments
        $varArgs = ($Variables.GetEnumerator() | ForEach-Object { "-var=`"$($_.Key)=$($_.Value)`"" }) -join ' '
        
        # Terraform Format
        if ($Action -in @('full', 'init')) {
            try {
                Invoke-TerraformCommand -Command "terraform fmt -recursive" -Description "Format Terraform files"
            }
            catch {
                Write-TerraformLog "Format failed, but continuing..." -Level Warning
            }
        }
        
        # Terraform Init
        if ($Action -in @('full', 'init')) {
            Invoke-TerraformCommand -Command "terraform init -upgrade" -Description "Initialize Terraform"
        }
        
        # Terraform Validate
        if ($Action -in @('full', 'validate', 'plan')) {
            Invoke-TerraformCommand -Command "terraform validate" -Description "Validate Terraform configuration"
        }
        
        # Terraform Plan
        if ($Action -in @('full', 'plan', 'apply')) {
            if ($Destroy) {
                Invoke-TerraformCommand -Command "terraform plan -destroy -out=`"$planFile`" $varArgs" -Description "Generate destroy plan"
            }
            else {
                Invoke-TerraformCommand -Command "terraform plan -out=`"$planFile`" $varArgs" -Description "Generate Terraform plan"
            }
            
            # Convert plan to JSON and create visualizations
            try {
                Write-TerraformLog "Converting plan to JSON..." -Level Info
                terraform show -json "$planFile" | Out-File -FilePath $planJsonFile -Encoding utf8
                
                # Generate visualizations
                $summary = New-TerraformPlanVisualization -PlanFile $planFile -PlanJsonFile $planJsonFile -OutputDirectory $TerraformDirectory
                
                if ($summary) {
                    Write-TerraformLog "Plan Summary:" -Level Info
                    Write-TerraformLog "  - Resources to create: $($summary.Creates)" -Level Info
                    Write-TerraformLog "  - Resources to update: $($summary.Updates)" -Level Info
                    Write-TerraformLog "  - Resources to delete: $($summary.Deletes)" -Level Info
                }
            }
            catch {
                Write-TerraformLog "Failed to create plan visualization: $_" -Level Warning
            }
        }
        
        # Terraform Apply
        if ($Action -in @('full', 'apply')) {
            if (-not (Test-Path $planFile)) {
                throw "Plan file not found. Please run 'plan' first."
            }
            
            if (-not $AutoApprove) {
                Write-Host "`n" -NoNewline
                $confirmation = Read-Host "Do you want to apply this plan? (yes/no)"
                if ($confirmation -ne 'yes') {
                    Write-TerraformLog "Apply cancelled by user" -Level Warning
                    return
                }
            }
            
            if ($Destroy) {
                Invoke-TerraformCommand -Command "terraform apply `"$planFile`"" -Description "Destroy infrastructure" -StreamOutput
            }
            else {
                Invoke-TerraformCommand -Command "terraform apply `"$planFile`"" -Description "Apply Terraform plan" -StreamOutput
            }
            
            Write-TerraformLog "Deployment completed successfully!" -Level Success
        }
        
        Write-TerraformLog "=== Script Completed ===" -Level Success
    }
    finally {
        Pop-Location
    }
}

#endregion

#region Usage Examples
<#
# Example 1: Run a plan
Invoke-TerraformDeployment -Action plan

# Example 2: Run a full deployment with auto-approve
Invoke-TerraformDeployment -Action full -AutoApprove

# Example 3: Apply an existing plan
Invoke-TerraformDeployment -Action apply

# Example 4: Destroy infrastructure
Invoke-TerraformDeployment -Action destroy -AutoApprove

# Example 5: Just validate the configuration
Invoke-TerraformDeployment -Action validate

# Example 6: Initialize Terraform
Invoke-TerraformDeployment -Action init

# Example 7: Custom terraform directory
Invoke-TerraformDeployment -Action plan -TerraformDirectory "C:\terraform\myproject"

# Example 8: Plan with additional variables
Invoke-TerraformDeployment -Action plan -Variables @{
    environment = "production"
    region = "eastus"
}
#>
#endregion

# Execute the function when script is run directly (F5 or from command line)
# Invoke-TerraformDeployment @PSBoundParameters
Invoke-TerraformDeployment -Action apply -AutoApprove