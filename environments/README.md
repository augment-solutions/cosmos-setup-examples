# Auto-clone Git Repositories in Cosmos

A script to automatically clone a set of Azure DevOps, Bitbucket or GitLab repositories in a Cosmos environment. It uses a folder structure convention that enables Cosmos to automatically update the repositories on each refresh with no additional configuration.

## Instructions

First, create the necessary access tokens in Azure DevOps/Bitbucket/GitLab and add them as secrets in Cosmos. After this, create the environment, add the necessary environment variables, and run the script.

## Create access token & Cosmos Secret

An access token is needed to authenticate with Azure DevOps/Bitbucket/GitLab over HTTPS to clone the repositories.

### Azure Dev Ops: Create access token & `ADO_TOKEN` secret

Access tokens can be defined as a [Personal Access Token (PAT)](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate) on the user, or as a [Project](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows#create-a-pat-for-a-service-principal-or-managed-identity) scope. Once created, copy the token, as it will be used in the next step when creating the `ADO_TOKEN` secret in Cosmos.

When creating the token, specify the following scopes:

* Code: `Read & write`
* Pull Request Threads: `Read & write`

The Pull Request Threads scope is optional, but it's highly recommended to include it so that the token can be used by Experts that need to create pull requests and make comments to existing pull requests.

After creating the token, switch to Cosmos, and go to **Configuration > Secrets > Add Secret > Environment Variable**, and use as Name `ADO_TOKEN` and as Value copy & paste the token, and click **Create Secret**.

### Bitbucket: Create access token & `BITBUCKET_TOKEN` secret

Access tokens can be defined on [Repository](https://support.atlassian.com/bitbucket-cloud/docs/create-a-repository-access-token/), [Project](https://support.atlassian.com/bitbucket-cloud/docs/create-a-project-access-token/), or [Workspace](https://support.atlassian.com/bitbucket-cloud/docs/create-a-workspace-access-token/) level. Once created, copy the token, as it will be used in the next step when creating the `BITBUCKET_TOKEN` secret in Cosmos.

When creating the token, specify the following scopes:

* Repositories:
    * `Read`
    * `Write`
* Pull requests:
    * `Read`
    * `Write`

The Pull request scopes are optional, but it's highly recommended to include them so that the token can be used by Experts that need to create pull requests and make comments to existing pull requests.

After creating the token, switch to Cosmos, and go to **Configuration > Secrets > Add Secret > Environment Variable**, and use as Name `BITBUCKET_TOKEN` and as Value copy & paste the token, and click **Create Secret**.

### Create GitLab access token & `GITLAB_TOKEN` secret

It is recommended to use a [Service account](https://docs.gitlab.com/user/profile/service_accounts/) and create an access token for it, rather than using a group or personal access token. This way the token is not tied to a specific user or group.

To create a service account and generate an access token:

1. In GitLab, go to your **Group > Settings > Service accounts > Add service account**, and provide a name.
2. Next to the new service account, click the **3 dots > Manage access tokens > Add new token**.
3. Provide a token name.
4. Set a maximum expiration date. Keep in mind that this access token will need to be rotated on the GitLab side before it expires, and its new value will then have to be updated in the Cosmos secret manager (this is a common security best practice).
5. Select the following scopes:
    * `read_repository`
    * `write_repository`
    * `api`
6. Click **Generate token**, and copy the token, as it will be used in the next step when creating the `GITLAB_TOKEN` secret in Cosmos.

The `api` scope is optional, but it's highly recommended to include it so that the token can be used by Experts that need to create merge requests and make comments to existing merge requests.

After creating the token, switch to Cosmos, and go to **Configuration > Secrets > Add Secret > Environment Variable**, and use as Name `GITLAB_TOKEN` and as Value copy & paste the token, and click **Create Secret**.

## Create environment

Next, create a custom Cosmos environment that will clone the repositories and keep them up to date.

In Cosmos, go to **Configuration > Environments > Create Environment**, and set the following environment variables:

- `CLONE_REPOS` (in the format `<workspace_a>/<repo_x>,<workspace_b>/<repo_y>)

Then click **Customize**, and run the following command:

   ```bash
   curl -LsSf https://raw.githubusercontent.com/augment-solutions/cosmos-setup-examples/refs/heads/main/environments/install.sh | bash
   ```

This script will detect which platform token is available (if more than one is set, it will ask you to pick), and clone the repositories defined in `CLONED_REPOS` into `/workspace`.

Once you're done, hit **Save & Close**.

Finally, on the Environment page, enable the **Scheduled refresh** toggle, and don't forget to click `Update Environment`.
