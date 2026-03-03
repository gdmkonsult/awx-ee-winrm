FROM ghcr.io/gdmkonsult/awx-ee:new

USER root

# Add ALPN fix for Windows Server 2025 WinRM compatibility
RUN mkdir -p /runner/python_patch
COPY sitecustomize.py /runner/python_patch/
ENV PYTHONPATH=/runner/python_patch:${PYTHONPATH}

# Required for Nutanix capacity report chart generation
RUN python3 -m pip install --no-cache-dir matplotlib numpy

USER 1000
