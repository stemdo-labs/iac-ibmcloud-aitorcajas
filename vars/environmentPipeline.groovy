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
            }

            stage('Extraer Desarrollo') {
                steps {
                    script {
                        def pipelineName = sh(script: "basename \$(git rev-parse --show-toplevel)", returnStdout: true).trim()
                        echo "Nombre de la pipeline: ${repoName}"
                        if (repoName.contains("backend") && env.ENVIRONMENT == 'production') {
                            env.DESARROLLO = 'backend-production'
                        } else if (repoName.contains("backend") && env.ENVIRONMENT == 'development') {
                            env.DESARROLLO = 'backend-development'
                        } else if (repoName.contains("frontend") && env.ENVIRONMENT == 'production') {
                            env.DESARROLLO = 'frontend-production'
                        } else if (repoName.contains("frontend") && env.ENVIRONMENT == 'development') {
                            env.DESARROLLO = 'frontend-development'
                        }
                        echo "Desarrollo configurado: ${env.DESARROLLO}"
                    }
                }
            }
        }
    }
}