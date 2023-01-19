pipeline {

    agent any

    environment {
        GIT_LFS_SKIP_SMUDGE = 1
        CHART_REPO = "${env.altilia_ia_chart_repo}"
        CHART_REPO_CRED = credentials('altilia-chart-repo-cred')
        CHART_REPO_SUBPATH = 'infra'
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
               
                // get yq
                sh ('sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64 && sudo add-apt-repository ppa:rmescandon/yq')
                // Install all tools
                sh ('sudo apt-get update && sudo apt-get install -y kubectl yq')
                sh ('sudo apt update && sudo apt install software-properties-common')
            }
        }




        stage('Load Model To Minio') {
            when {
                anyOf {
                    branch 'dev'
                }
            }
            environment {
               KUBECONFIG = credentials('kubeconfig-altiliaia-dev')
            }
            
            steps {
                
                script {
                    env.MINIO = sh (
                        script: 'make KUBECONFIG=$KUBECONFIG get_minio_pod',
                        returnStdout: true
                    ).trim()
                    echo "${MINIO}"
                    env.MODEL_NAME = sh (
                        script: 'make KUBECONFIG=$KUBECONFIG get_model_name',
                        returnStdout: true
                    ).trim()
                    echo "${MODEL_NAME}"
                    sh ('make KUBECONFIG=$KUBECONFIG MODEL_NAME=$MODEL_NAME MINIO=$MINIO deploy_models_to_minio')
                }
                
                
            }  
        }

    }
 
}