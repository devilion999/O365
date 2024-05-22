# Import the CSV file
# change the CSV file name to your file
$csvPath = "C:\Users\Administrator\Documents\import.csv"
$emailMappings = Import-Csv -Path $csvPath

# Loop through each row in the CSV and set the email forwarding
foreach ($emailMapping in $emailMappings) {
    # Set email forwarding from old email to new email without keeping a copy
    Set-Mailbox -Identity $emailMapping.OldEmail -ForwardingSMTPAddress $emailMapping.NewEmail -DeliverToMailboxAndForward $false
}

# Output completion message
Write-Host "Email forwarding has been set for all users in the CSV file."

