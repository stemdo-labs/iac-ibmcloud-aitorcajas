def call() {
    if (env.GIT_BRANCH == 'origin/main') {
        env.ENVIRONMENT = 'production'
    } else if (env.GIT_BRANCH == 'origin/develop') {
        env.ENVIRONMENT = 'development'
    }
    return env.ENVIRONMENT
}