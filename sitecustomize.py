"""
Site-wide customization for AWX Execution Environment.
Disables ALPN in SSL connections for Windows WinRM compatibility.

This file is automatically loaded by Python at startup when placed in site-packages.
"""

import ssl

# Disable ALPN by replacing set_alpn_protocols with no-op
# urllib3 2.x calls this method, so we can't delete it - we override it instead
def _noop_alpn(self, protocols):
    pass

ssl.SSLContext.set_alpn_protocols = _noop_alpn
