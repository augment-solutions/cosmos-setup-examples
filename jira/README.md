# Jira MCP Server Setup

Since most of our use cases are headless automations, a dedicated JIRA service account must be created.

## 1. Create a Jira Service Account

As an Atlassian admin:

1. Go to [https://admin.atlassian.com/](https://admin.atlassian.com/).
2. Navigate to **Directory > Service Account > Create a Service account**.
3. Enter the name **Augment Code**.
4. Select app **Jira** with role **User**.
5. Click **Save**.

## 2. Create API Token Credentials

1. On the newly created service account, click **Create credentials**.
2. Choose authentication type **API token**.
3. Click **Next**.
4. Pick a name and expiration date (max 1 year out).
5. Select the following scopes:

   **Read**
   - `read:jira-work`
   - `read:jira-user`
   - `read:comment:jira`
   - `read:comment.property:jira`

   **Manage** (optional)
   - `manage:servicedesk-customer`
   - `manage:jira-webhook`
   - `manage:jira-project`
   - `manage:jira-data-provider`
   - `manage:jira-configuration`

   **Write**
   - `write:jira-work`
   - `write:comment:jira`
   - `write:comment.property:jira`
   - `write:request.comment:jira-service-management`

6. Click **Next**, then **Create**.
7. Copy the API token to a safe place.

## 3. Configure the MCP Server in Augment

1. Go to **Settings > MCP Registry** ([https://app.augmentcode.com/app/mcp](https://app.augmentcode.com/app/mcp)).
2. Click **Add server**.
3. Select **Remote MCP**.
4. Configure the server with the following values:
   - **Name:** `Atlassian MCP server`
   - **Connection type:** `HTTP` (keep default)
   - **Server URL:** `https://mcp.atlassian.com/v1/mcp`
   - **Authentication type:** `Header`
   - **Header name:** `Authorization`
   - **Header value:** `Bearer YOUR_SERVICE_ACCOUNT_API_TOKEN`
5. Keep enabled products **CLI** and **Cloud Agents** selected.
6. Set **Visibility** to **shared** to make this MCP server and service account reusable by other users.
7. Click **Add Server**.

The MCP server should now appear in your MCP registry.

## 4. Test the Connectivity

1. In the left nav bar, click **+ New session**.
2. Make sure the **Atlassian MCP server** is attached to the session.
3. Enter the prompt: `lookup a given Jira ticket via its url`.
4. Click **Send**.
