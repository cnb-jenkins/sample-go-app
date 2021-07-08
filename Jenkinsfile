node("master") {
  withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
    cleanWs()
    checkout scm
    sh 'curl -L https://github.com/vmware-tanzu/kpack-cli/releases/download/v0.3.0/kp-linux-0.3.0 > kp && chmod +x kp'
    sh './kp image save demo --git $(git config --get remote.origin.url) --git-revision $(git rev-parse HEAD) --cluster-builder my-cluster-builder -w --tag samj1912/sample-app'
    def image = sh( script: "./kp image status demo | grep Image |  tr -s ' ' | cut -d ' ' -f 2", returnStdout: true).trim()
    sh "echo ${image}"
  }
}
