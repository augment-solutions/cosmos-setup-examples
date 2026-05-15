# GitLab Webhook Setup

This guide describes how to set up a GitLab webhook that delivers events to Cosmos to trigger Experts.

## 1. Create the Webhook in Cosmos

Create the webhook using the `auggie` CLI (UI support is coming very soon):

```bash
auggie cloud webhook create --type gitlab --description <webhook_name>
```

The command returns the webhook details, for example:

```
Created webhook: <some_uuid>
Type: gitlab
URL: https://augmentdemo.api.augmentcode.com/webhooks/<some_uuid>
Secret: <some_secret>
Save this secret now. It cannot be retrieved again.
Setup fields:
Webhook URL: https://augmentdemo.api.augmentcode.com/webhooks/<some_uuid>
Secret token: <some_secret>
Content type: application/json
Authentication header: X-Gitlab-Token
```

Copy the **Webhook URL** and **Secret token** before closing the terminal — the secret cannot be retrieved again.

## 2. Add the Webhook in GitLab

1. In GitLab, open your project and go to **Settings → Webhooks**.
2. Click **Add new webhook**.
3. Fill in the form:
   - **Name:** a descriptive name, e.g. `Augment Cosmos`.
   - **URL:** the **Webhook URL** returned by `auggie` (e.g. `https://augmentdemo.api.augmentcode.com/webhooks/<some_uuid>`).
   - **Secret token:** paste the **Secret token** returned by `auggie`. GitLab sends this value in the `X-Gitlab-Token` header.
   - **Trigger:** check whichever events you want to be sent to Cosmos. Typically, you want at least **Merge request events**.
   - **SSL verification:** keep **Enable SSL verification** selected.
4. Click **Add webhook** to save changes.

## 3. Test the Webhook

1. Go back to your list of GitLab webhooks.
2. Next to the new webhook, click the **Test** dropdown and select an event (e.g. **Merge request events**).
3. Confirm GitLab reports a `2xx` response from the Cosmos URL.
4. Optionally verify the delivery on the Cosmos side via https://app.augmentcode.com/app/events or:
   ```bash
   auggie cloud webhook list
   ```
   You should see the event with source **Custom** under **Configuration → Events log**.
