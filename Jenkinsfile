pipeline {
    agent any
    environment {
    	AWS_DEFAULT_REGION = "ap-northeast-2"
    }
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
	    post {
 		 success {
        	    withAWS(credentials: 'aws-credentials') {
           	    	def s3 = s3UploadFile(
                	    file: "./${JOB_NAME}${BUILD_NUMBER}.tar.gz",
                	    bucket: "sshbucket-0408",
                	    path: "s3://sshbucket-0408/artifact/${JOB_NAME}${BUILD_NUMBER}.tar.gz"
            		)
            		println "Artifact uploaded to S3: s3://${s3.bucket}/${s3.path}"
        	    }
    		}
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

