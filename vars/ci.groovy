def ci(String entorno, String desarrollo) {
    node {
        stage('Checkout Code') {
            script {
                if(desarrollo.contains('backend')) {
                    git branch: 'develop', url: 'https://github.com/stemdo-labs/final-project-gestion-orquestas-backend-aitorcajas.git'
                } else if (desarrollo.contains('frontend')) {
                    git branch: 'develop', url: 'https://github.com/stemdo-labs/final-project-gestion-orquestas-frontend-aitorcajas.git'
                }
            }
        }

        stage('Extraer versión') {
            script {
                def repoName = env.REPO_NAME ?: sh(script: "echo ${env.GIT_URL} | awk -F'/' '{print \$NF}' | sed 's/.git\$//'", returnStdout: true).trim()
                echo "Nombre del repositorio: ${repoName}"
                if (repoName.contains('backend')) {
                    def version = sh(script: "grep -oP '<version>\\\\K[^<]+' pom.xml | sed -n '2p'", returnStdout: true).trim()
                    env.VERSION = version
                    echo "Versión (backend): ${version}"
                } else if (repoName.contains('frontend')) {
                    def version = sh(script: "jq -r '.version' package.json", returnStdout: true).trim()
                    env.VERSION = version
                    echo "Versión (frontend): ${version}"
                }
            }
        }

        // stage('Cargar imagen') {
        //     steps {
        //         script {
        //             def imageName = sh(script: "echo ${params.DESARROLLO}-${env.VERSION}", returnStdout: true).trim()
        //             env.IMAGE_NAME = imageName
        //             echo "Image name: ${env.IMAGE_NAME}"
        //         }
        //     }
        // }
    }
}

return this