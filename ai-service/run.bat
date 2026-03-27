@echo off
setlocal
echo [AI] Starting YOLO FastAPI service on port 8000...
python -m uvicorn app:app --reload --port 8000
