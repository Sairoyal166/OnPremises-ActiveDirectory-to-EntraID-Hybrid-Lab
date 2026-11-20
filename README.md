# OnPremises-ActiveDirectory-to-EntraID-Hybrid-Lab
End-to-end On-Premises Active Directory (Windows Server 2022) and Microsoft Entra ID Hybrid Cloud Security Lab

## The Story

Imagine a company called **CorpLab** running its entire user and device management on an on-premises Windows Server. Every user, every department, every password, and every workstation policy — all managed locally on a single Domain Controller (`corp.local`).

The IT team decided it was time to **modernize and extend to the cloud**. The goal: synchronize on-premises Active Directory identities to **Microsoft Entra ID** (`CorpLab-Entra`) — Microsoft's modern cloud identity platform — enforce zero-trust privileged access, and automate cloud device management with **Microsoft Intune** without disrupting end users.

---

## Tech Stack

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Virtualization** | Oracle VirtualBox | Isolated enterprise lab host environment |
| **On-Premises Server** | Windows Server 2022 | Domain Controller (`corp.local`), AD DS, DNS, and GPOs |
| **Client Workstation** | Windows 11 Enterprise | Domain-joined corporate endpoint |
| **Hybrid Sync Engine** | Microsoft Entra Connect | Synchronizes AD users, groups, and password hashes |
| **Cloud Identity** | Microsoft Entra ID (P2) | Cloud directory (`CorpLab-Entra`), PIM, and ID Protection |
| **Endpoint Management** | Microsoft Intune | Automated MDM device enrollment and compliance |
| **Automation & Audit** | PowerShell | Hybrid join verification (`dsregcmd`) and policy updates |

---
