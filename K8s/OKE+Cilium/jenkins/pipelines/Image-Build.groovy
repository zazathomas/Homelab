properties([
    parameters([
        string(name: 'GIT_REPO_URL', defaultValue: 'https://github.com/zazathomas/Jenkins-for-DevSecOps.git', description: 'Repository containing the Dockerfile'),
        string(name: 'KANIKO_CONTEXT', defaultValue: 'Docker-Deployment', description: 'Context for Docker build'),
        string(name: 'PATH_TO_DOCKERFILE', defaultValue: 'Docker-Deployment/Dockerfile', description: 'Path to Dockerfile'),
        string(name: 'IMAGE_NAME', defaultValue: '', description: 'Image name to build'),
        string(name: 'IMAGE_TAG', defaultValue: '', description: 'Specify the image tag')
    ])
])

// Define variables
def registry = 'ghcr.io'
def image_repository = 'zazathomas'
def imageName = params.IMAGE_NAME
def imageTag = params.IMAGE_TAG
def giturl = params.GIT_REPO_URL
def kanikoContext = params.KANIKO_CONTEXT
def kanikoDockerfile = params.PATH_TO_DOCKERFILE
def credentialsId = 'ghcr'  // Store credentials securely in Jenkins


podTemplate(
    containers: [
        containerTemplate(image: 'jenkins/inbound-agent:jdk21', name: 'jnlp', alwaysPullImage: true),
        containerTemplate(args: 'infinity', command: 'sleep', image: 'gcr.io/kaniko-project/executor:debug', name: 'kaniko', alwaysPullImage: true),
        containerTemplate(args: 'infinity"', command: 'sleep', image: 'jitesoft/cosign:v2.4.1', name: 'cosign', alwaysPullImage: true)
    ]
) {
    node(POD_LABEL) {
        try {
            stage('Git Clone') {
                echo 'Cloning Repository...'
                git branch: 'main', url: giturl
            }

            stage("Build Image") {
                container('kaniko') {
                    echo "Logging into ${registry} registry..."
                    // Use Jenkins credentials to create `config.json`
                    withCredentials([usernamePassword(credentialsId: credentialsId, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh """
                            echo '{"auths": {"https://${registry}": {"username": "$USERNAME", "password": "$PASSWORD"}}}' > /kaniko/.docker/config.json
                        """
                    }  // End of withCredentials

                    echo 'Building Image using Kaniko...'
                    sh """
                    /kaniko/executor \
                      --context ${kanikoContext} \
                      --dockerfile ${kanikoDockerfile} \
                      --destination ${registry}/${image_repository}/${imageName}:${imageTag} \
                      --destination ${registry}/${image_repository}/${imageName}:latest \
                      --cache=true \
                      --skip-tls-verify=true
                    """
                }  // End of container 'kaniko'
            }

            stage("Sign Image") {
                container('cosign') {
                    echo 'Signing Image...'
                    withCredentials([file(credentialsId: "cosign-keyy", variable: 'COSIGN_KEY')]) {
                    withCredentials([usernamePassword(credentialsId: credentialsId, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh """
                        echo ${PASSWORD} | cosign login ${registry} -u ${USERNAME} --password-stdin
                        COSIGN_PASSWORD="" cosign sign --key $COSIGN_KEY ${registry}/${image_repository}/${imageName}:${imageTag} -y
                        """
                    }
                    }  // End of withCredentials
                }  // End of container 'cosign'
            }
        }  // End of try

        catch (Exception e) {
            echo "Pipeline failed: ${e.getMessage()}"
            currentBuild.result = 'FAILURE'
        } 
        
        finally {
            echo 'Pipeline finished!'
        }
    }  // End of node
}
