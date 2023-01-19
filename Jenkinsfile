pipeline {

    agent any

    environment {
        GIT_LFS_SKIP_SMUDGE = 1
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
                // get helm cli
                sh ('curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -')
                sh ('echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list')
                // get yq
                sh ('sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64 && sudo add-apt-repository ppa:rmescandon/yq')
                // Install all tools
                sh ('sudo apt-get update && sudo apt-get install -y kubectl helm yq')
                sh ('sudo apt update && sudo apt install software-properties-common')
            }
        }

    }
 
}