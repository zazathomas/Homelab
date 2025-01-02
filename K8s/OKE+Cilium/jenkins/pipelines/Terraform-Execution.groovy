properties([
    parameters([
        string(name: 'SOURCE_REPOSITORY', defaultValue: '', description: 'Terraform configuration source repository'),
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Terraform action to run i.e. apply | destroy'),
        string(name: 'SOURCE_REPOSITORY_PATH', defaultValue: '', description: 'Terraform source repository path'),
    ])
])

// Define environment variables
def credentialsId_backend = 'tf-backend-creds'
def credentialsId_oci = 'tf-infra-creds'
def terraform_giturl = params.SOURCE_REPOSITORY
def terraform_git_path = params.SOURCE_REPOSITORY_PATH
def terraform_action = params.ACTION

podTemplate(
containers: [
  containerTemplate(image: 'jenkins/inbound-agent:jdk21', name: 'jnlp', alwaysPullImage: true),
  containerTemplate(args: 'infinity', command: 'sleep', image: 'hashicorp/terraform:1.9', name: 'terraform', alwaysPullImage: true)
]
){
    node(POD_LABEL) {
        try {

            stage("Clone terraform repository") {
                echo "Cloning terraform configuration..."
                git branch: 'main', url: terraform_giturl
            }

            stage("Setup Terraform Credentials") {
                container('terraform'){
                    echo "Configuring Terraform credentials..."
                    sh """
                        # Configure the Terraform CLI
                    """  // End of withCredentials
                }
            }

            stage("Terraform Init") {
                container('terraform'){
                    echo "Initializing Terraform..."
                    sh """
                       # terraform init
                    """
                }
            }

            stage("Terraform Plan") {
                container('terraform'){
                    echo "Planning Terraform..."
                    sh """
                      #  terraform plan
                    """
                }
            }

            stage("Terraform Action") {
                container('terraform'){
                    echo "${terraform_action}ing Terraform config..."
                    sh """
                      #  terraform $terraform_action --auto-approve
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