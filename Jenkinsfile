def minio = ""
def model_name = ""
    
pipeline {

    agent any

    environment {
        GIT_LFS_SKIP_SMUDGE = 1
        KUBECONFIG = credentials('kubeconfig-altiliaia-dev')
        PROJECT_NAME = env.JOB_NAME.tokenize('/').get(1)
    }

    stages {
 
        stage('Setup: install kubectl, helm, yq and other tools') {
            when {
                anyOf {
                    branch 'master'
                    branch 'test'
                    branch 'dev'
                }
            }
            steps {
                sh ('echo "Current workspace is $WORKSPACE"')
                sh ('echo "Install tools "')
                sh ('sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl lsb-release gnupg')
                // get kubectl
                sh ('sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg')
                sh ('echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list')
                // Install all tools
                sh ('sudo apt-get update && sudo apt-get install -y kubectl')
                sh ('sudo apt update && sudo apt install software-properties-common')
            }
        }

        stage("GET MINIO POD NAME") {
            when {
                anyOf {
                    branch 'dev'
                }
            }
             steps {
                script {
                    env.MINIO = sh (
                            script: 'make KUBECONFIG=$KUBECONFIG get_model_name',
                            returnStdout: true
                        ).trim()
                    echo "${MINIO}"
                    minio = "${MINIO}"
                } 
               
              }
        }

        stage("GET MODEL NAME") {
            when {
                anyOf {
                    branch 'dev'
                }
            }
             steps {
                script {
                    env.MODEL_NAME = sh (
                            script: 'make KUBECONFIG=$KUBECONFIG get_minio_pod',
                            returnStdout: true
                        ).trim()
                    echo "${MODEL_NAME}"
                    model_name="${MODEL_NAME}"
                } 
              }
        }

        stage('Load Model To Minio') {
            when {
                anyOf {
                    branch 'dev'
                }
            }
            
            steps {
                script {
                    env.MODEL_NAME=model_name
                    env.MINIO=minio
                    sh ('make KUBECONFIG=$KUBECONFIG MODEL_NAME=${MODEL_NAME} MINIO=${MINIO} deploy_models_to_minio')
                }
            }  
        }

    }
 
}