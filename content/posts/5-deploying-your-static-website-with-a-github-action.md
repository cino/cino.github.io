+++
author = "Ricardo Cino"
title = "Deploying your static website with a Github Action"
slug = "deploying-your-static-website"
date = "2022-02-18"
+++
Authenticate GitHub with OpenID Connect to deploy your CDK project to your AWS Organization

After making an AWS CDK project one of the first thing you will realize is that you don't want to keep running cdk deploy to update your production environment. This is a fine way of working when you modify your personal dev environment as it is a quick way of deploying but definitely not for your staging/production environments.

<!--more-->

To deploy to these types of environments you should be using some kind of a ci/cd setup. There are lots of different tools you can choose from like <a href="https://aws.amazon.com/codedeploy/" target="_blank">AWS CodeDeploy,</a> <a href="https://docs.gitlab.com/ee/ci/pipelines/" target="_blank">GitLab Pipelines</a>, Jenkins (don't), or my absolute favorite at this moment <a href="https://github.com/features/actions" target="_blank">Github Actions</a>.

When you think about how the deployment should work it's actually quite simple. The only thing that should happen is that the commands you're running by yourself should be run by an automated process. However, this is where we find our biggest problem: we are not authenticated in our GitHub Action (for now).

## How to authenticate the GitHub Action?

There is more than a single way to authenticate your GitHub action to manage your AWS resources, however, there is only one that is actually recommended by AWS. This is the OpenID Connect authentication method. When using this we authenticate GitHub to assume a role within an organization, when GitHub is authorized to do so it will request temporary credentials which can be used to execute command-line executions like the CDK.

The other option would be to generate long-loving access keys and store these in your repositories secrets, this is not the way you want to go and I'm not sure why I'm even telling this.

**💡 Avoid using Long-living-access keys completely, you don't want to deal with refreshing these keys in the long run.**

## Setting op Github OpenID Connect with AWS.

Before we can make our GitHub Action which executes our deployment we will need to allow GitHub to our AWS Organization. This can be done by setting up an Identity Provider for GitHub within the IAM settings.

There is an excellent guide on how to configure the OpenID Identity Provider in the <a href="https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services" target="_blank">GitHub documentation</a>. This includes all the information you should need to configure it correctly and make it work.

As shown in my earlier post about the <a href="/posts/static-website-distribution-with-aws-cloudfront/">static website</a> I find it important to have all my infrastructure as code, that's why I'll show how I've configured the OpenID Connect Provider in a CDK Stack.

For starters, we would need to make an OpenID Connect Provider in AWS, this can be done with the IAM library of the CDK. As mentioned on the GitHub documentation you need to configure the URL and the "Audience", when using the CDK you'll see there is no "Audience" property to configure. This is because this has been named "clientIds" and works the exact same.

Finally, we create an OpenIDConnectPrincipal which will allow GitHub to communicate with our AWS.

{{< highlight typescript >}}
const gitHubProvider = new iam.OpenIdConnectProvider(this, 'GithubProvider', {
  url: 'https://token.actions.githubusercontent.com',
  clientIds: ['sts.amazonaws.com'],
  thumbprints: [
    '6938fd4d98bab03faadb97b34396831e3780aea1',
  ]
});
const gitHubPrincipal = new iam.OpenIdConnectPrincipal(gitHubProvider);
{{< / highlight >}}

The thumbprint is the latest according to this <a href="https://github.blog/changelog/2022-01-13-github-actions-update-on-oidc-based-deployments-to-aws/">GitHub blog</a> post.

Next up, we are going to define what roles GitHub can use, this is an important step as you want to explicitly tell when GitHub should be allowed to assume the given role.

Here we create a new role that includes an important condition, here we only allow GitHub to assume this role when the repository is my specific repository and even only from a specific branch. If you don't set this up correctly it could be possible someone else could enter your account.

{{< highlight typescript >}}
const deploymentRole = new iam.Role(this, "DeploymentRole", {
  assumedBy: new iam.WebIdentityPrincipal(
    gitHubProvider.openIdConnectProviderArn,
    {
      StringLike: {
        "token.actions.githubusercontent.com:sub":
          `repo:cino/cdk-static-serverless:ref:refs/heads/main`
      }
    }
  ),
  managedPolicies: [
    iam.ManagedPolicy.fromAwsManagedPolicyName("AdministratorAccess"),
  ]
});
{{< / highlight >}}

Here you can see that we allow the OpenIdConnectProvider to assume the created role, and for this example, I've given the role the AdministratorAccess role.

**💡 Don't give any role AdministratorAccess in production, this is only for the given example. You should create your own policy and specify exactly what you need to be able to accomplish.**

## Creating the Github Action to execute the deploy

Now we have authenticated GitHub and can actually execute actions within our AWS account we can go ahead and create a GitHub action to deploy our existing Stack. For this, I've updated the existing <a href="https://github.com/cino/cdk-static-serverless">Static Website</a> repository that I created during the previous blog post and made the action run. The complete action can be found at <a hreef="https://github.com/cino/cdk-static-serverless/blob/main/.github/workflows/deploy.yml">this location</a>.

We are lucky enough that the authentication part of our GitHub action has completely been automated by AWS and we simply need to use an existing GitHub action. This is the <a herf="https://github.com/aws-actions/configure-aws-credentials">aws-actions/configure-aws-credentials</a> action that can authenticate your action in multiple ways.

In our Action, we need to add the following part right after checking out our code and everything after this action will be authenticated to perform actions in the AWS Organization. As you can see we specify which role you want to assume and this needs to be the ARN of the created role.

{{< highlight yaml >}}

- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v1
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
    aws-region: eu-central-1
{{< / highlight >}}

Now we are authenticated we can do anything necessary to update our stack, for the given example I've kept it as simple as possible to make it work by just setting up Node with the managed action from GitHub.

{{< highlight yaml >}}

- name: Setup Node
  uses: actions/setup-node@v2
  with:
    node-version: 14
{{< / highlight >}}

This will install node and npm in our action which we will need to install the dependencies which will be the next step.

{{< highlight yaml >}}- name: Install dependencies
  run: npm ci

- name: Deploy to CloudFront/S3
  run: npx cdk deploy --require-approval never

{{< / highlight >}}

These are the last 2 steps of our action, first, our npm dependencies are installed by running `npm ci`, and second, we will run the `cdk deploy` command by prefixing this with npx. Npx will download the CDK library and add it to our path so we can use the executable.

## That's a wrap

When all this has been set up you should be able to deploy the CDK project right into your AWS account while using a correct authentication method, without keys that you need to replace every x months. To see the results you can see the output of <a href="https://github.com/cino/cdk-static-serverless/runs/5272810000?check_suite_focus=true">this workflow</a> that is.
