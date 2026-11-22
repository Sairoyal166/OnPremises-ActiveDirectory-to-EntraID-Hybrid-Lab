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
| **On-Premises Server** | Windows Server 2022 | Domain Controller, AD DS, DNS, and GPOs |
| **Client Workstation** | Windows 11 Enterprise | Domain-joined corporate endpoint |
| **Hybrid Sync Engine** | Microsoft Entra Connect | Synchronizes AD users, groups, and password hashes |
| **Cloud Identity** | Microsoft Entra ID (P2) | Cloud directory , PIM, and ID Protection |
| **Endpoint Management** | Microsoft Intune | Automated MDM device enrollment and compliance |
| **Automation & Audit** | PowerShell | Hybrid join verification  and policy updates |

---

## Phase 1 — Building the Foundation

### Step 1: Virtual Environment Provisioning
* **Hypervisor Setup:** Installed and configured **Oracle VirtualBox** on the physical host machine to simulate an isolated enterprise data center.
* **Virtual Network Architecture:** Configured a dedicated virtual network segment (`NatNetwork`) so the Domain Controller and corporate workstation could communicate privately while maintaining controlled internet access for cloud synchronization.
* **Virtual Machine Provisioning:** Built and allocated dedicated compute, memory, and storage resources for two core enterprise nodes:
  * **`windows-server-2022` (`Windows Server 2022`):** Primary Domain Controller and DNS server (2 vCPUs, 4 GB RAM, dynamically allocated VDI storage).
  * **`Windows-11-Client` (`Windows 11 Enterprise`):** Corporate endpoint workstation used for domain join, Group Policy testing, and Intune enrollment (2 vCPUs, 4 GB RAM, dynamically allocated VDI storage).

![Oracle VirtualBox Manager](screenshots/01-virtualbox-vms.png)

*Oracle VirtualBox Manager showing the provisioned Windows Server 2022 Domain Controller (`windows-server-2022`) and Windows 11 Enterprise client (`Windows-11-Client`) VMs on NatNetwork.*

### Step 2: Static Networking & DNS Configuration
* **Domain Controller Static IP:** Assigned a static IPv4 address (`192.168.10.10/24`) to **`windows-server-2022`** so client machines and DNS records always resolve to a consistent server endpoint.
* **Local DNS Loopback:** Configured **`windows-server-2022`**'s preferred DNS server to point to its own static IP / loopback (`127.0.0.1`) in preparation for hosting the Active Directory-integrated DNS zone.
* **Client DNS Pointing:** Configured **`Windows-11-Client`**'s IPv4 network adapter to use **`windows-server-2022`** (`192.168.10.10`) as its primary DNS server, ensuring all internal domain queries route directly to the Domain Controller.
* **Connectivity Verification:** Validated bidirectional network reachability and name resolution between **`Windows-11-Client`** and **`windows-server-2022`** using `ping` and `nslookup` before promoting the server.

> **Why this matters:** Active Directory relies heavily on DNS (`SRV` records) for Domain Controller discovery, Kerberos authentication, and Group Policy retrieval. Pointing clients to an external public DNS instead of the internal Domain Controller is the cause of failed domain joins in enterprise environments.

---

## Phase 2 — Setting Up Active Directory (`corp.local`)

### Step 1: Installing AD DS & Promoting the Domain Controller
* **Role Installation:** Installed the **Active Directory Domain Services (AD DS)** and **DNS Server** roles on the **Windows Server 2022** (`windows-server-2022`) virtual machine via Server Manager.
* **Domain Promotion:** Promoted the server to a primary Domain Controller, creating a new forest and root domain named **`corp.local`** (NetBIOS: `CORP`) with **Global Catalog (GC)** enabled and a DSRM recovery password configured.
* **Post-Reboot Validation:** Rebooted the Domain Controller and verified that core directory services (`NTDS`, `DNS`, `Netlogon`, `KDC`) were running and Active Directory DNS zones (`msdcs.corp.local` and `corp.local`) were populated.

