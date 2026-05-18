@echo off
echo Deploying Panic Button Frontend to Cloud Run...

call gcloud config set project kelas-if-b-kelompok-16
call gcloud run deploy panic-button-frontend ^
  --source . ^
  --allow-unauthenticated ^
  --region us-central1