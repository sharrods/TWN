def buildJar() {
    echo 'building the application...'
    sh 'mvn package'
}
j
def buildImage() {
    echo "building the docker image..."
    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
        sh 'docker build -t sharroddev/demo-app:jma-1.1 .'
        sh 'echo $PASS | docker login -u $USER --password-stdin'
        sh 'docker push sharroddev/demo-app:jma-1.1'
    }
}

def deployApp() {
    echo 'deploying the application...'
}

return this
