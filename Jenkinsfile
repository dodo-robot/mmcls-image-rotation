pipeline {

    agent any

    environment {
        CHART_REPO = "${env.altilia_ia_chart_repo}"
        CHART_REPO_CRED = credentials('altilia-chart-repo-cred')
        CHART_REPO_SUBPATH = 'infra'
        PROJECT_NAME = env.JOB_NAME.tokenize('/').get(1)
    }

    stages {

        stage('Install & Test') {
            steps {
                script {
                    if (fileExists('./venv/')) {
                        sh('make python-test')
                    }else{
                        sh('make install_python')
                        sh('make python-test')
                    } 
                }
            }  
            
        }

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


        stage('Build and publish on Altilia CR dev') {
             when {
                anyOf {
                    branch 'dev'
                }
            }
            environment {
               CR_ALTILIA_URL = 'craltiliaaidevtr.azurecr.io'
               CR_ALTILIA = credentials('cr-altilia-cred-dev')
            }
            steps {
                script {
                    env.VERSION = sh (
                        script: 'python3.8 ./setup.py --version',
                        returnStdout: true
                    ).trim()
                    echo "${VERSION}"
                }
                sh ('make docker-build TAG="$CR_ALTILIA_URL/$PROJECT_NAME:${VERSION}"')
                sh ('make publish_on_acr CR_URL=$CR_ALTILIA_URL CR_USR=$CR_ALTILIA_USR CR_PWD=$CR_ALTILIA_PSW TAG="$CR_ALTILIA_URL/$PROJECT_NAME:${VERSION}"')
            }
            post {
                always {
                    sh ('make cleanup')
                }
            }
        }

        stage('Build and publish on Altilia CR test') {
            when { expression { env.BRANCH_NAME == 'test' } }
            environment {
                CR_ALTILIA_URL = 'craltiliaaitest.azurecr.io'
                CR_ALTILIA = credentials('cr-altilia-cred-test')
            }
            steps {
                script {
                    env.VERSION = sh (
                        script: 'python3.8 ./setup.py --version',
                        returnStdout: true
                    ).trim()
                    echo "${VERSION}"
                }
                sh ('make docker-build TAG="$CR_ALTILIA_URL/$PROJECT_NAME:${VERSION}"')
                sh ('make publish_on_acr CR_URL=$CR_ALTILIA_URL CR_USR=$CR_ALTILIA_USR CR_PWD=$CR_ALTILIA_PSW TAG="$CR_ALTILIA_URL/$PROJECT_NAME:${VERSION}"')
            }
            post {
                always {
                    sh ('make cleanup')
                }
            }
        }

        stage('Upload chart on Altilia charts repository') {
            when { expression { env.BRANCH_NAME == 'test' } }
            steps {
                sh('make upload_chart_to_repo USERNAME_CHART_REPO=$CHART_REPO_CRED_USR PASSWORD_CHART_REPO=$CHART_REPO_CRED_PSW CHART_REPO=$CHART_REPO CHART_REPO_SUBPATH=$CHART_REPO_SUBPATH CHART_NAME=$PROJECT_NAME APP_CHART_VERSION=${VERSION} CHART_VERSION=${VERSION}')
            }
        }

        stage('Deploy on Altilia AKS dev') {
            when { expression { env.BRANCH_NAME == 'dev' } }
            environment {
               KUBECONFIG = credentials('kubeconfig-altiliaia-dev')
            }
            steps {
                script {
                    timeout(time: 3, unit: 'MINUTES') {
                        input message: 'Approve deployment to DEV?'
                        sh('make KUBECONFIG=$KUBECONFIG CI_ENVIRONMENT_NAME="${BRANCH_NAME}" deploy')
                    }
                }
            }
        }
    }

    post {
        always {
            sh('make cleanup')
        }
    }
}