# Template

A step for Wercker that processes template input files and replaces strings like ${FOO} with their value in the environment.

The step takes two arguments:

- **input**: path to input file (the template)
- **output**: path to output file (containing replaced values)
- **overwrite** (optional): string of environment variables to overwrite, in form of ENVVAR1=VAL1,ENVVAR2,VAL2

## Example

```
steps:
    - audienceproject/sam-deploy:
        - template: sam-template.yaml
        - s3-bucket: $ARTEFACTS_BUCKET
        - s3-prefix: "$WERCKER_GIT_REPOSITORY/$WERCKER_GIT_COMMIT"
        - stack-name: my awesome stack name
        - region: $AWS_REGION
        - tags: product=AudienceData project=$WERCKER_GIT_REPOSITORY
```
