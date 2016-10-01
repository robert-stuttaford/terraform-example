# aws
aws_profile    = "cgn-staging"
aws_account_id = "xxx"

# datadog
datadog_integration_id = "xxx"

# environment
environment = "staging"
system_name = "cgn-staging"

# network
cidr           = "10.1.0.0/16"
public_ranges  = ["10.1.0.0/19", "10.1.32.0/19", "10.1.64.0/19"]
private_ranges = ["10.1.128.0/19", "10.1.160.0/19", "10.1.192.0/19"]

# dns
route53_public_zone_id = "xxx"
domain                 = "cgn.fyi"
acm_arn                = "arn:aws:acm:us-west-2:XXXXXXXXXXXX:certificate/yyyyyyyyyyyyy"

# ec2
base_ami = "ami-xxxxxx" # packed cgn-base
key_name = "staging-instances"

# use http://www.ec2instances.info/ for easy instance name + capacity comparisons

datomic_instance_count = "1"
datomic_instance_type  = "c4.large"

transactor_memory_index_max       = "512m"
transactor_memory_index_threshold = "32m"
transactor_object_cache_max       = "1g"
transactor_xmx                    = "2625m"

dynamo_read_capacity  = "250"
dynamo_write_capacity = "125"

# datomic
backup_instance_type  = "t2.medium"
backup_instance_count = "0"

# memcached
memcached_instance_type = "cache.t2.micro"

# redis
redis_instance_type = "cache.t2.micro"

# bastion
bastion_instance_type = "t2.micro"

# APP_xmx              = ram - 500
# APP_object_cache_max = APP_xmx / 2
# APP_memory_index_max = APP_xmx / 8

# e.g. ram 7500m. xmx 7000m. object 3500m. memory 875m.

# c2 (aka server)
c2_instance_type    = "c4.xlarge"
c2_min_size         = "2"
c2_desired_capacity = "2"
c2_max_size         = "2"
c2_xmx              = "6000m"
c2_object_cache_max = "3000m"
c2_memory_index_max = "750m"

# chat
chat_instance_type    = "c4.xlarge"
chat_min_size         = "2"
chat_desired_capacity = "2"
chat_max_size         = "2"
chat_xmx              = "6000m"
chat_object_cache_max = "3000m"
chat_memory_index_max = "750m"

# highstorm
highstorm_instance_type    = "c4.2xlarge"
highstorm_min_size         = "3"
highstorm_desired_capacity = "3"
highstorm_max_size         = "3"
highstorm_xmx              = "12000m"
highstorm_object_cache_max = "6000m"
highstorm_memory_index_max = "1500m"

# zookeeper
zookeeper_instance_type    = "c4.large"
zookeeper_min_size         = "3"
zookeeper_desired_capacity = "3"
zookeeper_max_size         = "3"
