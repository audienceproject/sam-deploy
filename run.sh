#!/bin/bash
if [[  -z $WERCKER_SAM_DEPLOY_REGION || -z $WERCKER_SAM_DEPLOY_STACK_NAME ]]; then
        echo "Please set deploy stack region and name "
        exit 1
fi
if [[  -z $WERCKER_SAM_DEPLOY_TEMPLATE ]]; then
	echo "Please set template"
	exit 1
fi
if [[  -z $WERCKER_SAM_DEPLOY_S3_BUCKET ]]; then
	echo "Please set s3 bucket"
	exit 1
fi

if [[  -z $WERCKER_SAM_DEPLOY_S3_PREFIX ]]; then
	echo "Please set s3 prefix"
	exit 1
fi

if [[  -z $WERCKER_SAM_DEPLOY_TAGS ]]; then
	echo "Please set tags"
	exit 1
fi



SAM_PACKAGED_OUTPUT=sam-packaged.yaml

## package and upload swagger + lambda files
sam package \
	--template-file "$WERCKER_SAM_DEPLOY_TEMPLATE" \
	--output-template-file "$SAM_PACKAGED_OUTPUT" \
	--s3-bucket "$WERCKER_SAM_DEPLOY_S3_BUCKET" \
	--s3-prefix "$WERCKER_SAM_DEPLOY_S3_PREFIX" \
	--force-upload

echo "sam package created the following template file"
cat $SAM_PACKAGED_OUTPUT

## extracts the required CF parameters and supplies them via corresponding envvars
##
## parametername: DynamodbTable
## corresponding envvar: DYNAMODB_TABLE
##
function parse_yaml_for_parameters {
   
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if ( length($3) > 0 && vname[0]=="Parameters") {
        head = ""
        tail =  vname[1]
        while ( match(tail,/[A-Z]/) ) {
            tgt = substr(tail,RSTART,1)
            if ( substr(tail,RSTART-1,1) ~ /[a-z0-9]/ ) {
                tgt = "_" tolower(tgt)
            }
            head = head substr(tail,1,RSTART-1) tgt
            tail = substr(tail,RSTART+1)
        }
        envvar = toupper(head tail)
        value= ENVIRON[envvar]
        if (length(value) > 0) {
            printf("'%s=%s' ",vname[1],value);
        }
      }
   }'
   echo -n "sdiufhasuidf=sdiufhasuidf"
}

PARAMETERS=$(parse_yaml_for_parameters $SAM_PACKAGED_OUTPUT)

echo "Using the following parameter overrides: ${PARAMETERS}"

## actually deploy the CF template
sam deploy \
    --region $WERCKER_SAM_DEPLOY_REGION \
	--template-file $SAM_PACKAGED_OUTPUT \
	--stack-name $WERCKER_SAM_DEPLOY_STACK_NAME \
	--capabilities CAPABILITY_IAM \
	--parameter-overrides $PARAMETERS \
	--tags $WERCKER_SAM_DEPLOY_TAGS