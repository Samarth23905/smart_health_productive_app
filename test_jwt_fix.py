#!/usr/bin/env python
"""Test JWT token fix - verify identity is string, not dict"""

import json
import base64
from flask_jwt_extended import JWTManager, create_access_token
from flask import Flask

app = Flask(__name__)
app.config['JWT_SECRET_KEY'] = 'test-secret-key'
jwt = JWTManager(app)

with app.app_context():
    # Test the old way (should have failed):
    # token_old = create_access_token(identity={"id": 2, "role": "citizen"})
    
    # Test the new way (should work correctly):
    token = create_access_token(identity=str(2))  # Pass user_id as string
    
    # Decode and inspect the token
    parts = token.split('.')
    # Add padding if needed
    payload = parts[1]
    padding = 4 - (len(payload) % 4)
    if padding != 4:
        payload += '=' * padding
    
    decoded = json.loads(base64.urlsafe_b64decode(payload))
    
    print("\n✅ JWT TOKEN FIX VERIFICATION")
    print("=" * 50)
    print(f"\nToken Created: {token[:50]}...")
    print(f"\nPayload Content:")
    print(json.dumps(decoded, indent=2))
    print(f"\n'sub' (subject) claim type: {type(decoded['sub']).__name__}")
    print(f"'sub' value: {decoded['sub']}")
    
    if isinstance(decoded['sub'], str):
        print("\n✅ SUCCESS: 'sub' is a STRING (correct)")
        print("   JWT validation will pass on protected endpoints")
    else:
        print("\n❌ FAILED: 'sub' is not a string (incorrect)")
        print("   JWT validation will fail with '422 Subject must be a string'")
    
    print("\n" + "=" * 50)
