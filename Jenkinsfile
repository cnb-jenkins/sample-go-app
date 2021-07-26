node("master") {
  withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
    cleanWs()
    checkout scm
    sh 'GIT_REVISION=$(git rev-parse HEAD) make unit-test build'
    sh "Successfully built $(image-tag)"
  }
}
