def call(String entorno) {
    pipeline {
        agent any

        stages {
            stage('Definir Entorno') {
                steps {
                    script {
                    echo "El entorno es: ${entorno}"
                    // Lógica para ejecutar según el entorno
                    if (entorno == 'production') {
                        echo "Ejecutando en producción"
                    } else if (entorno == 'development') {
                        echo "Ejecutando en desarrollo"
                    }
                    }
                }
            }
        }
    }
}
