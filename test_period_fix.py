#!/usr/bin/env python3
"""
Quick test to verify period parameter handling in routes
"""
import sys
from app import app

def test_period_routes():
    """Test that all routes handle period parameter correctly"""

    routes_to_test = [
        '/inicio',
        '/pendientes',
        '/problemas',
        '/realizadas'
    ]

    with app.test_client() as client:
        # First login
        response = client.post('/login', data={
            'email': 'test@example.com',
            'password': 'password'
        }, follow_redirects=False)

        print("Testing period parameter handling...\n")

        for route in routes_to_test:
            # Test with period parameter
            test_period = '2025-06'
            response = client.get(f'{route}?period={test_period}', follow_redirects=True)

            # Check if page loaded successfully
            if response.status_code == 200:
                # Check if the period appears in the response
                if test_period in response.get_data(as_text=True):
                    print(f"✅ {route}: Period parameter handled correctly")
                else:
                    print(f"⚠️  {route}: Response loaded but period not visible")
            else:
                print(f"❌ {route}: Failed with status {response.status_code}")

        print("\n✨ Test completed!")

if __name__ == '__main__':
    try:
        test_period_routes()
    except Exception as e:
        print(f"❌ Test failed: {e}")
        sys.exit(1)
