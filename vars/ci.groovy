def ci() {
    node {
        environment {
            ENTORNO = entorno
            DESARROLLO = desarrollo
        }

        stage('Preparación') {
            echo "Entorno: ${ENTORNO}"
            echo "Desarrollo: ${DESARROLLO}"
        }

        stage('Checkout Code') {
            checkout scm
        }

        stage('Extraer versión') {
            script {
                def pipelineName = env.GIT_URL.split('/')[4]
                if (pipelineName.contains('backend')) {
                    def version = sh(script: "grep -oP '<version>\\K[^\<]+' pom.xml | sed -n '2p'", returnStdout: true).trim()
                    currentBuild.description = "Version: ${version}"
                    env.VERSION = version
                } else if (pipelineName.contains('frontend')) {
                    def version = sh(script: "jq -r '.version' package.json", returnStdout: true).trim()
                    currentBuild.description = "Version: ${version}"
                    env.VERSION = version
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