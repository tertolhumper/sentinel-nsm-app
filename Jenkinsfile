pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker
    image: docker:27-dind
    securityContext:
      privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - sleep
    args:
    - infinity
    securityContext:
      runAsUser: 0
'''
        }
    }
    environment {
        IMAGE = "ghcr.io/tertolhumper/sentinel-nsm-app"
        TAG = "${BUILD_NUMBER}"
    }
    stages {
        stage('Build') {
            steps {
                container('docker') {
                    sh '''
                        docker build -t ${IMAGE}:${TAG} -t ${IMAGE}:latest .
                    '''
                }
            }
        }
        stage('Push') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(
                        credentialsId: 'ghcr-credentials',
                        usernameVariable: 'GHCR_USER',
                        passwordVariable: 'GHCR_TOKEN'
                    )]) {
                        sh '''
                            echo $GHCR_TOKEN | docker login ghcr.io -u $GHCR_USER --password-stdin
                            docker push ${IMAGE}:${TAG}
                            docker push ${IMAGE}:latest
                        '''
                    }
                }
            }
        }
        stage('Update Config') {
            steps {
                container('kubectl') {
                    sh '''
                        kubectl set image deployment/nginx nginx=${IMAGE}:${TAG} -n lemp
                    '''
                }
            }
        }
    }
}
