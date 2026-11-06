resource "aws_s3_bucket" "site-assets" {
  bucket              = "site-web-952133486861-us-west-2-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name           = "site-assets"
    State          = "static-site-full-stack"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket" "site-uploads" {
  bucket              = "s3-presign-uploads-952133486861-us-west-2-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name           = "site-uploads"
    State          = "static-site-full-stack"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_cors_configuration" "site-uploads_cors" {
  bucket = aws_s3_bucket.site-uploads.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 300
  }
}

resource "aws_s3_bucket_ownership_controls" "site-assets_controls" {
  bucket = aws_s3_bucket.site-assets.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_ownership_controls" "site-uploads_controls" {
  bucket = aws_s3_bucket.site-uploads.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_site-assets_st_static-site-full-stack_doc" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site-assets.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.site-cdn.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_site-assets_st_static-site-full-stack" {
  bucket = aws_s3_bucket.site-assets.id
  policy = data.aws_iam_policy_document.aws_s3_bucket_policy_site-assets_st_static-site-full-stack_doc.json
}

resource "aws_s3_bucket_public_access_block" "site-assets_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.site-assets.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "site-uploads_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.site-uploads.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site-assets_configuration" {
  bucket = aws_s3_bucket.site-assets.id
  rule {
    blocked_encryption_types = ["SSE-C"]
    bucket_key_enabled       = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site-uploads_configuration" {
  bucket = aws_s3_bucket.site-uploads.id
  rule {
    blocked_encryption_types = ["SSE-C"]
    bucket_key_enabled       = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "site-assets_versioning" {
  bucket = aws_s3_bucket.site-assets.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}

resource "aws_s3_bucket_versioning" "site-uploads_versioning" {
  bucket = aws_s3_bucket.site-uploads.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Enabled"
  }
}

resource "aws_s3_object" "error-html" {
  acl    = "private"
  bucket = aws_s3_bucket.site-assets.bucket
  content = <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Page not found</title>
  <style>
    body { font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif; background:#0f172a; color:#e2e8f0; min-height:100vh; display:flex; align-items:center; justify-content:center; text-align:center; padding:24px; margin:0; }
    h1 { font-size:64px; margin:0 0 8px; color:#38bdf8; }
    p { color:#94a3b8; font-size:18px; }
    a { color:#38bdf8; text-decoration:none; }
  </style>
</head>
<body>
  <div>
    <h1>404</h1>
    <p>The page you are looking for does not exist.</p>
    <p><a href="/">Back to home</a></p>
  </div>
</body>
</html>
  EOF
  content_type = "text/html"
  key          = "error.html"
  tags = {
    Name           = "error-html"
    State          = "static-site-full-stack"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "index-html" {
  acl    = "private"
  bucket = aws_s3_bucket.site-assets.bucket
  content = <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>File Upload</title>
  <style>
    :root { --bg:#0f172a; --card:#1e293b; --accent:#38bdf8; --text:#e2e8f0; --muted:#94a3b8; --success:#22c55e; --error:#ef4444; }
    * { box-sizing:border-box; margin:0; padding:0; }
    body { font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif; background:var(--bg); color:var(--text); min-height:100vh; display:flex; align-items:center; justify-content:center; padding:24px; }
    .card { background:var(--card); border-radius:16px; padding:48px 40px; max-width:640px; width:100%; box-shadow:0 20px 60px rgba(0,0,0,.4); }
    .badge { display:inline-block; background:rgba(56,189,248,.15); color:var(--accent); font-size:12px; font-weight:600; letter-spacing:.08em; text-transform:uppercase; padding:6px 12px; border-radius:999px; margin-bottom:20px; }
    h1 { font-size:32px; line-height:1.2; margin-bottom:12px; }
    p { color:var(--muted); font-size:16px; line-height:1.6; margin-bottom:24px; }
    
    .upload-area { 
      border: 2px dashed rgba(56,189,248,0.3); 
      border-radius:12px; 
      padding:40px 20px; 
      text-align:center;
      margin-bottom:20px;
      transition:all 0.3s ease;
      cursor:pointer;
    }
    .upload-area:hover { border-color:var(--accent); background:rgba(56,189,248,0.05); }
    .upload-area.dragover { border-color:var(--accent); background:rgba(56,189,248,0.1); }
    .upload-icon { font-size:48px; margin-bottom:16px; }
    
    input[type="file"] { display:none; }
    
    .file-info { background:rgba(148,163,184,0.1); padding:16px; border-radius:8px; margin-bottom:20px; display:none; }
    .file-info.show { display:block; }
    .file-name { font-weight:600; word-break:break-all; }
    .file-size { color:var(--muted); font-size:14px; }
    
    .progress { height:8px; background:rgba(148,163,184,0.2); border-radius:4px; overflow:hidden; margin-bottom:20px; display:none; }
    .progress.show { display:block; }
    .progress-bar { height:100%; background:var(--accent); transition:width 0.3s ease; width:0%; }
    
    .btn {
      background:var(--accent); color:#0f172a; border:none; padding:14px 28px; border-radius:8px;
      font-size:16px; font-weight:600; cursor:pointer; width:100%; transition:all 0.2s;
    }
    .btn:hover:not(:disabled) { filter:brightness(1.1); }
    .btn:disabled { opacity:0.5; cursor:not-allowed; }
    
    .message { padding:16px; border-radius:8px; margin-top:20px; display:none; }
    .message.show { display:block; }
    .message.success { background:rgba(34,197,94,0.15); color:var(--success); border:1px solid rgba(34,197,94,0.3); }
    .message.error { background:rgba(239,68,68,0.15); color:var(--error); border:1px solid rgba(239,68,68,0.3); }
    
    .info-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:16px; margin-top:28px; }
    .info-item { background:rgba(148,163,184,0.08); border:1px solid rgba(148,163,184,0.12); border-radius:10px; padding:16px; }
    .info-item h3 { font-size:14px; color:var(--accent); margin-bottom:6px; }
    .info-item span { font-size:13px; color:var(--muted); }
    
    footer { margin-top:28px; font-size:13px; color:var(--muted); text-align:center; }
  </style>
</head>
<body>
  <div class="card">
    <span class="badge">Online</span>
    <h1>File Upload</h1>
    <p>Select a file to upload directly to S3 using a presigned URL.</p>
    
    <div class="upload-area" id="uploadArea">
      <div class="upload-icon">📁</div>
      <p>Drag and drop a file here<br>or click to select</p>
      <input type="file" id="fileInput">
    </div>
    
    <div class="file-info" id="fileInfo">
      <div class="file-name" id="fileName"></div>
      <div class="file-size" id="fileSize"></div>
    </div>
    
    <div class="progress" id="progress">
      <div class="progress-bar" id="progressBar"></div>
    </div>
    
    <button class="btn" id="uploadBtn" disabled>Select a file</button>
    
    <div class="message" id="message"></div>
    
    <div class="info-grid">
      <div class="info-item"><h3>Storage</h3><span>Amazon S3</span></div>
      <div class="info-item"><h3>CDN</h3><span>Amazon CloudFront</span></div>
      <div class="info-item"><h3>API</h3><span>Lambda + Presigned URL</span></div>
    </div>
    
    <footer>Provisioned with Struct8 &middot; Infrastructure as code</footer>
  </div>

  <script>
    const uploadArea = document.getElementById('uploadArea');
    const fileInput = document.getElementById('fileInput');
    const fileInfo = document.getElementById('fileInfo');
    const fileName = document.getElementById('fileName');
    const fileSize = document.getElementById('fileSize');
    const uploadBtn = document.getElementById('uploadBtn');
    const progress = document.getElementById('progress');
    const progressBar = document.getElementById('progressBar');
    const message = document.getElementById('message');

    let selectedFile = null;

    // API endpoint - uses CloudFront URL with /api/prefix
    const API_URL = '/api/presign';

    // Format file size
    function formatSize(bytes) {
      if (bytes < 1024) return bytes + ' B';
      if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
      return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
    }

    // Show message
    function showMessage(text, type) {
      message.textContent = text;
      message.className = 'message show ' + type;
    }

    // Click to select file
    uploadArea.addEventListener('click', () => fileInput.click());

    // File selection via input
    fileInput.addEventListener('change', (e) => {
      if (e.target.files.length > 0) {
        handleFile(e.target.files[0]);
      }
    });

    // Drag and drop
    uploadArea.addEventListener('dragover', (e) => {
      e.preventDefault();
      uploadArea.classList.add('dragover');
    });

    uploadArea.addEventListener('dragleave', () => {
      uploadArea.classList.remove('dragover');
    });

    uploadArea.addEventListener('drop', (e) => {
      e.preventDefault();
      uploadArea.classList.remove('dragover');
      if (e.dataTransfer.files.length > 0) {
        handleFile(e.dataTransfer.files[0]);
      }
    });

    // Process selected file
    function handleFile(file) {
      selectedFile = file;
      fileName.textContent = file.name;
      fileSize.textContent = formatSize(file.size);
      fileInfo.classList.add('show');
      uploadBtn.textContent = 'Upload File';
      uploadBtn.disabled = false;
      
      // Reset states
      progress.classList.remove('show');
      progressBar.style.width = '0%';
      message.classList.remove('show');
    }

    // Upload file
    uploadBtn.addEventListener('click', async () => {
      if (!selectedFile) return;

      uploadBtn.disabled = true;
      uploadBtn.textContent = 'Getting presigned URL...';
      progress.classList.add('show');
      progressBar.style.width = '10%';

      try {
        // 1. Get presigned URL from Lambda. The object key keeps the original
        // file name, after a timestamp that keeps two uploads of the same name apart.
        let query = '?key=' + encodeURIComponent('uploads/' + Date.now() + '-' + selectedFile.name);
        if (selectedFile.type) query += '&contentType=' + encodeURIComponent(selectedFile.type);
        const response = await fetch(API_URL + query, { method: 'POST' });

        if (!response.ok) {
          throw new Error('Failed to get presigned URL');
        }

        const data = await response.json();
        const uploadUrl = data.uploadUrl;

        progressBar.style.width = '50%';
        uploadBtn.textContent = 'Uploading file...';

        // 2. Upload directly to S3 using presigned URL
        const uploadResponse = await fetch(uploadUrl, {
          method: 'PUT',
          headers: {
            'Content-Type': selectedFile.type
          },
          body: selectedFile
        });

        if (!uploadResponse.ok) {
          throw new Error('Upload failed');
        }

        progressBar.style.width = '100%';
        showMessage('✅ Upload successful! Saved as ' + data.key, 'success');

        // Clear after success
        setTimeout(() => {
          selectedFile = null;
          fileInput.value = '';
          fileInfo.classList.remove('show');
          uploadBtn.textContent = 'Select a file';
          uploadBtn.disabled = true;
        }, 2000);

      } catch (error) {
        console.error('Upload error:', error);
        showMessage('❌ Error: ' + error.message, 'error');
        uploadBtn.disabled = false;
        uploadBtn.textContent = 'Try again';
      }
    });
  </script>
</body>
</html>
  EOF
  content_type = "text/html"
  key          = "index.html"
  tags = {
    Name           = "index-html"
    State          = "static-site-full-stack"
    Struct8Creator = "rmay struct"
  }
}
