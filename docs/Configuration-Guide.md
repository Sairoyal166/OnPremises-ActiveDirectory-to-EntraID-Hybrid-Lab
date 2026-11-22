# Lab Configuration & Command Reference

## 1. Infrastructure & Policy Overview
* **Domain Controller (`windows-server-2022`):** Windows Server 2022 (`corp.local`) with AD DS and DNS roles installed.
* **Client Workstation (`Windows-11-Client`):** Windows 11 Enterprise domain-joined to `corp.local` and registered in `CorpLab-Entra`.
* **Group Policy Objects (`gpmc.msc`):** `IT_Desktop_policy`, `Youtube_Restriction`, `GPO_Event_Forwarding`, and `Intune MDM Auto Enrolment`.
* **Hybrid Sync & Governance (`CorpLab-Entra`):** Microsoft Entra Connect (Password Hash Synchronization, Password Writeback, Hybrid Entra Join), Microsoft Entra ID P2, Microsoft Intune, PIM, and Entra ID Protection.

## 2. Administrative Consoles & Commands Used

| Phase | Command / Shortcut | Purpose |
| :--- | :--- | :--- |
| **Phase 1** | `ipconfig /all` | Verify static IPv4, subnet mask, gateway, and internal DNS configuration. |
| **Phase 1** | `ping corp.local` | Validate network reachability and DNS resolution between client and DC. |
| **Phase 2** | `dsa.msc` | Manage Organizational Units, security groups, and domain users in Active Directory. |
| **Phase 2** | `sysdm.cpl` | Join `Windows-11-Client` from `WORKGROUP` to the `corp.local` domain. |
| **Phase 2** | `gpmc.msc` | Create, edit, and link custom Group Policy Objects to departmental OUs. |
| **Phase 2** | `gpupdate /force` | Force immediate Group Policy refresh on domain-joined endpoints. |
| **Phase 2** | `gpresult /r` | Audit applied Computer and User Group Policy Objects on the client. |
| **Phase 3** | `Start-ADSyncSyncCycle -PolicyType Delta` | Trigger an on-demand Entra Connect delta sync from `windows-server-2022`. |
| **Phase 4** | `dsregcmd /status` | Verify `AzureAdJoined : YES`, `DomainJoined : YES`, and MDM registration URLs. |
| **Phase 4** | `taskschd.msc` | Inspect and run the Intune MDM enrollment task under `\Microsoft\Windows\EnterpriseMgmt\`. |
