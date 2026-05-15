# Azure DevOps Webhook Setup

This guide describes how to set up an Azure DevOps (ADO) service hook that delivers events to Cosmos to trigger Experts.

## 1. Create the Webhook in Cosmos

Create the webhook in the Cosmos UI at https://app.augmentcode.com/app/webhooks:

1. Click **Create webhook**.
2. Enter a description and click **Create**.

After creation, Cosmos displays the webhook details, for example:

```
Bearer Token
<bearer_token>

Usage Example
curl -X POST https://augmentdemo.api.augmentcode.com/webhooks/<some_uuid> \
  -H "Authorization: Bearer <bearer_token>" \
  -H "Content-Type: application/json" \
  -d '{"event": "test", "data": "your payload here"}'
```

Copy the **Webhook URL** and **Bearer token** before closing the page — the token cannot be retrieved again.

## 2. Add the Webhook in Azure DevOps

Azure DevOps does not have a native "secret token" field for web hook subscriptions. Instead, authentication to Cosmos is performed by adding the Bearer token as a custom HTTP header on the service hook subscription.

1. In Azure DevOps, open your project and go to **Project settings → Service hooks**.
2. Click **+ Create subscription**.
3. Select **Web Hooks** as the service, then click **Next**.
4. Choose the **Trigger on this type of event** you want to send to Cosmos, for example:
   - **Pull request created**
   - **Pull request updated**
   - **Pull request commented on**
   - **Pull request merge attempted**
   - **Code pushed**

   Create a separate subscription per event type — Azure DevOps only allows one event type per subscription. Configure any filters (repository, branch, etc.) you want to scope the subscription to, then click **Next**.
5. On the **Action** step, fill in the form:
   - **URL:** the **Webhook URL** returned by Cosmos (e.g. `https://augmentdemo.api.augmentcode.com/webhooks/<some_uuid>`).
   - **Basic authentication username / password:** leave both empty.
   - **HTTP headers:** add the Bearer token here as a custom header. Enter exactly:
     ```
     Authorization: Bearer <bearer_token>
     ```
     Replace `<bearer_token>` with the token returned by Cosmos. This is how Cosmos authenticates the incoming request.
   - **Resource details to send / Messages to send / Detailed messages to send:** keep the defaults (**All**).
6. Click **Test** to send a sample payload to Cosmos and confirm a `2xx` response. Optionally verify the delivery on the Cosmos side via https://app.augmentcode.com/app/events.
7. Click **Finish** to save the subscription.

Repeat steps 2–7 for each additional event type you want to forward to Cosmos.
