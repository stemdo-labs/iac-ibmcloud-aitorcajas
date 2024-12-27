def call(Map pipelineParams) {
    pipeline {
        agent any

        environment {
            GITHUB_REF = env.BRANCH_NAME
        }

        stages {
            stage('Definir Entorno') {
                steps {
                    script {
                        if (GITHUB_REF == 'main') {
                            env.ENVIRONMENT = 'production'
                        } else if (GITHUB_REF == 'develop') {
                            env.ENVIRONMENT = 'development'
                        } else {
                            error "Branch no reconocido: ${GITHUB_REF}"
                        }
                        echo "Entorno definido: ${env.ENVIRONMENT}"
                    }
                }
            }

            stage('Checkout del Repositorio') {
                steps {
                    checkout scm
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