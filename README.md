# Deploying DNS Delegated Subdomains using Terraform Cloud

## Introduction

When working on an application that is running in multiple clouds, the differences in default behaviour for DNS names of resources created in those clouds becomes clearer. When working with infrastructure as code, it becomes abundantly clear you need to have a predictable way to assign your resources DNS names.

The best practice is to deploy a dedicated DNS delegated subdomain into each cloud provider that you will be using for your application.

If you have a [Terraform Enterprise](https://www.terraform.io/docs/enterprise/index.html) installation in your company, you could use exactly the same configuration and setup to deploy this example from there. The reason for this is that Terraform Enterprise is deployed using the same engine that is used within Terraform Cloud.

The original git repository for the terraform code that was created can be found here
[https://github.com/lhaig/dns-multicloud](https://github.com/lhaig/dns-multicloud)

The original blogpost that goes with this can be found

[Haigmail](https://www.haigmail.com/2019/10/08/multi-cloud-dns-delegated-sub-domain-with-terraform-and-terraform-cloud/)

and here

[Medium](https://medium.com/hashicorp-engineering/deploying-dns-delegated-subdomains-using-terraform-cloud-94be8b0009aa)

## Why This Repository
This git repository is a continuation of that inital idea, we have now changed the code to be more capable of being imported into the modulle registry for Terraform Cloud or Terraform Enterprise. 

You can read more about Terraform Enterprise here:

[https://www.terraform.io/docs/enterprise/index.html](https://www.terraform.io/docs/enterprise/index.html)

You can read more about Terraform Cloud here:

[https://www.terraform.io/docs/cloud/index.html](https://www.terraform.io/docs/cloud/index.html)

## Use this repository as a module

If you want to use the repository as a module you can use the [v0.3.0](https://github.com/lhaig/terraform-dns-multicloud/tree/v0.3.0) release and include it in the source block.
Example:

    module "dns-multicloud" {
      source              = "git::https://github.com/lhaig/terraform-dns-multicloud.git?ref=v0.3.0"
    }

## What is a Delegated Subdomain

In basic terms, a delegated DNS subdomain is a child domain of a larger parent domain name. It is used to organise web addresses. For example, mydomain.com is the parent domain and aws.mydomain.com is a child / subdomain.

In general, creating these in one environment is easy as the authoritative DNS servers are the same for the primary and the secondary zones. When you want to use these in different cloud providers for referencing resources within those providers, the providers need to have control of the domain. Therefore, we need to provision the zone on the DNS servers provided by the cloud providers. This is called delegating the zone.

## What you need

Accounts on the following cloud providers:

* AWS

* Azure

* GCP

Create a free account on the Terraform Cloud platform. You can find the signup page [here.](https://app.terraform.io/signup/account)

Login to your Terraform Cloud account.

![](https://cdn-images-1.medium.com/max/2000/1*TFR5y2WqF-xoToVodTP2Yw.png)

*If you are using the Terraform Cloud platform for the first time, you need to [create an organization](https://www.terraform.io/docs/cloud/users-teams-organizations/organizations.html) before creating the workspace needed.*
[Create a workspace](https://www.terraform.io/docs/cloud/workspaces/creating.html) to deploy your zones with.

Fork the [https://github.com/lhaig/terraform-dns-multicloud.git](https://github.com/lhaig/terraform-dns-multicloud.git) GitHub repository so that you can make changes to the plan for your deployment. We will link the repository to your workspace at the end of the blog post.

Now clone the git repository,

    git clone https://github.com/YOURNAME/terraform-dns-multicloud.git
    cd dns-multicloud

Open the file [variables.tf](https://github.com/lhaig/terraform-dns-multicloud/blob/master/variables.tf) in your editor. It will look something like this:

    # General
    variable "owner" {
      description = "Person Deploying this Stack e.g. john-doe"
    }

    variable "namespace" {
      description = "Name of the zone e.g. demo"
    }

    variable "created-by" {
      description = "Tag used to identify resources created programmatically by Terraform"
      default     = "terraform"
    }

    variable "hosted-zone" {
      description = "The name of the dns zone on Route 53 that will be used as the master zone "
    }

    # AWS

    variable "create_aws_dns_zone" {
      description = "Set to true if you want to deploy the AWS delegated zone."
      type        = bool
      default     = "false"
    }

    # Azure

    variable "create_azure_dns_zone" {
      description = "Set to true if you want to deploy the Azure delegated zone."
      type        = bool
      default     = "false"
    }

    variable "azure_location" {
      description = "The azure location to deploy the DNS service"
      default     = "West Europe"
    }

    # GCP

    variable "create_gcp_dns_zone" {
      description = "Set to true if you want to deploy the Azure delegated zone."
      type        = bool
      default     = "false"
    }

    variable "gcp_project" {
      description = "GCP project name"
    }

Now open the workspace [Variables](https://www.terraform.io/docs/cloud/workspaces/variables.html) section in the workspace and create and populate the variables as they are listed above. The result should look like this:

![Standard Terraform Variables](https://cdn-images-1.medium.com/max/4768/1*_lVrCnMCUR-BpUvfvBe3kA.png)*Standard Terraform Variables*

Next, you will need to create the [Environment Variables](https://www.terraform.io/docs/cloud/workspaces/variables.html#environment-variables) with the authentication credentials for each cloud provider.

The Environment Variables should all be created and marked as [sensitive](https://www.terraform.io/docs/cloud/workspaces/variables.html#sensitive-values). They should look like this once you have finished.

![Environment Variables](https://cdn-images-1.medium.com/max/2438/1*ZESW7paEdHNbz0XKogDqpA.png)*Environment Variables*

Terraform Cloud does not allow new line characters in variables and so needs to have the GOOGLE_CREDENTIALS as a specific format, as the standard way they are provided is via a json file.

Follow the steps below to prepare them.

    vim gcp-credentials.json

    then press :

    enter the following
    %s;\n; ;g

    Press enter

    Save the file by pressing : then wq and press enter

If you do not have access to vim in your environment. Open the editor of your choice and remove all Carriage returns from the file so the complete json file is on one line.

Copy the contents of the file into the variable, mark it as sensitive, and Save.

## Add the Git repository to your Workspace

To automate the deployment of this repository, we need to connect the git repository to your workspace in Terraform Cloud. To do this, access the workspace settings and select the version control section.

![](https://cdn-images-1.medium.com/max/2000/1*5ROao9CdQpzTGRlN9cQ9rg.png)

Once you select it, you will be presented with the version control page. Terraform Cloud supports a number of VCS providers.

Open the [Terraform VCS](https://www.terraform.io/docs/cloud/vcs/) page to find out how to connect your specific provider to your organization. Once the provider is connected, follow on from here.

We will use GitHub as the provider but the workflow will be similar for other providers. Click on the Connect to Version Control button** **on the page. Select the **Github** button.

![Terraform  Cloud login window](https://cdn-images-1.medium.com/max/2852/1*CJ8BOCalFaLScBVApdWymg.png)

Select your organization in the dropdown. Find the cloned repository **terraform-dns-multicloud** and click on the name.

![](https://cdn-images-1.medium.com/max/3144/1*SClV-UeJSASQyc5c9oJeeA.png)

You will be taken to the **Confirm Changes** section. Make sure the details are correct. Mine look like this:

![Confirm Changes](https://cdn-images-1.medium.com/max/2000/1*TPGibkYMQNU0TlZoJf-OUg.png)*Confirm Changes*

Click the Update VCS Settings button.

You now have the option to change the setting for **Automatic Runs** if you would like.

Terraform can be set to either automatically run a plan and apply for the updated commit or it can be configured to only run the plan and apply if a file in a specific path is changed.

I will keep the default of automatic, which is the **always trigger runs option**.

![](https://cdn-images-1.medium.com/max/3396/1*Lo8ZsH8_7uAikvUhJZm1vw.png)

Finally, click the **Update VCS button**.

Your plan will now be executed by Terraform Cloud; if you select the runs menu item you should see that your run is there but it needs confirmation. Click on the run and then you can see that the plan has completed and Terraform Cloud is waiting for you to confirm and apply the plan.

To allow for automatically applying the changes you could select the settings General option.

![Settings General](https://cdn-images-1.medium.com/max/2000/1*1YBWc8YDa4ink9wFvU08gQ.png)*Settings General*

Then change the Apply Method section to Auto Apply.

![](https://cdn-images-1.medium.com/max/3192/1*pjMyjzJecCSFTPv1wHdfig.png)

More in-depth documentation can be found in the [Connecting VCS Providers to Terraform Cloud](https://www.terraform.io/docs/cloud/vcs/index.html) documentation.

You could now make changes to the files and have the system automatically plan and apply them.

[outputs.tf](https://github.com/lhaig/dns-multicloud/blob/master/outputs.tf)

The last file is the [outputs.tf](https://github.com/lhaig/dns-multicloud/blob/master/outputs.tf) file. In this file we describe the outputs that we think will be needed when we want to use these zones when we are creating resources in the cloud providers.

    output "aws_sub_zone_id" {
      value = var.create_aws_dns_zone ? aws_route53_zone.aws_sub_zone[0].zone_id : ""
    }

    output "aws_sub_zone_nameservers" {
      value = var.create_aws_dns_zone ? aws_route53_zone.aws_sub_zone[0].name_servers : []
    }

    output "azure_sub_zone_name" {
      value = var.create_azure_dns_zone ? azurerm_dns_zone.azure_sub_zone[0].id : ""
    }

    output "azure_sub_zone_nameservers" {
      value = var.create_azure_dns_zone ? azurerm_dns_zone.azure_sub_zone[0].name_servers : []
    }

    output "azure_dns_resourcegroup" {
      value = var.create_azure_dns_zone ? azurerm_resource_group.dns_resource_group[0].name : ""
    }

    output "gcp_dns_zone_name" {
      value = var.create_gcp_dns_zone ? google_dns_managed_zone.gcp_sub_zone[0].name : ""
    }

    output "gcp_dns_zone_nameservers" {
      value = var.create_gcp_dns_zone ? google_dns_managed_zone.gcp_sub_zone[0].name_servers : []
    }

The outputs to take note of for use in other deployments are:

AWS — aws_sub_zone_id

Azure — azure_dns_resourcegroup

GCP — gcp_dns_zone_name

After you have customised the terraform files to your liking, save the files and commit them to the git repository.

When you now push the changes to the repository, Terraform Cloud will pick up these changes and run the plan for this repository.

