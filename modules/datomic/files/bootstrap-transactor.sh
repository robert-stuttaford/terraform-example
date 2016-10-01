exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

DD_API_KEY=${datadog_api_key}  bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)"

export XMX=${xmx}
export JAVA_OPTS=${java_opts}
export DATOMIC_DEPLOY_BUCKET=deploy-a0dbc565-faf2-4760-9b7e-29a8e45f428e
export DATOMIC_VERSION=${datomic_version}

cd /datomic

cat <<EOF >aws.properties
aws-transactor-role=${transactor_role}
aws-peer-role=${peer_role}
aws-dynamodb-region=${region}
aws-dynamodb-table=${dynamo_table}
aws-cloudwatch-region=${region}
aws-cloudwatch-dimension-value=${cloudwatch_dimension}
aws-s3-log-bucket-id=${s3_log_bucket}
protocol=ddb
host=`curl http://instance-data/latest/meta-data/local-ipv4`
alt-host=`curl http://instance-data/latest/meta-data/public-ipv4`
port=4334
memory-index-max=${memory_index_max}
memory-index-threshold=${memory_index_threshold}
object-cache-max=${object_cache_max}
license-key=${license-key}
memcached=${memcached_uri}
EOF
chmod 744 aws.properties

AWS_ACCESS_KEY_ID="$${DATOMIC_READ_DEPLOY_ACCESS_KEY_ID}" AWS_SECRET_ACCESS_KEY="$${DATOMIC_READ_DEPLOY_AWS_SECRET_KEY}" aws s3 cp "s3://$${DATOMIC_DEPLOY_BUCKET}/$${DATOMIC_VERSION}/startup.sh" startup.sh
chmod 500 startup.sh
./startup.sh
