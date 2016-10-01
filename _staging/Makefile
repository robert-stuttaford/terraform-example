env=staging
profile=cgn-${env}

all: plan

region=us-west-2
tf-state-bucket=cgn-terraform

remote:
	terraform remote config \
		-backend=s3 \
		-backend-config="profile=${profile}" \
		-backend-config="bucket=${tf-state-bucket}" \
		-backend-config="key=${env}/terraform.tfstate" \
		-backend-config="region=${region}"

show:
	terraform show | grep module | sort

fmt:
	terraform fmt

get:
	terraform get

refresh:
	terraform refresh -var-file=_${env}.tfvars

plan: fmt get
	terraform plan -var-file=_${env}.tfvars -out proposed.plan

apply:
	terraform apply proposed.plan

destroy:
	terraform destroy -var-file=_${env}.tfvars

output:
	terraform output -no-color -json > tf_outputs.json

ansible:
	./upload-ansible-playbooks.sh

vars: output ansible

circleci-env:
	python update-circleci-env.py YOUR_CIRCLE_CI_TOKEN_HERE

packer-file=amis/cgn-base.json

# requires that the instance profile from terraform is live
pack:
	AWS_PROFILE=${profile} packer build ${packer-file}

instance-ips:
	aws ec2 describe-instances --output text --profile ${profile} \
	  --filters "Name=instance-state-name,Values=running" \
	  --query 'Reservations[*].Instances[*].[PrivateIpAddress,Tags[?Key==`Type`].Value[]]'
