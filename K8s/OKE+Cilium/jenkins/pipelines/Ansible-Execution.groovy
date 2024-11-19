properties([
    parameters([
        string(name: 'GIT_REPO_URL', defaultValue: 'https://github.com/zazathomas/Jenkins-for-DevSecOps.git', description: 'Repository containing the ansible-playbook'),
        string(name: 'PATH_TO_PLAYBOOK', defaultValue: './', description: 'Path to Playbook'),
        string(name: 'Inventory', defaultValue: '', description: 'Inventory to run the playbook against'),
    ])
])

// Define variables
def giturl = params.GIT_REPO_URL
def playbook = params.PATH_TO_PLAYBOOK
def inventory = ''  


podTemplate(
    containers: [
        containerTemplate(image: 'jenkins/inbound-agent:jdk21', name: 'jnlp', alwaysPullImage: true),
        containerTemplate(args: 'infinity', command: 'sleep', image: 'alpine/ansible:latest', name: 'ansible', alwaysPullImage: true),
    ]
) {
    node(POD_LABEL) {
        try {
            stage('Git Clone') {
                echo 'Cloning Repository...'
                git branch: 'main', url: giturl
            }

            stage("Run Playbook") {
                container('ansible') {
                    echo "Running playbook..."
                    sh 'ansible-playbook --help'
                    // Use Jenkins credentials to create `config.json`
                    //withCredentials([file(credentialsId: "ansible-ssh-key", variable: 'SSH_KEY')]) {
                     //   sh """
                      //      # ansible-playbook -i inventory < follow command>
                      //  """
                   // }
                    // ansible runs
                }  // End of container 'ansible'
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
