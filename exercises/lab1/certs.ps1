[CmdletBinding()]
param (
    [Parameter()][string] $SubscriptionId,
    [Parameter()][string] $KeyVaultSubscriptionId,
    [Parameter()][string] $TenantId,
    [Parameter()][string] $AppId,
    [Parameter()][securestring] $Password,
    [Parameter()][string] $CNames,
    [Parameter()][string] $VaultName,
    [Parameter()][string] $KeyVaultName,
    [Parameter()][int] $DaysBeforeRenewal = 30
)
if(Get-Module -ListAvailable -Name Az){
    Write-Host "##[debug] Skipping import of Az"
}
else{
    Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force
}
# $SecurePassword  = ConvertTo-SecureString $Password -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential ($AppId, $Password)
Connect-AzAccount -Tenant $TenantId -Credential $Credentials -ServicePrincipal -Subscription $KeyVaultSubscriptionId -Scope Process

$cert = Get-AzKeyVaultCertificate -VaultName $VaultName -Name $KeyVaultName


if(!$cert -or ((Get-Date).adddays($DaysBeforeRenewal) -gt $cert.Certificate.NotAfter )){
    if(Get-Module -ListAvailable -Name Posh-ACME){
        Write-Host "##[debug] Skipping import of Posh-ACME"
    }
    else{
        Install-Module -Name Posh-ACME -Scope CurrentUser -Force
        Set-PAServer LE_PROD
    }
    $azParams = @{
        AZSubscriptionId      = $SubscriptionId
        AZTenantId            = $TenantId
        AZAppCred             = $Credentials
    }
    New-PACertificate $CNames.Split(',').Trim() -AcceptTOS -Contact wemawuyts@outlook.com -DnsPlugin Azure -PluginArgs $azParams -Force
    $cert = Get-PACertificate
    Import-AzKeyVaultCertificate -VaultName $VaultName -Name $KeyVaultName -FilePath $cert.PfxFile -Password  $cert.PfxPass
}else {
    Write-Host "##[debug] Skipping certificate renewal for $KeyVaultName certificate is valid till: $($cert.Certificate.NotAfter.ToString('MMMM dd, yyyy'))"
}

Disconnect-AzAccount -Scope Process

