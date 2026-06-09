FROM ghcr.io/gdmkonsult/awx-ee:new

USER root

# Add ALPN fix for Windows Server 2025 WinRM compatibility
RUN mkdir -p /runner/python_patch
COPY sitecustomize.py /runner/python_patch/

# Keep ansible-runner worker stream identical to the base EE. Apply the ALPN
# patch only when ansible-playbook runs, so worker stdout remains clean JSON.
RUN mv /usr/local/bin/ansible-playbook /usr/local/bin/ansible-playbook.real && \
		printf '%s\n' \
			'#!/bin/sh' \
			'export PYTHONPATH="/runner/python_patch${PYTHONPATH:+:$PYTHONPATH}"' \
			'exec /usr/local/bin/ansible-playbook.real "$@"' \
			> /usr/local/bin/ansible-playbook && \
		chmod +x /usr/local/bin/ansible-playbook

USER 1000
