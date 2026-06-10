# AWX Execution Environment - WinRM Compatible

Custom AWX Execution Environment with ALPN fix for Windows Server 2025 WinRM compatibility.

## Problem
Windows Server 2025 WinRM over HTTPS (port 5986) does not support ALPN (Application-Layer Protocol Negotiation). Modern Python 3.11+ with urllib3 2.x automatically sends ALPN in TLS handshake, causing "Connection reset by peer" errors when connecting via IP address.

## Solution
This EE keeps the base AWX image unchanged and adds one Python startup patch through `sitecustomize.py` in Python 3.12 site-packages. The patch suppresses urllib3's default `http/1.1` ALPN offer while leaving other `set_alpn_protocols` calls untouched.

## Features
- Based on `ghcr.io/gdmkonsult/awx-ee:new` by default
- Includes all features from base image
- **urllib3 HTTP/1.1 ALPN disabled** for Windows WinRM compatibility
- Works with both hostname and IP address connections for Temp Staging environment. 
- Supports HTTPS WinRM on port 5986

## Usage

### In AWX
1. Go to AWX WebUI → **Administration** → **Execution Environments**
2. Add new EE using an immutable tag, for example `ghcr.io/gdmkonsult/awx-ee-winrm:sha-<commit>`
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
- On every build → `ghcr.io/gdmkonsult/awx-ee-winrm:sha-<commit>`
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
1. The Dockerfile starts from `ghcr.io/gdmkonsult/awx-ee:new` by default
2. `sitecustomize.py` is copied to `/usr/local/lib/python3.12/site-packages/sitecustomize.py`
3. Python loads `sitecustomize.py` during interpreter startup
4. The module wraps `ssl.SSLContext.set_alpn_protocols`
5. urllib3's `['http/1.1']` ALPN offer is skipped
6. Windows WinRM accepts the TLS handshake

The image does not modify `/usr/local/bin/ansible-playbook` or the ansible-runner worker entrypoint.

For reproducible debugging, build with a pinned base image digest:

```bash
docker build \
  --build-arg BASE_IMAGE=ghcr.io/gdmkonsult/awx-ee:new@sha256:3d079a87f50dd8184c83d2427865cbd04a4617572839428bee3861bb96235836 \
  -t ghcr.io/gdmkonsult/awx-ee-winrm:noalpn-test .
```

## License
Same as base AWX EE image.
Repo containing AWX Execution environment with no APLN fix for WinRM compability. 
