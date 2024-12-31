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
                    def version = sh(script: "grep -oP '<version>[^<]+' pom.xml | sed 's/<version>//' | sed -n '2p'", returnStdout: true).trim()
                    env.VERSION = version
                    echo "Versión (backend): ${version}"
                } else if (repoName.contains('frontend')) {
                    def json = readJSON file: 'package.json'
                    def version = json.version
                    env.VERSION = version
                    echo "Versión (frontend): ${version}"
                }
            }
        }

        stage('Cargar imagen') {
            script {
                def imageName = sh(script: "echo acajas-cr-namespace/${desarrollo}:${version}", returnStdout: true).trim()
                env.IMAGE_NAME = imageName
                echo "Image name: ${env.IMAGE_NAME}"
            }
        }

        stage('Preparar Entorno') {
            container('tools') {
                sh '''
                    apt-get update && apt-get install -y curl bash git docker.io
                    curl -fsSL https://clis.cloud.ibm.com/install/linux | bash
                    ibmcloud plugin install container-registry -r 'IBM Cloud'
                    dockerd > /var/log/dockerd.log 2>&1 &
                    sleep 10
                    docker version
                    ibmcloud --version
                    ibmcloud plugin list
                '''
            }
        }

        stage('Build de la imagen') {
            script {
                sh 'docker build -t ${imageName} .'
            }
        }
    }
}

return this