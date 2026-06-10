"""Disable urllib3's HTTP/1.1 ALPN offer for WinRM compatibility."""

import ssl

_original_set_alpn_protocols = ssl.SSLContext.set_alpn_protocols


def _set_alpn_protocols_without_http11(self, protocols=None):
    if protocols in (["http/1.1"], ("http/1.1",)):
        return None

    return _original_set_alpn_protocols(self, protocols)


ssl.SSLContext.set_alpn_protocols = _set_alpn_protocols_without_http11
