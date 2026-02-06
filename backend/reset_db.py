from app import app, db

with app.app_context():
    print("Dropping all tables...")
    db.drop_all()
    print("All tables dropped.")    
    print("Creating all tables...")
    db.create_all()
    print("All tables created.")
    print("Database reset successfully!")

