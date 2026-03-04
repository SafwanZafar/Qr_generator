import com.android.build.gradle.BaseExtension
import org.gradle.api.tasks.Delete

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directory (optional)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Ensure Android namespace is set for all subprojects
subprojects {
    afterEvaluate {
        val androidExt = extensions.findByName("android")
        if (androidExt is BaseExtension) {
            if (androidExt.namespace.isNullOrEmpty()) {
                androidExt.namespace = "com.example.${project.name.replace("-", "_")}"
            }
        }
    }
}

// Force evaluation order if needed
subprojects {
    project.evaluationDependsOn(":app")
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}