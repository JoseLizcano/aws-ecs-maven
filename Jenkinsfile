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
                    sh '''
                        docker build --build-arg project=hello_world \
                        --build-arg artifactid=hello_world \
                        --build-arg version=1.0-SNAPSHOT \
                        -t hello_world:${BUILD_TAG} . < Dockerfile
                    '''
                    sh '''
                        #!/usr/bin/env bash
                        if [[ $(aws ecr describe-repositories --query 'repositories[?repositoryName==`hello_world`].repositoryUri' --output text) -lt 1 ]]; then
                            aws ecr create-repository --repository-name hello_world;
                        fi
                    '''
                    sh '''
                        export ECR_REPO=$(aws ecr describe-repositories --query 'repositories[?repositoryName==`hello_world`].repositoryUri' --output text)
                        $(aws ecr get-login --no-include-email )
                        docker tag hello_world:${BUILD_TAG} ${ECR_REPO}:${BUILD_TAG}
                        docker push ${ECR_REPO}:${BUILD_TAG}
                    '''
                }
            }
        } // Build Container

    }
}