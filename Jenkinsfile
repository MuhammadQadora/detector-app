pipeline {
    agent {
        kubernetes {
            serviceAccount 'jenkins'
            yaml '''
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: jnlp
                image: muhammadqadora/agent
              - name: kaniko
                image: gcr.io/kaniko-project/executor:debug
                imagePullPolicy: Always
                command:
                - sleep
                args:
                - 9999999
                volumeMounts:
                  - name: jenkins-docker-cfg
                    mountPath: /kaniko/.docker
              volumes:
              - name: jenkins-docker-cfg
                projected:
                  sources:
                  - secret:
                      name: docker-credentials 
                      items:
                        - key: .dockerconfigjson
                          path: config.json
            '''
        }
    }
    environment {
        password = credentials('password')
        user = credentials('user')
        dbname = credentials('dbname')
    }
    stages {
        stage('checkout-github') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-token', url: 'https://github.com/MuhammadQadora/detector-app.git']])
            }
        }
        // stage('kaniko-buildimage'){
        //     steps {
        //         container(name: 'kaniko', shell: '/busybox/sh'){
        //             sh '''#!/busybox/sh
        //             /kaniko/executor --context `pwd` --destination muhammadqadora/detector
        //             '''
        //         }
        //     }
        // }
        stage('deployment-kubernetes'){
            steps {
                sh '''#!/bin/bash
                for i in $(ls)
                do
                    if [[ $i == *.yaml ]]
                    then
                        envsubst < $i | kubectl apply -f -
                    fi
                done
                '''
            }
        }
        stage('insert-sql-script'){
            steps {
                sh '''#!/bin/bash
                sleep 15
                kubectl exec -i $(kubectl get pods -l app=mysql -o=name) -- mysql -u$(echo $user | base64 -d) -p$(echo $password | base64 -d) $dbname < src/main/resources/import.sql
                '''
                /////this should not be done in production.?
            }
        }
    }
}