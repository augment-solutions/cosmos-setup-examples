# Cosmos E2E Video Recording — Reusable GitHub Action

Records a [Playwright](https://playwright.dev/) E2E test as a video, uploads it to a cloud storage bucket, and posts an inline preview comment on the pull request — all as a single reusable `workflow_call`.

## What it does

1. **Checks out** the repo, installs Node + Playwright + app dependencies.
2. **Starts** a dev server, runs the Playwright test suite with video recording enabled.
3. **Uploads** the `.webm` recording (plus an animated GIF or static thumbnail preview) to a Google Cloud Storage bucket.
4. **Verifies** the uploaded video is publicly accessible.
5. **Posts or updates** a PR comment with the preview image linked to the full recording.

> **Storage note:** This example uses GCS with `gsutil`, but the upload logic is compatible with any S3-compatible object store (AWS S3, MinIO, Cloudflare R2, Backblaze B2). See the inline comments in the workflow for adaptation instructions.

## Prerequisites

| Requirement | Details |
|---|---|
| **GCS bucket** | A publicly-readable bucket. One-time setup: `gsutil mb -p [INSERT_YOUR_GCP_PROJECT_ID] -l [INSERT_YOUR_GCP_REGION] gs://[INSERT_YOUR_STORAGE_BUCKET]` then `gsutil iam ch allUsers:objectViewer gs://[INSERT_YOUR_STORAGE_BUCKET]` |
| **Service account key** | A GCP service account JSON key with `roles/storage.objectCreator` on the bucket, stored as the GitHub secret `GCS_SA_KEY` |
| **Playwright config** | Your Playwright config must enable video recording (e.g., `use: { video: 'on' }`) |

## Quick start

### 1. Copy the reusable workflow

Copy [`cosmos-video-recording-e2e.yml`](./cosmos-video-recording-e2e.yml) into your repository at:

```
.github/workflows/cosmos-video-recording-e2e.yml
```

### 2. Create a caller workflow

Create a workflow that invokes the reusable workflow on pull request events:

```yaml
# .github/workflows/e2e-video.yml
name: E2E Video Recording

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  record:
    uses: ./.github/workflows/cosmos-video-recording-e2e.yml
    with:
      pr_number: ${{ github.event.pull_request.number }}
      app_working_directory: "[INSERT_YOUR_APP_DIRECTORY]"   # e.g., "." or "frontend"
      app_start_command: "npm run dev"                        # adjust to your start script
      app_url: "http://localhost:3000"                        # adjust to your dev server port
      test_working_directory: "[INSERT_YOUR_TEST_DIRECTORY]" # e.g., "tests/e2e"
      playwright_config: "playwright.config.ts"
      video_output_directory: "test-results"                  # Playwright video output dir
      gcs_bucket: "[INSERT_YOUR_STORAGE_BUCKET]"             # e.g., "my-project-e2e-artifacts"
      gcs_object_prefix: "e2e-videos"
    secrets:
      GCS_SA_KEY: ${{ secrets.GCS_SA_KEY }}
```

### 3. Configure your Playwright tests

Make sure your Playwright config enables video recording:

```ts
// playwright.config.ts
export default defineConfig({
  use: {
    video: 'on',
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
  },
  outputDir: 'test-results',
});
```

## Inputs reference

| Input | Required | Default | Description |
|---|---|---|---|
| `pr_number` | ✅ | — | PR number to comment on |
| `app_working_directory` | ✅ | — | Path to the application directory |
| `app_start_command` | | `npm run dev` | Command to start the dev server |
| `app_url` | | `http://localhost:3000` | Dev server URL |
| `test_working_directory` | | `.` | Path to E2E test directory |
| `playwright_config` | | `playwright.config.ts` | Playwright config file |
| `video_output_directory` | | `test-results` | Where Playwright writes videos |
| `gcs_bucket` | ✅ | — | GCS bucket name |
| `gcs_object_prefix` | | `e2e-videos` | Object path prefix in the bucket |
| `node_version` | | `20` | Node.js version |
| `comment_marker` | | `<!-- cosmos-e2e-video -->` | HTML marker for idempotent comments |
| `comment_heading` | | `🎬 E2E Recording — verification` | PR comment heading |

## Secrets

| Secret | Required | Description |
|---|---|---|
| `GCS_SA_KEY` | ✅ | GCP service account JSON key with write access to the bucket |

## How the PR comment works

The workflow posts (or updates) a single PR comment containing:

- An **inline preview** (animated GIF or static thumbnail) linked to the full `.webm` recording
- **Playback checks** confirming public accessibility
- A **footer** with the commit SHA and workflow run ID

On subsequent pushes to the same PR, the existing comment is updated in place rather than creating a new one (matched by the `comment_marker` HTML comment).

## Adapting for other storage providers

The workflow uses GCS, but the pattern is portable. To use **AWS S3**, for example:

1. Replace `google-github-actions/auth@v2` → `aws-actions/configure-aws-credentials@v4`
2. Replace `google-github-actions/setup-gcloud@v2` → remove (AWS CLI is preinstalled)
3. Replace `gsutil cp` → `aws s3 cp`
4. Update the public URL from `https://storage.googleapis.com/BUCKET/OBJECT` to your S3 URL pattern

See the inline comments in the workflow YAML for detailed guidance.
