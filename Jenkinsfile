node("master") {
  withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
    cleanWs()
    checkout scm
    sh 'make unit-test build'
    sh 'echo "Successfully built $(make image-tag)"'
    cleanWs()
  }
}
