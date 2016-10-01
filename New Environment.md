## Setting up a new environment

WIP!

- Decide on a name.
- Make a new AWS account.
- Set up account links between new account and master account.
  - http://cobus.io/aws/2016/09/03/AWS_Multi_Account.html
  - Set up role assumption, consolidated billing.
- [SUB] Set up access credentials in local AWS profile.
- [SUB] Allow access to `cgn-terraform` S3 bucket.
- [MASTER] Allow CircleCI user to access `cgn-YOUR-ENV-ci` and `cgn-YOUR-ENV-static` S3 buckets.
- [SUB] Set up AWS credentials.
- [SUB] Set up an SSH key and make available locally for SSH usage.
- [MASTER] Register a domain with AWS Route53.
- [SUB] Set up hosted zone for domain.
- [SUB] Register SSL certificate with AWS ACM.
- Clone `_staging` and edit all occurrences of `staging` to your new name.
- Edit your new environment to suit.
- `cd _YOUR-ENV && make remote` to bootstrap Terraform state.
