import bcrypt

def hash_password(password: str) -> str:
    """Hash password menggunakan bcrypt dengan cost=12"""
    salt = bcrypt.gensalt(rounds=12)
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def main():
    print("="*70)
    print("  PASSWORD HASH GENERATOR (untuk Supabase)")
    print("="*70)
    print()
    
    # Password yang ingin di-hash
    password = "password123"
    
    # Generate hash
    password_hash = hash_password(password)
    
    print(f"Original Password: {password}")
    print(f"Hashed Password:   {password_hash}")
    print()
    print("="*70)
    print("  SQL UPDATE COMMAND")
    print("="*70)
    print()
    
    # SQL untuk update sample users
    users = [
        ("admin@pilar.com", "Admin PILAR"),
        ("user@pilar.com", "User Testing"),
        ("test@pilar.com", "Test User"),
    ]
    
    print("-- Update password hash untuk semua sample users")
    print("-- Password: password123")
    print()
    
    for email, name in users:
        print(f"UPDATE public.users")
        print(f"SET password_hash = '{password_hash}'")
        print(f"WHERE email = '{email}';")
        print()

if __name__ == "__main__":
    main()
