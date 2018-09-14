# Template

A step for Wercker that processes sam template and deploys cloudformation stack

## Example

```
steps:
    - audienceproject/sam-deploy:
        template: sam-template.yaml
        s3-bucket: $ARTEFACTS_BUCKET
        s3-prefix: "$WERCKER_GIT_REPOSITORY/$WERCKER_GIT_COMMIT"
        stack-name: my awesome stack name
        region: $AWS_REGION
        tags: product=AudienceData project=$WERCKER_GIT_REPOSITORY
```
