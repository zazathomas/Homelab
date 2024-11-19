properties([
    parameters([
        string(name: 'SOURCE_REGISTRY', defaultValue: 'cgr.dev', description: 'Source registry'),
        string(name: 'SOURCE_IMAGE', defaultValue: '', description: 'Image to replicate'),
        string(name: 'SOURCE_TAG', defaultValue: '', description: 'Select the image tag'),
        string(name: 'DESTINATION_TAG', defaultValue: '', description: 'Tag to replicate'),
    ])
])

// Define Variables
def registry = 'ghcr.io'
def imageTag = params.DESTINATION_TAG
def source_registry = params.SOURCE_REGISTRY
def source_image = params.SOURCE_IMAGE
def sourceTag = params.SOURCE_TAG
def destination_repository = 'zazathomas'
def credentialsId = 'ghcr'

podTemplate(
containers: [
  containerTemplate(image: 'jenkins/inbound-agent:jdk21', name: 'jnlp', alwaysPullImage: true),
  containerTemplate(args: 'infinity', command: 'sleep', image: 'gcr.io/go-containerregistry/crane:debug', name: 'crane', alwaysPullImage: true)
]
){
    node(POD_LABEL) {
        try {

            stage("Copy Image to Registry"){
                container('crane'){
                    echo "Logging into ${registry} registry..."
                    // Use Jenkins credentials to create `config.json`
                    withCredentials([usernamePassword(credentialsId: credentialsId, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh """
                        echo ${PASSWORD} | crane auth login ${registry} -u ${USERNAME} --password-stdin
                        """
                    }  // End of withCredentials
                    echo "Attempting to Copy Image to ${registry} registry..."
                    sh """
                    until crane copy ${source_registry}/${source_image}:${sourceTag} ${registry}/${destination_repository}/${source_image}:${imageTag}; do
                        echo "Image copy failed, retrying in 5 seconds..."
                        sleep 5
                    done
                    echo "Image copied successfully!"
                    """
                }
            }
        }

        catch (Exception e) {
        // Handle failure case (similar to `post { failure { } }` in declarative)
        echo "Pipeline failed: ${e.getMessage()}"
        currentBuild.result = 'FAILURE'
        }

        finally {
        // This will always run, whether success or failure (like `post { always { } }`)
        echo 'Pipeline finished!'
    }
}
}