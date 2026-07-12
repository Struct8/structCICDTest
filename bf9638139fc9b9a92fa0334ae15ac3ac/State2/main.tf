terraform {
  required_version = ">= 1.0.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.21.1"
    }
  }

  backend "s3" {
    bucket  = "pro112-teste-cicd"
    key     = "bf9638139fc9b9a92fa0334ae15ac3ac/State2/main.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

# --- Main Cloud Provider ---
provider "cloudflare" {}

### CATEGORY: MISC ###

resource "cloudflare_r2_bucket" "diagram_backup" {
  account_id                        = "bf9638139fc9b9a92fa0334ae15ac3ac"
  name                              = "diagram-backup"
}

resource "cloudflare_workers_script" "cloudman_collab" {
  account_id                        = "bf9638139fc9b9a92fa0334ae15ac3ac"
  script_name                       = "cloudman-collab"
  compatibility_date                = "2024-09-23"
  compatibility_flags               = ["nodejs_compat"]
  content                           = "export default { async fetch() { return new Response(\"ok\"); } }"
  main_module                       = "index.js"
  usage_model                       = "bundled"
  bindings                          = [
    {
      bucket_name = cloudflare_r2_bucket.diagram_backup.name
      name = "DIAGRAM_BACKUP"
      type = "r2_bucket"
    }
  ]
  observability                     = {
    enabled = true
    logs = {
      enabled = true
      invocation_logs = false
    }
  }
  placement                         = {
    mode = "smart"
  }
}


