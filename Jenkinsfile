pipeline {
    /* Executa no node controller ----------------------------------------- */
    agent any

    /* Opções -------------------------------------------------------------- */
    options {
        ansiColor('xterm')
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '30'))
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
    }

    /* Ferramentas --------------------------------------------------------- */
    tools { terraform 'terraform' }

    /* Variáveis fáceis de ajustar ---------------------------------------- */
    environment {
        TF_BACKEND_BUCKET = ''              // → coloque o bucket depois
        TF_BACKEND_REGION = 'us-east-1'
    }

    stages {

        /* ---------- Checkout -------------------------------------------- */
        stage('Checkout') {
            steps { checkout scm }
        }

        /* ---------- Init ------------------------------------------------ */
        stage('Init') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-terraform',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {

                    script {
                        if (env.TF_BACKEND_BUCKET?.trim()) {
                            sh """
                              terraform init \
                                -backend-config="bucket=${TF_BACKEND_BUCKET}" \
                                -backend-config="region=${TF_BACKEND_REGION}"
                            """
                        } else {
                            sh 'terraform init'
                        }
                    }
                }
            }
        }

        /* ---------- Fmt & Validate -------------------------------------- */
        stage('Fmt & Validate') {
            steps {
                /* Apenas mostra diferenças, mas NÃO falha o build */
                sh 'terraform fmt -recursive -diff'
                sh 'terraform validate'
            }
        }

        /* ---------- Plan ------------------------------------------------ */
        stage('Plan') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-terraform',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {

                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        /* ---------- Apply (sempre) -------------------------------------- */
        stage('Apply') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-terraform',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {

                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }

    /* ---------- Pós-build ---------------------------------------------- */
    post {
        always {
            archiveArtifacts artifacts: 'tfplan', fingerprint: true
        }
    }
}