# Bitbucket Webhook Setup

This guide describes how to set up a Bitbucket webhook that delivers events to Cosmos.

## 1. Create the Webhook in Cosmos

Create the webhook using the `auggie` CLI:

```bash
auggie cloud webhook create --type bitbucket --description <webhook_name>
```

The command returns the webhook details, for example:

```
Created webhook: <some_uuid>
Type: bitbucket
URL: https://augmentdemo.api.augmentcode.com/webhooks/<some_uuid>
Secret: <some_secret>
Save this secret now. It cannot be retrieved again.
Setup fields:
Webhook URL: https://augmentdemo.api.augmentcode.com/webhooks/<some_uuid>
Signing secret: <secret>
Content type: application/json
Authentication header: X-Hub-Signature: sha256=<hex HMAC>
```

Copy the **Webhook URL** and **Signing secret** before closing the terminal — the secret cannot be retrieved again.

## 2. Add the Webhook in Bitbucket

In Bitbucket Cloud, webhooks are configured per repository or at the workspace level for events across multiple repos. Pick one.

### A. Repository-level webhook

1. Go to your workspace in Bitbucket Cloud.
2. Click on the elipsis (...) next to the repository name and select **Settings**
3. In the left sidebar, click on **Workflow** > **Webhooks**.
3. Click **Add webhook**.
4. Fill in the form:
   - **Title:** a descriptive name, e.g. `Augment Cosmos`.
   - **URL:** the **Webhook URL** returned by `auggie` (e.g. `https://augmentdemo.api.augmentcode.com/webhooks/<some_uuid>`).
   - **Status:** keep **Active** checked.
   - **Secret:** paste the **Signing secret** returned by `auggie`. Bitbucket uses this secret to sign deliveries with `X-Hub-Signature: sha256=<hex HMAC>` using HMAC-SHA256 over the request body.
   - **SSL / TLS:** leave **Skip certificate verification** unchecked.
   - **Triggers:** check whichever events you want to be send to Cosmos. Typically, you want at least **Created** & **Updated** under **Pull Requests**.
   - Under **Triggers**, select the events that should invoke Cosmos workflows. Common choices:
     - **Repository:** `push`
     - **Pull request:** `created`, `updated`, `approved`, `changes request created`, `merged`, `declined`, `comment created`, `comment updated`
5. Click **Save**.

### B. Workspace-level webhook

Presently, it is not possible to create Webhooks on the workspace level using the Bitbucket Cloud UI. The UI option is currently only available on the repository level.

To create Webhooks on the workspace level, utilize the Bitbucket Cloud REST API as followed:

```bash
curl --request POST \
  --url 'https://api.bitbucket.org/2.0/workspaces/{workspace}/hooks' \
  --header 'Authorization: Bearer <access_token>' \
  --header 'Accept: application/json'
  -d '
    {
      "description": "<webhook_name>",
      "url": "<webhook_url>",
      "active": true,
      "secret": "<copy+paste_cosmos_signed_secret>",
      "events": [
        "repo:push",
        "pullrequest:created",
        "pullrequest:updated",
        "pullrequest:approved",
        "pullrequest:changes_request_created",
        "pullrequest:merged",
        "pullrequest:declined",
        "pullrequest:updated",
        "pullrequest:comment_created",
        "pullrequest:comment_updated"
      ]
    }'
```

Note that you need to create an access token in Bitbucket Cloud to authenticate with the API. The token needs to have `read:webhook:bitbucket` & `write:webhook:bitbucket` scope. For instructions on how to create an access token in Bitbucket, see https://github.com/augment-solutions/cosmos-setup-examples/tree/main/environments.

For a full list of available events, see the [Bitbucket documentation on Event payloads](https://support.atlassian.com/bitbucket-cloud/docs/event-payloads). And see also [Bitbucket documentation on How to create workspace-level Webhooks](https://support.atlassian.com/bitbucket-cloud/kb/how-to-create-workspace-level-webhooks/) and [Bitbucket documentation on Create a webhook for a workspace](https://developer.atlassian.com/cloud/bitbucket/rest/api-group-workspaces/#api-workspaces-workspace-hooks-post).

## 3. Test the Webhook

1. In the webhook list, click **View requests** next to the new webhook (requires **Request History Collection** to be enabled).
2. Trigger a matching event in the repository (for example, push a commit or open a pull request).
3. Confirm Bitbucket reports a `2xx` response from the Cosmos URL.
4. Optionally verify the delivery on the Cosmos side via https://app.augmentcode.com/app/webhooks or:
   ```bash
   auggie cloud webhook list
   ```
