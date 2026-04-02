
from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()

supabase_url = "https://lynzclilcsykpakjezuv.supabase.co"
supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5bnpjbGlsY3N5a3Bha2plenV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE5MjgxMzUsImV4cCI6MjA4NzUwNDEzNX0.DmjpHqrSu4WffjYCO2O-yK7sJMHonqkAC5g1Z9quQm4"
supabase = create_client(supabase_url, supabase_key)

try:
    res = supabase.table("users").select("*").limit(5).execute()
    print("Users table content:", res.data)
except Exception as e:
    print("Error checking users table:", e)

try:
    res = supabase.table("backup_lost_and_found").select("user_id").limit(5).execute()
    print("Lost and Found user_ids:", res.data)
except Exception as e:
    print("Error checking L&F table:", e)
