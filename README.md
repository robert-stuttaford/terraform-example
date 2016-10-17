# Terraform Example

This code was extracted from Cognician's 3rd-gen AWS infrastructure on Oct 1 2016.

Cognician's codebase is still very much a work in progress :-)

The overall design decisions are:

- Approachable infrastructure code for the whole tech team. I'm glaring at you, CloudFormation.
- Use [Terraform](https://www.terraform.io) for provisioning infrastructure.
- Use [Packer](https://www.packer.io) to build a single general-purpose base AMI.
- Use [Ansible](https://www.ansible.com) playbooks for instance configuration.
- Keep separate environments in separate AWS accounts, with a controlling 'master' account for some goodies. Please follow this excellent article on that:  <http://cobus.io/aws/2016/09/03/AWS_Multi_Account.html>.

Given that it is extracted, it's a mix of the things Cognician needs. In no particular order, those are:

- A single VPC, with the usual 3 security group setup - internal, web, and bastion.
- A bastion a.k.a. jump host.
- A [Datomic](https://www.datomic.com) transactor pair.
- Elasticache:
  - Memcached - Datomic's 2nd-tier peer cache.
  - Redis - a function memoisation backend using https://github.com/strongh/crache.
- AWS CodeDeploy.
- Datadog integration.
- Several web apps.
- Several non-web apps.
- A Zookeeper cluster.
- Several S3 buckets.

## Why am I sharing this?

I wanted to give back. Several folks in the community really helped me get up to speed, either through their writing or through answering many questions. Check them out.

- Charity Majors' blog posts https://charity.wtf/tag/terraform/ - and that she was kind enough to give me a copy of her TF code! :fistbump:
- Michael McClintock's sample code for Datomic https://github.com/mrmcc3/tf_aws_datomic - thanks Mike!
- Cobus Bernard, for showing me the AWS multi-account stuff - that's his post above - and for all the general assistance.
- Paul Stack, for his excellent Exhibitor/Zookeeper code, published here: http://www.paulstack.co.uk/blog/2016/01/15/building-an-autodiscovering-apache-zookeeper-cluster-in-aws-using-packer-ansible-and-terraform/
- `#terraform` on https://hangops.slack.com/ - so many folks helped!

Also, I strongly believe in Terraform and I can clearly see the leverage it produces, and want to make it easy for others to see it and adopt it.

Finally, I'm really hoping some folks are going to tell me how wrong I am doing things, so that I can learn :-)

## Disclaimer

I'm sharing this 'as is'. I make no guarantees of maintenance of this code. Use at your own risk.

Just saying!

---

## Workstation Setup

### 1. AWS

> Sets up AWS credentials for aws cli and the rest of the tools.

Install AWS CLI.

```
brew install awscli
```

This will ensure that the environments you work with are in your `~/.aws/` files.

Note that the `default` profile is empty; this is intentional. We'll declare a profile in our terraform files.

`~/.aws/config`:

```
[default]
region = us-west-2

[profile cgn-master]
region = us-east-1

[profile cgn-staging]
region = us-west-2
```

`~/.aws/credentials`:

```
[default]

[cgn-master]
aws_access_key_id = ...
aws_secret_access_key = ...

[cgn-staging]
aws_access_key_id = ...
aws_secret_access_key = ...

```

Test that AWS is set up by calling `aws ec2 describe-instances` with a `--profile cgn-???` arg, which prints info about the user you're authenticated as.

### 2. Terraform

> Terraform manages AWS infrastructure - IAM users, S3 buckets, EC2 scaling groups, etc.

Install Terraform:

```
brew install terraform
```

For each `_[environment]`, go into each one and run `make remote`:

```
cd _staging
make remote
```

This will allow you to download the current Terraform state for that env from S3.

Verify that it's working with `make plan`:

```
make plan
```

You should see Terraform do some work and then declare that there are no differences between what you have and what's running.

### 3. Packer

> Packer builds AMIs (Amazon Machine Images) for our EC2 instances to use.

Install Packer:

```
brew install packer
```

### 4. Ansible

> Ansible configures our instances for specific tasks e.g. Zookeeper or one of our apps.

Install Ansible:

```
brew install python
pip install ansible
```

Install Ansible Dynamic Inventory for EC2:

```
mkdir -p /etc/ansible
cp playbooks/inventory/ec2.py /etc/ansible/hosts
cp playbooks/inventory/ec2.ini /etc/ansible/ec2.ini
```

- - -

### 4. SSH proxying

For staging, put this into `~/.ssh/config`:

```
Host *
  UseRoaming no
  ControlPath ~/.ssh/cm-%r@%h:%p
  ControlMaster auto
  ControlPersist 10m
  ForwardAgent yes
  Port 22

Host b.cgn.fyi
  HostName b.cgn.fyi
  User ubuntu
  IdentityFile ~/.ssh/your-ec2-ssh-key-for-that-env

Host 10.1.*
  ProxyCommand ssh -W %h:%p ubuntu@b.cgn.fyi
  User ubuntu
  IdentityFile ~/.ssh/your-ec2-ssh-key-for-that-env
```

## Pack AMIs

AMIs are packed per environment. We may centralise them in the future.

```
cd _staging
make pack
```

This will pack `_staging/amis/cgn-base.json`, and eventually produce a new `ami-xxxxxxxx` value for you to place in `_staging/_staging.tfvars` -> `*_ami` values.

- - -

## Using Terraform

[Terraform](https://www.terraform.io) uses a two-phase approach:

```
cd _staging
make remote # you only need to do this once
make plan
```

This will assess what's live and compare it to your state, and come up with a plan to apply (which it will store in `./proposed.plan`.

Assuming the output matches your intentions, apply the plan:

```
make apply
```

Once you are returned to the prompt, your changes are live — although some EC2 provisioning may still be in progress.

## Generate Ansible vars from Terraform outputs

```
cd _staging
./gen-ansible-vars.py
```

This will populate `playbooks/group_vars/all.yml` with values produced
by Terraform output.

## List private ips for all running instances for tag

When using the SSH config described above, you can use this to get a list of IPs for an app to SSH into.

```
cd _staging
make instance-ips
```

---

# CI build steps for this repo

0. Ensure terraform is installed.
1. Ensure `terraform.tfstate` is present: `cd _staging && make remote`.
2. Update all CircleCI apps via API to have the correct AWS creds (from `terraform output`) with `python update-circleci-env.py`.
3. `bash upload-ansible-playbooks.sh`.
