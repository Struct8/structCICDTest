"""Test function for a Struct8 diagram on Google Cloud (Cloud Functions 2nd gen, HTTP).

Each call writes one JSON object to the bucket named by the DATA_BUCKET environment
variable and answers with the object's name. The function's service account needs
write access to that bucket (roles/storage.objectCreator or objectUser).

Temporary: this folder exists only for the test and is deleted afterwards.
"""

import json
import os
import uuid
from datetime import datetime, timezone

import functions_framework
from google.cloud import storage

_client = None


def _storage():
    global _client
    if _client is None:
        _client = storage.Client()
    return _client


@functions_framework.http
def handler(request):
    bucket_name = os.environ.get("DATA_BUCKET", "").strip()
    if not bucket_name:
        return _reply(500, {"error": "DATA_BUCKET is not set on the function."})

    now = datetime.now(timezone.utc)
    record = {
        "received_at": now.isoformat(),
        "method": request.method,
        "path": request.path,
        "query": request.args.to_dict(),
        "body": request.get_json(silent=True),
        "function": os.environ.get("K_SERVICE", "local"),
    }
    name = f"events/{now:%Y/%m/%d}/{now:%H%M%S}-{uuid.uuid4().hex[:8]}.json"

    try:
        blob = _storage().bucket(bucket_name).blob(name)
        blob.upload_from_string(json.dumps(record, indent=2), content_type="application/json")
    except Exception as exc:  # the caller sees why the write failed (permission, bucket name)
        return _reply(502, {"error": f"{type(exc).__name__}: {exc}", "bucket": bucket_name})

    return _reply(200, {"bucket": bucket_name, "object": name, "record": record})


def _reply(status, payload):
    return json.dumps(payload, indent=2), status, {"Content-Type": "application/json"}
