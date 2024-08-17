pipeline {
    agent { label 'slave' }

    stages {
        stage('Checkout') {
            steps {
                // Checkout code from SCM
                git branch: 'master', url: 'https://github.com/rwirba/ezlearn-academy.git'
            }
        }

        stage('Compile') {
            steps {
                // Run Maven compile
                sh '/opt/maven/bin/mvn clean compile'
            }
        }

        stage('Build (Package)') {
            steps {
                // Run Maven package to build the WAR file
                sh '/opt/maven/bin/mvn clean package'
            }
            post {
                // Archive the WAR file
                always {
                    archiveArtifacts artifacts: 'target/*.war', allowEmptyArchive: true
                }
            }
        }

        stage('Test') {
            steps {
                // Run Maven tests
                sh '/opt/maven/bin/mvn test'
            }
            post {
                // Archive test results
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                script {
                    // Deploy to Tomcat 9 using the Deploy to Container plugin
                    deploy adapters: [
                        tomcat9(credentialsId: 'admin', 
                                path: '', 
                                url: 'http://3.92.144.224:8081/manager/text')
                    ], 
                    war: '**/*.war',
                    contextPath: '/'
                }
            }
        }
    }
}
