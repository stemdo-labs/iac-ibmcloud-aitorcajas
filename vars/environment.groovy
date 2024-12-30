def environment() {
    node {
        stage('Checkout del Repositorio') {
            checkout scm
        }

        stage('Definir Entorno') {
            script {
                def branch = env.GIT_BRANCH
                echo "Rama actual: ${branch}"
                if (branch == 'origin/main') {
                    env.ENVIRONMENT = 'production'
                } else if (branch == 'origin/develop') {
                    env.ENVIRONMENT = 'development'
                }
                echo "Entorno definido: ${env.ENVIRONMENT}"
            }
        }

        stage('Extraer Desarrollo') {
            script {
                def pipelineName = sh(script: "basename \$(git rev-parse --show-toplevel)", returnStdout: true).trim()
                echo "Nombre de la pipeline: ${pipelineName}"
                if (pipelineName.contains("backend") && env.ENVIRONMENT == 'production') {
                    env.DEVELOPMENT = 'backend-production'
                } else if (pipelineName.contains("backend") && env.ENVIRONMENT == 'development') {
                    env.DEVELOPMENT = 'backend-development'
                } else if (pipelineName.contains("frontend") && env.ENVIRONMENT == 'production') {
                    env.DESARRODEVELOPMENTLLO = 'frontend-production'
                } else if (pipelineName.contains("frontend") && env.ENVIRONMENT == 'development') {
                    env.DEVELOPMENT = 'frontend-development'
                }
                echo "Desarrollo configurado: ${env.DEVELOPMENT}"
            }
        }
    }
}

return this