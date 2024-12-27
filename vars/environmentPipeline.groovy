// vars/environmentPipeline.groovy
def call() {
    whoami
    // Obtener la rama y definir el entorno
    def branch = env.BRANCH_NAME ?: 'main' // Si no hay BRANCH_NAME, se asume 'main'
    
    def entorno = ''
    if (branch == 'main') {
        entorno = 'production'
    } else if (branch == 'develop') {
        entorno = 'development'
    } else {
        entorno = 'unknown'
    }

    // Establecer el entorno como una variable de entorno
    env.ENVIRONMENT = entorno
    echo "Entorno definido: ${env.ENVIRONMENT}"
    return env.ENVIRONMENT
}
