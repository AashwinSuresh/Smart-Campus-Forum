
from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()

supabase_url = "https://lynzclilcsykpakjezuv.supabase.co"
supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5bnpjbGlsY3N5a3Bha2plenV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE5MjgxMzUsImV4cCI6MjA4NzUwNDEzNX0.DmjpHqrSu4WffjYCO2O-yK7sJMHonqkAC5g1Z9quQm4"
supabase = create_client(supabase_url, supabase_key)

try:
    print("Attempting Join Query...")
    # Try with constraint name
    res = supabase.table("backup_lost_and_found").select("*, users!backup_lost_and_found_user_id_fkey(full_name)").limit(1).execute()
    print("Join Result (with constraint):", res.data)
except Exception as e:
    print("Join Error (with constraint):", e)

try:
    print("Attempting Simple Join Query...")
    # Try without constraint name
    res = supabase.table("backup_lost_and_found").select("*, users(full_name)").limit(1).execute()
    print("Join Result (simple):", res.data)
except Exception as e:
    print("Join Error (simple):", e)

try:
    # Check what columns are actually in the users table
    res = supabase.table("users").select("*").limit(1).execute()
    if res.data:
        print("Columns in users table:", list(res.data[0].keys()))
    else:
        print("Users table is empty.")
except Exception as e:
    print("Error checking users columns:", e)
