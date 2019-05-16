pipeline {
    agent {
        node {
            label 'dind'
        }
    }

    parameters {
        string(name: 'AWS_DEFAULT_REGION', defaultValue: 'us-east-1', description: 'The region to deploy to')
    }

    stages {
        stage('Build Container') {
            steps {
                script {
                    docker.withRegistry("https://016582840202.dkr.ecr.us-east-1.amazonaws.com", "ecr:us-east-1:aws") {
                        sh '''
                            docker build \
                            --build-arg artifactid=hello_world \
                            --build-arg version=1.0-SNAPSHOT \
                            -t hello_world:${BUILD_NUMBER} . < Dockerfile
                        '''
                        sh '''
                            #!/usr/bin/env bash
                            export ECR_REPO=016582840202.dkr.ecr.us-east-1.amazonaws.com/hello_world
                            docker tag hello_world:${BUILD_NUMBER} ${ECR_REPO}:${BUILD_NUMBER}
                            docker push ${ECR_REPO}:${BUILD_NUMBER}
                        '''
                    } 
                }
            }
        } // Build Container

        stage('Deploy to ECS ') {
            steps {
                sh '''#!/usr/bin/env bash
                    export ECR_REPO=016582840202.dkr.ecr.us-east-1.amazonaws.com/hello_world
                    ecport CF_ROLE_ARN=arn:aws:iam::016582840202:role/DEVOPS-CFRole-Z12JF9HZ2RVI
                    export CF_ROLE_ARN=$(aws cloudformation list-exports --query 'Exports[?Name==`CFRoleARN`].Value' --output text)
                    if aws cloudformation describe-stacks  --query 'Stacks[].StackName' | grep JenkinsECSHelloWorld ; then
                        aws cloudformation update-stack  --role-arn ${CF_ROLE_ARN} --stack-name JenkinsECSHelloWorld --template-body file://helloworld-taskdefinition.json  --parameters ParameterKey=TaskAmount,ParameterValue=1 ParameterKey=ContainerImage,ParameterValue=${ECR_REPO}:${BUILD_NUMBER}
                    else
                        aws cloudformation create-stack  --role-arn ${CF_ROLE_ARN} --stack-name JenkinsECSHelloWorld --template-body file://helloworld-taskdefinition.json  --parameters ParameterKey=TaskAmount,ParameterValue=1 ParameterKey=ContainerImage,ParameterValue=${ECR_REPO}:${BUILD_NUMBER}
                    fi
                '''
                sh '''#!/usr/bin/env bash
                    sleep 30
                    export status=$(aws cloudformation describe-stacks  --stack-name=JenkinsECSHelloWorld --query Stacks[].StackStatus --output text)
                    while [[ $status != *COMPLETE &&  $status != *FAILED ]]; do
                    sleep 30
                    export status=$(aws cloudformation describe-stacks  --stack-name=JenkinsECSHelloWorld --query Stacks[].StackStatus --output text)
                    done
                    echo $status
                    [[ $status == "UPDATE_COMPLETE" || $status == "CREATE_COMPLETE" ]]
                '''
            }
        } // Deploy to ECS

    }
}