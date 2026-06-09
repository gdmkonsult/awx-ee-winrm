"""Disable ALPN for WinRM compatibility when loaded by ansible-playbook."""

import ssl


def _noop_alpn(self, protocols=None):
    return None

ssl.SSLContext.set_alpn_protocols = _noop_alpn
