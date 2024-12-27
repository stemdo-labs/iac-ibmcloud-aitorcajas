def call(Map pipelineParams) {
    pipeline {
        agent any

        stages {
            stage('Checkout del Repositorio') {
                steps {
                    checkout scm
                }
            }

            stage('Definir Entorno') {
                steps {
                    script {
                        // Obtener el nombre de la rama desde Git
                        def branch = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
                        echo "Rama actual: ${branch}"
                        if (branch == 'main') {
                            env.ENVIRONMENT = 'production'
                        } else if (branch == 'develop') {
                            env.ENVIRONMENT = 'development'
                        } else {
                            error "Branch no reconocido: ${branch}"
                        }
                        echo "Entorno definido: ${env.ENVIRONMENT}"
                    }
                }
            }

            stage('Extraer Desarrollo') {
                steps {
                    script {
                        def repoName = sh(script: "basename \$(git rev-parse --show-toplevel)", returnStdout: true).trim()
                        if (repoName.contains("backend") && env.ENVIRONMENT == 'production') {
                            env.DESARROLLO = 'backend-production'
                        } else if (repoName.contains("backend") && env.ENVIRONMENT == 'development') {
                            env.DESARROLLO = 'backend-development'
                        } else if (repoName.contains("frontend") && env.ENVIRONMENT == 'production') {
                            env.DESARROLLO = 'frontend-production'
                        } else if (repoName.contains("frontend") && env.ENVIRONMENT == 'development') {
                            env.DESARROLLO = 'frontend-development'
                        } else {
                            error "Repositorio o entorno no reconocido"
                        }
                        echo "Desarrollo configurado: ${env.DESARROLLO}"
                    }
                }
            }
        }
    }
}