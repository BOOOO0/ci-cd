pipeline {
    agent any
    stages {
	stage("Checkout Repo") {
            steps {
                cleanWs()
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/BOOOO0/ci-cd.git']]])
            }
        }
        stage("Build") {
            steps {
                nodejs('node14') {
                    sh 'npm install'
                    sh 'npm run build'
                    sh 'tar -zcf ${JOB_NAME}${BUILD_NUMBER}.tar.gz ./build/*'
		}
            }
	    post{
		sh 'aws s3 cp ./build/${JOB_NAME}${BUILD_NUMBER}.tar.gz s3://sshbucket-0408/artifact/${JOB_NAME}${BUILD_NUMBER}.tar.gz'
	    }
        }
        stage("Deploy") {
            steps {
                sh '''
                    ansible-playbook -i ./ansible/deploy/web.ini ./ansible/deploy/deploy_web_server_playbook.yml --extra-vars file_name='${JOB_NAME}${BUILD_NUMBER}.tar.gz'"
                '''
            }
        }
    }
}

