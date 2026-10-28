# gcp-function-test

Temporary code for testing a Struct8 diagram on Google Cloud. Delete this folder after the test.

- `function/`: an HTTP Cloud Function (2nd gen, Python 3.12, entry point `handler`). Each call
  writes one JSON object under `events/` in the bucket named by the `DATA_BUCKET` environment
  variable and returns the object's name.
- `site/`: static files published to a bucket by a bucket object component.

The workflow of this repository runs only on `manifest.json` pushes, so this folder triggers nothing.
