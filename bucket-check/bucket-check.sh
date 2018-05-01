#!/bin/bash
#
#script checkes to see if an s3 bucket exists. If not, it builds it with a security policy
#place script and policy files in .gitlab directory of repo
#
echo "Checking S3 bucket exists..."
BUCKET_EXISTS=true
S3_CHECK=$(aws s3 ls "s3://$S3_BUCKET" 2>&1)
#Check if bucket exists; set var; fail if error in checking
if [ $? != 0 ]
then
  NO_BUCKET_CHECK=$(echo $S3_CHECK | grep -c 'NoSuchBucket')
  if [ $NO_BUCKET_CHECK = 1 ]; then
    echo "BUCKET DOES NOT EXIST"
    BUCKET_EXISTS=false
  else
    echo "Error checking S3 Bucket"
    echo "$S3_CHECK"
    exit 1
  fi
else
  BUCKET_EXISTS=true
fi
#
#Build bucket if does not exist
#
if [ $BUCKET_EXISTS == 'false' ]
  then
    aws s3 mb s3://$S3_BUCKET --region <region> --profile $1
    aws s3 website s3://$S3_BUCKET/ --index-document index.html --error-document error.html
    sed -i -e "s/bucket_name/$S3_BUCKET/g" .gitlab/s3_policy.json
    aws s3api put-bucket-policy --bucket $S3_BUCKET --policy file://.gitlab/s3_policy.json --profile $1
  else
    echo "BUCKET EXISTS IN S3. NO ACTION TAKEN"
fi
