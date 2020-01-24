// pipeline {
//     agent any
//     stages {
//         stage('Build') {
//             steps {
//                 script {
//                   sh 'cat Dockerfile'
//                 }
//             }
//         }
//     }
// }

node {
    checkout scm

    stage('Build') {
        sh 'cat Dockerfile'
    }
}
