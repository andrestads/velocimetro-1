// Top-level build file where you can add configuration options common to all sub-projects/modules.

plugins {
    // Android Gradle Plugin (AGP) - Versão 8.1.0 ou superior para compatibilidade
    // Removendo a versão explícita para evitar conflito com a 8.7.0 que já está no classpath.
    id("com.android.application") apply false
    id("com.android.library") apply false
    // Kotlin plugin
    kotlin("android") apply false
}

// Configuração do diretório de build (mantida a sua lógica original)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Task para limpar os arquivos de build
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
