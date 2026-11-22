# Verify Hybrid Entra ID Join and Intune MDM Enrollment
gpupdate /force

dsregcmd /status | Select-String -Pattern "AzureAdJoined|DomainJoined|DomainName|TenantName|MdmUrl|AzureAdPrt"

Get-ScheduledTask -TaskPath "\Microsoft\Windows\EnterpriseMgmt\*" -ErrorAction SilentlyContinue |
    Select-Object TaskName, State
