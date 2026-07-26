allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// camera_android_camerax's own Android library module doesn't declare a
// direct dependency on androidx.concurrent:concurrent-futures even though
// its compiled camera-core classes reference CallbackToFutureAdapter,
// which fails compilation on newer AGP/javac type-annotation processing.
// `plugins.withId` (unlike `afterEvaluate`) is safe regardless of whether
// this project has already been evaluated by the time it runs.
subprojects {
    if (project.name == "camera_android_camerax") {
        plugins.withId("com.android.library") {
            dependencies.add("implementation", "androidx.concurrent:concurrent-futures:1.2.0")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
