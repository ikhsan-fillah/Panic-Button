gcloud run deploy panic-button-api ^
  --source . ^
  --region us-central1 ^
  --allow-unauthenticated ^
  --add-cloudsql-instances kelas-if-b-kelompok-16:us-central1:panic-button ^
  --set-env-vars INSTANCE_UNIX_SOCKET=/cloudsql/kelas-if-b-kelompok-16:us-central1:panic-button,DB_USER=panic_button_user,DB_PASSWORD=10-Panic-Button,DB_NAME=panic_button,JWT_SECRET=panic_button_secret_key,GCS_BUCKET_NAME=panic-button-storage,GCS_PROJECT_ID=kelas-if-b-kelompok-16