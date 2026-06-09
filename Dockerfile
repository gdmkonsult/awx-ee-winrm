FROM ghcr.io/gdmkonsult/awx-ee:new

USER root

# Match AWX 24.6 worker stream expectations. Newer ansible-runner emitted
# worker-stream output that AWX/Receptor failed to parse as JSON.
RUN python3.12 -m pip install --no-cache-dir ansible-runner==2.4.1

# Add ALPN fix for Windows Server 2025 WinRM compatibility
RUN mkdir -p /runner/python_patch
COPY sitecustomize.py /runner/python_patch/
ENV PYTHONPATH=/runner/python_patch:${PYTHONPATH}

# Install nutanix.ncp collection (missing from base image)
RUN ansible-galaxy collection install nutanix.ncp -p /usr/share/ansible/collections

USER 1000
