plugins {
    java
    id("org.springframework.boot") version "3.3.2"
    id("io.spring.dependency-management") version "1.1.6"
    id("org.sonarqube") version "4.4.1.3373"
}

group = "com.dolharubang"
version = "0.0.1-SNAPSHOT"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(17)
    }
}

configurations {
    compileOnly {
        extendsFrom(configurations.annotationProcessor.get())
    }
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.springframework.boot:spring-boot-starter-data-mongodb")
    implementation("org.springframework.boot:spring-boot-starter-jdbc")
    implementation("org.springframework.boot:spring-boot-starter-thymeleaf")
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-web-services")
    compileOnly("org.projectlombok:lombok")
    developmentOnly("org.springframework.boot:spring-boot-devtools")
    runtimeOnly("org.mariadb.jdbc:mariadb-java-client")
    annotationProcessor("org.projectlombok:lombok")
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.0.2")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("io.micrometer:micrometer-registry-prometheus")
    implementation ("org.bgee.log4jdbc-log4j2:log4jdbc-log4j2-jdbc4.1:1.16")
//    implementation("org.springframework.security:spring-security-oauth2-client:6.3.3")
//    implementation("org.springframework.boot:spring-boot-starter-security:3.3.4")

    implementation("io.awspring.cloud:spring-cloud-starter-aws:2.4.4")
    compileOnly ("org.springframework.cloud:spring-cloud-starter-aws:2.0.2.RELEASE")
    implementation (platform("com.amazonaws:aws-java-sdk-bom:1.11.228"))
    implementation ("com.amazonaws:aws-java-sdk-s3")
    implementation ("commons-io:commons-io:2.7")
    implementation ("net.coobird:thumbnailator:0.4.14")
}

configurations.all {
    exclude(group = "commons-logging")
}

sonarqube {
    properties {
        property("sonar.projectKey", "dolharubang-backend")
        property("sonar.projectName", "dolharubang-backend")
    }
}

tasks.withType<Test> {
    useJUnitPlatform()
}
