def environment() {
    node {
        stage('Checkout del Repositorio') {
            checkout scm
        }

        stage('Definir Entorno') {
            script {
                def branch = env.GIT_BRANCH
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
                def repoName = env.REPO_NAME ?: sh(script: "echo ${env.GIT_URL} | awk -F'/' '{print \$NF}' | sed 's/.git\$//'", returnStdout: true).trim()
                echo "Nombre del repositorio: ${repoName}"
                if (repoName.contains("backend") && env.ENVIRONMENT == 'production') {
                    env.DEVELOPMENT = 'backend-production'
                } else if (repoName.contains("backend") && env.ENVIRONMENT == 'development') {
                    env.DEVELOPMENT = 'backend-development'
                } else if (repoName.contains("frontend") && env.ENVIRONMENT == 'production') {
                    env.DEVELOPMENT = 'frontend-production'
                } else if (repoName.contains("frontend") && env.ENVIRONMENT == 'development') {
                    env.DEVELOPMENT = 'frontend-development'
                }
                echo "Desarrollo configurado: ${env.DEVELOPMENT}"
            }
        }
    }
}

return this