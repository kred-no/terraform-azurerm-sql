# README

Usage

```bash
module "sqlvm" {
  source = ""
  # ...
}

```
## WORKING NOTES


```bash
git remote add origin git@github.com:kred-no/terraform-azurerm-sql.git
```

```hcl
# Extension; for Azure Virtual Desktop (server)
{
  name      = "EntraLoginForAzureVirtualDesktop"
  publisher = "Microsoft.Azure.ActiveDirectory"
  type      = "AADLoginForWindows"
  version   = "2.2"
  settings  = <<-HEREDOC
    {
      "mdmId": "0000000a-0000-0000-c000-000000000000"
    }
    HEREDOC
  }, {
  name      = "EntraJoinPrivateForAzureVirtualDesktop"
  publisher = "Microsoft.Compute"
  type      = "CustomScriptExtension"
  version   = "1.10"
  settings  = <<-HEREDOC
    {
      "commandToExecute": "powershell.exe -Command \"New-Item -Force -Path HKLM:\\SOFTWARE\\Microsoft\\RDInfraAgent\\AADJPrivate\"; shutdown -r -t 15; exit 0"
    }
}
```

#### Resources

  * https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.compute/vm-windows-admincenter/main.bicep