### Step 2: Creating Organizational Units (OUs), Directory Objects & User Lifecycle Management
* **Creating Departmental OUs ** Opened **Active Directory Users and Computers ** via Server Manager -> Tools on **`windows-server-2022`**, right-clicked **`corp.local`** -> **New** -> **Organizational Unit**, and created dedicated departmental OUs (**`Company Users`**, **`Facilities`**, **`HR Department`**, **`IT`**, **`Logistics`**, **`Marketing`**, and **`Sales`**) to isolate users, endpoints, and shared resources from default containers.
* **Provisioning Departmental Users, Computers & Printers:** Right-clicked the target departmental OU (such as **`Sales`**) -> **New** to create and organize directory objects:
  * **Users (`New -> User`):** Created standard domain user accounts within their respective departments — including **`Devi Shree`** (`CORP\Devi Shree` / `Devishree@corp.local`) and **`Surendra Singh`** inside **`Sales`** — with compliant domain passwords.
  * **Computers (`New -> Computer` / Domain Join):** Pre-staged computer objects (`DESKTOP-0A...`) inside their departmental OUs (or moved joined workstations from the default **`Computers`** container) so computer-level GPOs target each department accurately.
  * **Security Groups (`New -> Group`):** Created departmental security groups (such as **`Sales_Team`**) to assign permissions and group policies via Role-Based Access Control (RBAC).
  * **Network Printers (`New -> Printer`):** Published shared network printers inside departmental OUs (`\\server\printer_share`) so employees can locate and connect to department printers directly through Active Directory.
* **Employee Onboarding & Offboarding Lifecycle:**
  * **Onboarding:** Provisioned new hires directly in their assigned department OU, added them to their department security group (e.g., `Sales_Team`), configured logon scripts/home folders, and required password change at next logon.
  * **Offboarding:** Disabled compromised or departing user accounts (`Right-click -> Disable Account`) to immediately revoke Kerberos/NTLM authentication while preserving audit history, removed security group memberships, and moved disabled accounts to a dedicated offboarding/disabled OU before deprovisioning.

*Active Directory Users and Computers (`dsa.msc`) showing the `Sales` OU containing `DESKTOP-0A...` (Computer), `Devi Shree` and `Surendra Singh` (Users), `Sales_Team` (Security Group), and the `New` object creation menu (`Computer`, `Group`, `Printer`, `User`).*

<img width="2455" height="1181" alt="image" src="https://github.com/user-attachments/assets/884cc213-83a0-42e1-9257-636433755a43" />

<img width="2397" height="1093" alt="image" src="https://github.com/user-attachments/assets/a2d2c30b-2ade-42f5-a838-fab0c927f8f2" /> 

### Step 3: Domain-Joining the Windows 11 Workstation
* **Verifying DNS & Connectivity:** Confirmed that **`Windows-11-Client`** (`Windows 11 Enterprise`) resolved **`corp.local`** directly to **`windows-server-2022`** before initiating the domain join.
* **Joining the Domain (`corp.local`):** Opened **Settings -> System -> About -> Rename this PC (advanced)** (or `sysdm.cpl`), clicked **Change**, switched membership from `WORKGROUP` to the **`corp.local`** domain, authenticated with `CORP\Administrator` credentials, and rebooted the workstation to register its computer object in Active Directory.
* **Validating Domain Logon & Kerberos Authentication:** At the Windows 11 lock screen, selected **Other user** and signed in with **`Devi Shree`** (`CORP\Devi Shree` / `Devishree@corp.local`) to verify domain authentication, profile creation, and standard user privilege boundaries.
  
  <img width="1019" height="740" alt="image" src="https://github.com/user-attachments/assets/5d43fa23-9c95-4aea-bc6f-816c8d6a16ac" />

 ### Step 4: Configuring & Linking Group Policy Objects (`gpmc.msc`)
* **Creating Custom Group Policy Objects:** Opened **Group Policy Management (`gpmc.msc`)** on **`windows-server-2022`** and configured four custom GPOs alongside the `Default Domain Policy`:
  * **`IT_Desktop_policy`:** Enforces standardized desktop configuration and workstation baseline restrictions.
  * **`Youtube_Restriction`:** Implements acceptable-use web/application access restrictions across targeted departmental OUs.
  * **`GPO_Event_Forwarding`:** Configures centralized Windows Event Forwarding and security log collection from domain endpoints.
  * **`Intune MDM Auto Enrolment`:** Prepares domain-joined workstations for zero-touch MDM enrollment (`Enable automatic MDM enrollment using default Azure AD credentials`).
* **Linking & Policy Verification:** Linked the GPOs to their respective departmental Organizational Units under **`corp.local`** and verified policy application on **`Windows-11-Client`** using `gpupdate /force` and `gpresult /r`.

*Group Policy Management (`gpmc.msc`) on `windows-server-2022` displaying the custom GPOs (`GPO_Event_Forwarding`, `Intune MDM Auto Enrolment`, `IT_Desktop_policy`, `Youtube_Restriction`) and departmental OUs under `corp.local`.*

> **Why this matters:** Linking custom Group Policy Objects to dedicated departmental OUs allows administrators to enforce granular security baselines, web restrictions, centralized logging, and automated MDM onboarding without modifying default domain containers.

<img width="2477" height="1208" alt="image" src="https://github.com/user-attachments/assets/be34d879-78e1-4d67-95ca-1a694795fbce" /> 








