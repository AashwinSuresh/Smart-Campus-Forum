from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any
import os
from supabase import create_client, Client
from datetime import datetime, timezone, timedelta
from dotenv import load_dotenv

load_dotenv()

# We use the same configuration block as other community.py/main.py services
supabase_url = os.getenv("supabase_url")
supabase_key = os.getenv("supabase_key")

supabase: Client = create_client(supabase_url, supabase_key)

router = APIRouter(prefix="/harassment-reports", tags=["Harassment"])


class HarassmentReportCreate(BaseModel):
    title: str
    description: str
    incident_date: str
    location: str
    reporter_id: str

@router.get("")
async def get_reports(user_id: str):
    """Fetch all reports for a specific user"""
    try:
        response = (
            supabase.table("harassment_reports")
            .select("*, users!harassment_reports_reporter_id_fkey(full_name)")
            .eq("reporter_id", user_id)
            .order("created_at", desc=True)
            .execute()
        )
        return {"status": "success", "reports": response.data}
    except Exception as e:
        print(f"get_reports error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("")
async def create_report(report: HarassmentReportCreate):
    """Creates a new report. The UI sends the UUID of the user via reported_by which is a Foreign Key."""
    try:
        payload: Dict[str, Any] = {
            "title": report.title,
            "description": report.description,
            "incident_date": report.incident_date,
            "location": report.location,
            "reporter_id": report.reporter_id,
            "status": "pending"
        }
        response = supabase.table("harassment_reports").insert(payload).execute()
        return {"status": "success", "data": response.data}
    except Exception as e:
        print(f"create_report error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.patch("/{report_id}/cancel")
async def cancel_report(report_id: str, user_id: str):
    """Cancels a pending report manually, but only allowed for the creator after 1 month has passed"""
    try:
        # Check current report first
        resp = supabase.table("harassment_reports").select("created_at, status, reporter_id").eq("report_id", report_id).single().execute()
        if not resp.data:
            raise HTTPException(status_code=404, detail="Report not found")
            
        report = resp.data
        
        if report.get("reporter_id") != user_id:
            raise HTTPException(status_code=403, detail="You are not authorized to cancel this report")
        
        # Enforce cancellation allowed ONLY AFTER 1 month
        # Normalize timestamp since Supabase iso strings might end with Z
        dt_str = report["created_at"].replace("Z", "+00:00")
        created_at = datetime.fromisoformat(dt_str)
        
        if (datetime.now(timezone.utc) - created_at) <= timedelta(days=30):
            raise HTTPException(status_code=400, detail="Cannot manually cancel a report until 1 month has passed")

        # Update the status to cancelled and update the timestamp
        update_resp = (
            supabase.table("harassment_reports")
            .update({
                "status": "cancelled",
                "updated_at": datetime.now(timezone.utc).isoformat()
            })
            .eq("report_id", report_id)
            .execute()
        )
        return {"status": "success", "data": update_resp.data}
    except HTTPException:
        raise
    except Exception as e:
        print(f"cancel_report error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
