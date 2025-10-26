# Set CORS for Firebase Storage using Google Cloud Shell

## Steps:

### 1. Open Google Cloud Shell
Go to: https://console.cloud.google.com/?project=app-dev-4768b

Click the **Cloud Shell** icon in the top right (looks like `>_`)

### 2. Create the CORS configuration file

In the Cloud Shell terminal, run:

```bash
cat > cors.json << 'EOF'
[
  {
    "origin": ["*"],
    "method": ["GET", "HEAD", "OPTIONS"],
    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin", "Range"],
    "maxAgeSeconds": 3600
  }
]
EOF
```

### 3. Apply CORS to your Firebase Storage bucket

```bash
gsutil cors set cors.json gs://app-dev-4768b.firebasestorage.app
```

### 4. Verify CORS was set correctly

```bash
gsutil cors get gs://app-dev-4768b.firebasestorage.app
```

This should display your CORS configuration.

### 5. Done!

Close Cloud Shell and refresh your Flutter app. The 3D model should now load! 🎉

---

## Alternative: One-line command

If you prefer a single command, run this in Cloud Shell:

```bash
echo '[{"origin":["*"],"method":["GET","HEAD","OPTIONS"],"responseHeader":["Content-Type","Access-Control-Allow-Origin","Range"],"maxAgeSeconds":3600}]' | gsutil cors set /dev/stdin gs://app-dev-4768b.firebasestorage.app
```

---

## Troubleshooting

If you get a permissions error, make sure you're logged into the correct Google account that has access to the Firebase project.

```bash
gcloud auth login
gcloud config set project app-dev-4768b
```

Then try the cors set command again.
