from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel
from typing import Optional, Literal
from supabase import create_client, Client
import os
from dotenv import load_dotenv

load_dotenv()

# We use the active Supabase configuration
supabase_url = os.getenv("supabase_url")
supabase_key = os.getenv("supabase_key")

supabase: Client = create_client(supabase_url, supabase_key)

router = APIRouter(prefix="/backup-lost-found", tags=["Backup Lost & Found"])

class BackupLostFoundCreate(BaseModel):
    item_name: str
    type: Literal["lost", "found"]
    location: str
    phone_number: str
    user_id: str
    status: Literal["open", "closed"] = "open"
    image_url: Optional[str] = None

@router.get("")
async def get_items(
    type: Optional[str] = Query(None),
    status: Optional[str] = Query(None),
    sort_by: Optional[str] = Query(None),
    q: Optional[str] = Query(None)
):
    try:
        query = supabase.table("backup_lost_and_found").select("*, users!backup_lost_and_found_user_id_fkey(full_name)")

        if type and type != 'all':
            query = query.eq("type", type)
            
        if status:
            query = query.eq("status", status)
            
        if q and q.strip():
            # Search logic by item name
            query = query.ilike("item_name", f"%{q.strip()}%")

        if sort_by == 'name':
            query = query.order("item_name", desc=False)
        else:
            # Default to ordering by date (newest first)
            query = query.order("created_at", desc=True)

        response = query.execute()
        return {"status": "success", "items": response.data}
    except Exception as e:
        print(f"Error fetching backup lost items: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("")
async def create_item(item: BackupLostFoundCreate):
    try:
        data = {
            "item_name": item.item_name,
            "type": item.type,
            "location": item.location,
            "phone_number": item.phone_number,
            "user_id": item.user_id,
            "status": item.status,
            "image_url": item.image_url
        }
        response = supabase.table("backup_lost_and_found").insert(data).execute()
        return {"status": "success", "item": response.data[0]}
    except Exception as e:
        print(f"Error creating backup lost item: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.patch("/{item_id}/close")
async def close_item(item_id: str):
    try:
        response = supabase.table("backup_lost_and_found")\
            .update({"status": "closed"})\
            .eq("id", item_id)\
            .execute()
        if not response.data:
            raise HTTPException(status_code=404, detail="Item not found")
        return {"status": "success", "item": response.data[0]}
    except Exception as e:
        print(f"Error closing backup lost item: {e}")
        raise HTTPException(status_code=500, detail=str(e))
