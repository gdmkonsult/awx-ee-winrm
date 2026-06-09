FROM ghcr.io/gdmkonsult/awx-ee:new

USER root

# Add ALPN fix for Windows Server 2025 WinRM compatibility
RUN mkdir -p /runner/python_patch
COPY sitecustomize.py /runner/python_patch/

# Keep the original Python ansible-playbook entrypoint. Import the ALPN patch
# inside ansible-playbook only, leaving ansible-runner worker unchanged.
RUN sed -i '/^import sys$/a sys.path.insert(0, "/runner/python_patch")\nimport sitecustomize' /usr/local/bin/ansible-playbook

USER 1000
