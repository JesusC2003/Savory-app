allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configurar buildDir sin espacios problemáticos
val buildDirPath = "C:/temp/savory-build"

val newBuildDir: Directory = layout.buildDirectory
    .dir("../../$buildDirPath")
    .get()
    
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = layout.buildDirectory
        .dir("../../$buildDirPath/${project.name}")
        .get()
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}