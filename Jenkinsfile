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
                            export ECR_REPO=https://016582840202.dkr.ecr.us-east-1.amazonaws.com
                            docker tag hello_world:${BUILD_NUMBER} ${ECR_REPO}:${BUILD_NUMBER}
                            docker push ${ECR_REPO}:${BUILD_NUMBER}
                        '''
                    } 
                }
            }
        } // Build Container

    }
}