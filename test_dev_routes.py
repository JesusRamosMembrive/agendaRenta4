#!/usr/bin/env python3
"""
Test script for Dev routes - validates that all routes are registered correctly
"""

import requests

BASE_URL = "http://localhost:5000"


def test_routes():
    """Test that dev routes are accessible (will redirect to login)"""

    routes_to_test = [
        ("/dev/cleanup", "GET", "Cleanup Page"),
        ("/dev/stats", "GET", "Stats Page"),
    ]

    print("=" * 60)
    print("Testing Dev Routes")
    print("=" * 60)

    for route, method, description in routes_to_test:
        url = f"{BASE_URL}{route}"
        try:
            if method == "GET":
                response = requests.get(url, allow_redirects=False)

            # Check if it redirects to login (302) - this means route exists
            if response.status_code == 302:
                redirect_location = response.headers.get("Location", "")
                if "/login" in redirect_location:
                    print(f"✅ {description}: Route exists and requires login")
                    print(f"   {method} {route} -> 302 (redirect to login)")
                else:
                    print(f"⚠️  {description}: Unexpected redirect")
                    print(
                        f"   {method} {route} -> {response.status_code} -> {redirect_location}"
                    )
            elif response.status_code == 404:
                print(f"❌ {description}: Route not found")
                print(f"   {method} {route} -> 404")
            else:
                print(f"ℹ️  {description}: Unexpected status")
                print(f"   {method} {route} -> {response.status_code}")

        except Exception as e:
            print(f"❌ {description}: Error - {str(e)}")

    print("=" * 60)


if __name__ == "__main__":
    test_routes()
