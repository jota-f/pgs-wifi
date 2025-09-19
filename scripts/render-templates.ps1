<#
render-templates.ps1
Script simples para Windows PowerShell que carrega um arquivo .env e renderiza templates usando substituição de placeholders ${VAR}.
Uso: execute na raiz do projeto: .\scripts\render-templates.ps1
#>

param(
    [string]$EnvFile = ".\.env",
    [switch]$Force
)

function Load-DotEnv {
    param($Path)
    if (-Not (Test-Path $Path)) {
        Write-Error "Env file not found: $Path"
        return $null
    }
    $lines = Get-Content $Path | Where-Object { $_ -and -not ($_ -match '^\s*#') }
    foreach ($line in $lines) {
        if ($line -match '^\s*([^=]+)=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            # Remove optional quotes
            if ($value.StartsWith('"') -and $value.EndsWith('"')) { $value = $value.Substring(1,$value.Length-2) }
            if ($value.StartsWith("'") -and $value.EndsWith("'")) { $value = $value.Substring(1,$value.Length-2) }
            # Set env var for current process
            [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
}

function Render-Template {
    param(
        [string]$TemplatePath,
        [string]$OutputPath
    )
    if (-Not (Test-Path $TemplatePath)) { Write-Error "Template not found: $TemplatePath"; return }
    $content = Get-Content $TemplatePath -Raw
    # Replace ${VAR} with process env variables
    $result = $content -replace '\$\{([A-Za-z0-9_]+)\}', { param($m) ([System.Environment]::GetEnvironmentVariable($m.Groups[1].Value, 'Process') ) }
    # If output exists and not forced, skip
    if ((Test-Path $OutputPath) -and -not $Force) {
        Write-Host "Skipping existing $OutputPath (use -Force to overwrite)"
        return
    }
    $dir = Split-Path $OutputPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $result | Set-Content $OutputPath -Encoding UTF8
    Write-Host "Rendered $TemplatePath -> $OutputPath"
}

# Main
Load-DotEnv -Path $EnvFile

# List of templates to render
$templates = @(
    @{ tpl = "configs/telegraf.conf.tpl"; out = "configs/telegraf.conf" },
    @{ tpl = "grafana/provisioning/datasources/influxdb.yml.tpl"; out = "grafana/provisioning/datasources/influxdb.yml" }
)

foreach ($t in $templates) { Render-Template -TemplatePath $t.tpl -OutputPath $t.out }

Write-Host "Done. Now run: docker compose up -d" -ForegroundColor Green
