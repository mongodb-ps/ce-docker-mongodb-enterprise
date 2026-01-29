"""Call Ops Manager API with digest authentication."""
import requests
from requests.auth import HTTPDigestAuth

HEADERS = {
    "Content-Type": "application/json",
    "Accept": "application/json",
}

def api_post(url, public_key, private_key, data, headers=None):
    """Make an API POST request to the given URL with digest authentication."""
    resp = requests.post(
        url,
        auth=HTTPDigestAuth(public_key, private_key),
        json=data,
        headers=headers or HEADERS,
        timeout=10
    )
    return resp

def api_put(url, public_key, private_key, data, headers=None):
    """Make an API PUT request to the given URL with digest authentication."""
    
    resp = requests.put(
        url,
        auth=HTTPDigestAuth(public_key, private_key),
        json=data,
        headers=headers or HEADERS,
        timeout=10
    )
    return resp

def api_delete(url, public_key, private_key, data, headers=None):
    """Make an API DELETE request to the given URL with digest authentication."""
    resp = requests.delete(
        url,
        auth=HTTPDigestAuth(public_key, private_key),
        json=data,
        headers=headers or HEADERS,
        timeout=10
    )
    return resp

def api_get(url, public_key, private_key, data, headers=None):
    """Make an API GET request to the given URL with digest authentication."""
    resp = requests.get(
        url,
        auth=HTTPDigestAuth(public_key, private_key),
        params=data,
        headers=headers or HEADERS,
        timeout=10,
    )
    return resp