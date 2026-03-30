def buildApp() {
    echo 'building the application...'
<<<<<<< HEAD
    sh 'mvn -f TWN-Jenkins/java-maven-app package'
}

def buildImage() {
    echo "building the docker image..."
    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', passwordVariable: 'PASS', usernameVariable: 'USER' )]) {
        sh 'docker build -t sharrods/demo-app:jma-2.1 -f TWN-Jenkins/java-maven-app/Dockerfile TWN-Jenkins/java-maven-app'
        sh 'echo $PASS | docker login -u $USER --password-stdin'
        sh 'docker push sharrods/demo-app:jma-2.1'
    }
=======
}

def testdApp() {
    echo 'testing the application...'
>>>>>>> 8332410 (Add Module 8 Jenkinsfiles, script.groovy updates and shared library)
}

def deployApp() {
    echo 'deploying the application...'
    echo "deploying version ${params.VERSION}"
}
<<<<<<< HEAD
return this
=======
return this
>>>>>>> 8332410 (Add Module 8 Jenkinsfiles, script.groovy updates and shared library)
