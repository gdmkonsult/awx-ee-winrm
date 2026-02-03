FROM ghcr.io/gdmkonsult/awx-ee:new

USER root

# Add ALPN fix for Windows Server 2025 WinRM compatibility
RUN mkdir -p /runner/python_patch
COPY sitecustomize.py /runner/python_patch/
ENV PYTHONPATH=/runner/python_patch:${PYTHONPATH}

USER 1000
