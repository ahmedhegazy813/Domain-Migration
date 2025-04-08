# Active Directory Domain Migration Script

This PowerShell script automates the process of migrating a computer from one Active Directory domain to another. It includes optional steps such as setting a static DNS server, creating a local administrator account, and disabling other local users.

---

## 🚀 Features

- Prompts for a new computer name
- Sets static DNS to `10.50.0.17`
- Creates a new local administrator account (customizable)
- Disables all other local user accounts
- Joins the new domain (`Mednet.net`)
- Reboots the machine after successful domain join

---

## 📁 Why Place the Script in `C:\Scripts`

Placing the script in `C:\Scripts` helps standardize deployment across multiple machines. It ensures:

- Consistent execution path for automated or scripted runs
- Easier administration in enterprise environments
- Simplified troubleshooting when multiple users or technicians are involved


---

## ✏️ Before You Run the Script

Open `ADMigration.ps1` and **edit the following values manually**:

1. **Local Administrator Account**:
   - Change the username and password in the section where the script creates the local admin user.
   - .

2. **Domain Credentials**:
   - 
     - Change the Domain Admin username and password in the section where the script Desjoin and Join Domain .
     - Proper network access and DNS resolution to the domain controller.

---

## ✅ Prerequisites

- Windows machine with PowerShell
- Administrator privileges on the local machine
- Access to the old and new domain environments
- Valid domain credentials
- Connectivity to DNS and domain controllers

---

## 📂 Project Files

```
/ADMigration.ps1     # PowerShell script for migration
/README.md           # Project documentation
/LICENSE             # MIT license
```

---

## ⚙️ How to Run the Script

1. Copy all files to `C:\Scripts`
2. Open PowerShell **as Administrator**
3. Run:

   ```powershell
   cd C:\Scripts
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\ADMigration.ps1
   ```

---


---

## 🛡️ Disclaimer

This script is intended for IT professionals. Test thoroughly in a lab before deploying to production systems.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.