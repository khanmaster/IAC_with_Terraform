
## Installing terraform

You can download the binary from the following link:

https://www.terraform.io/downloads.html
When you have unzipped the binary file, there's no installer. They students should move the file to their /usr/local/bin directory and set the Path if necessary.


- **For Windows**
- Install Chocolaty

- `https://chocolatey.org/install`
-  we can also install it using chocolatey package managers
- ```Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))```

- Open power shell in Admin mode
- Paste the copied text into your shell and press Enter.
- Wait a few seconds for the command to complete.
- If you don't see any errors, you are ready to use Chocolatey! Type choco or choco -? now, or see Getting Started for usage instructions.

- Install Terraform `choco install terraform`
- Check installation `terraform --version`
- Should see below outcome if everything went well
- ```Terraform v1.0.4
on windows_amd64
+ provider registry.terraform.io/hashicorp/aws v3.53.0
```
