#################################################
#         script Automation for Migwiz          #
#            Created by Moran Shechter          #
#              Date 30/4/2025                   #
#################################################

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Application.ReadWrite.All Directory.AccessAsUser.All"

# Create the application
$app = New-MgApplication -DisplayName "migwiz" -SignInAudience "AzureADMyOrg"
$appId = $app.Id

# Enable fallbackPublicClient using raw Graph PATCH request
Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/applications/$appId" -Body @{
    fallbackPublicClient = @{
        enabled = $true
    }
}

# Define required API permissions (Exchange Online)
$requiredResourceAccess = @(
    @{
        ResourceAppId = "00000002-0000-0ff1-ce00-000000000000";
        ResourceAccess = @(
            @{
                Id = "3b5f3d61-589b-4a3c-a359-5dd4b5ee5bd5";  # EWS.AccessAsUser.All
                Type = "Role"
            },
            @{
                Id = "dc890d15-9560-4a4c-9b7f-a736ec74ec40";  # full_access_as_app
                Type = "Role"
            }
        )
    }
)

# Assign permissions to the application
Update-MgApplication -ApplicationId $appId -BodyParameter @{
    RequiredResourceAccess = $requiredResourceAccess
}

# Create client secret (valid 730 days)
$secret = Add-MgApplicationPassword -ApplicationId $appId -PasswordCredential @{
    DisplayName = "migwiz"
    EndDateTime = (Get-Date).AddDays(730)
}

# Get the service principal of the newly created app
$sp = Get-MgServicePrincipal -Filter "AppId eq '$($app.AppId)'"

# Attempt to grant admin consent (simulate consent flow)
foreach ($perm in $requiredResourceAccess) {
    foreach ($access in $perm.ResourceAccess) {
        try {
            New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -PrincipalId $sp.Id -ResourceId $perm.ResourceAppId -AppRoleId $access.Id
        } catch {
            Write-Warning "Admin consent could not be granted automatically. You may need to grant it manually."
        }
    }
}

# ✅ Output the actual client secret VALUE (SecretText)
Write-Output "`n✅ App created successfully!"
Write-Output "🔹 App ID: $appId"
Write-Output "🔹 Client Secret VALUE (store this securely): $($secret.SecretText)"
Write-Output "`n⚠️ Save this value now — it is only shown once!"

# Admin consent info
Write-Output "`n🔐 Admin consent was attempted via Graph API."
Write-Output "If errors occurred, please grant manually here:"
Write-Output "https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/CallAnAPI/appId/$appId"
