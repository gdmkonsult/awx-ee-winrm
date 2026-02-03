# AWX Execution Environment - WinRM Compatible

Custom AWX Execution Environment with ALPN fix for Windows Server 2025 WinRM compatibility.

## Problem
Windows Server 2025 WinRM over HTTPS (port 5986) does not support ALPN (Application-Layer Protocol Negotiation). Modern Python 3.11+ with urllib3 2.x automatically sends ALPN in TLS handshake, causing "Connection reset by peer" errors when connecting via IP address.

## Solution
This EE disables ALPN by overriding `ssl.SSLContext.set_alpn_protocols` with a no-op function via `sitecustomize.py`, which is automatically loaded at Python startup.

## Features
- Based on `ghcr.io/gdmkonsult/awx-ee:new`
- Includes all features from base image
- **ALPN disabled** for Windows WinRM compatibility
- Works with both hostname and IP address connections for Temp Staging environment. 
- Supports HTTPS WinRM on port 5986

## Usage

### In AWX
1. Go to AWX WebUI → **Administration** → **Execution Environments**
2. Add new EE: `ghcr.io/gdmkonsult/awx-ee-winrm:latest`
3. Assign to Job Templates that target Windows hosts

### In Ansible Playbooks
```yaml
- hosts: windows_servers
  vars:
    ansible_connection: winrm
    ansible_port: 5986  # HTTPS
    ansible_winrm_transport: ntlm
    ansible_winrm_server_cert_validation: ignore
  tasks:
    - name: Test connection
      ansible.windows.win_ping:
```

## Build

Images are automatically built and pushed via GitHub Actions:
- On push to `main` → `ghcr.io/gdmkonsult/awx-ee-winrm:main` and `:latest`
- On version tags → `ghcr.io/gdmkonsult/awx-ee-winrm:v1.2.3`

### Manual Build
```bash
docker build -t ghcr.io/gdmkonsult/awx-ee-winrm:latest .
docker push ghcr.io/gdmkonsult/awx-ee-winrm:latest
```

## Testing
Verified working with:
- Windows Server 2025
- Ansible 2.15+
- Python 3.11
- urllib3 2.4.0
- pywinrm 0.5.0

## Technical Details

The fix works by:
1. `sitecustomize.py` is placed in `/runner/python_patch/`
2. `PYTHONPATH` includes this directory
3. Python automatically loads `sitecustomize.py` at startup
4. The module replaces `ssl.SSLContext.set_alpn_protocols` with a no-op function
5. urllib3 calls the method but ALPN is not sent in TLS handshake
6. Windows WinRM accepts the connection

## License
Same as base AWX EE image.
Repo containing AWX Execution environment with no APLN fix for WinRM compability. 
