#!/usr/bin/env python3
"""
Deployment troubleshooting script - Run this to check for common issues
"""
import os
import sys
from pathlib import Path

def check_environment():
    """Check environment variables"""
    print("=" * 60)
    print("ENVIRONMENT VARIABLES CHECK")
    print("=" * 60)
    
    required_vars = ["DATABASE_URL", "SECRET_KEY", "JWT_SECRET_KEY"]
    
    for var in required_vars:
        value = os.getenv(var)
        if value:
            # Mask sensitive values
            if len(value) > 20:
                masked = value[:20] + "..." + value[-10:]
            else:
                masked = value
            print(f"✓ {var}: {masked}")
        else:
            print(f"✗ {var}: NOT SET - REQUIRED!")
    
    print("\n")

def check_imports():
    """Check if all required packages can be imported"""
    print("=" * 60)
    print("DEPENDENCIES CHECK")
    print("=" * 60)
    
    required_packages = [
        "flask",
        "flask_cors",
        "flask_sqlalchemy",
        "flask_jwt_extended",
        "psycopg2",
        "werkzeug",
        "dotenv"
    ]
    
    for package in required_packages:
        try:
            __import__(package)
            print(f"✓ {package}")
        except ImportError as e:
            print(f"✗ {package}: NOT INSTALLED - {e}")
    
    print("\n")

def check_database():
    """Check database connection"""
    print("=" * 60)
    print("DATABASE CONNECTION CHECK")
    print("=" * 60)
    
    try:
        from flask_sqlalchemy import SQLAlchemy
        from flask import Flask
        
        app = Flask(__name__)
        db_url = os.getenv("DATABASE_URL")
        
        if not db_url:
            print("✗ DATABASE_URL not set")
            return
        
        app.config["SQLALCHEMY_DATABASE_URI"] = db_url
        app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
        
        from models import db
        db.init_app(app)
        
        with app.app_context():
            try:
                from sqlalchemy import text
                result = db.session.execute(text("SELECT 1"))
                print("✓ Database connection successful")
            except Exception as e:
                print(f"✗ Database connection failed: {e}")
    
    except Exception as e:
        print(f"✗ Error testing database: {e}")
    
    print("\n")

def main():
    print("\n🔍 SMART HEALTH APP - DEPLOYMENT CHECKER\n")
    
    check_environment()
    check_imports()
    check_database()
    
    print("=" * 60)
    print("REMEDIES FOR COMMON ISSUES:")
    print("=" * 60)
    print("""
1. If DATABASE_URL is missing:
   - Go to Render Dashboard
   - Find your PostgreSQL database
   - Copy the Internal Database URL
   - Add to your Web Service environment variables

2. If SECRET_KEY or JWT_SECRET_KEY is missing:
   - Generate random strings: python -c "import os; print(os.urandom(24).hex())"
   - Add to Render environment variables

3. If imports are failing:
   - Make sure requirements.txt has all dependencies
   - Redeploy on Render (git push origin main)

4. If database connection fails:
   - Check if PostgreSQL service is running on Render
   - Verify the database still exists
   - Check connection string format
    """)

if __name__ == "__main__":
    main()
