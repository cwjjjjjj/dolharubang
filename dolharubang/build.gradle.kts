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
    implementation("org.bgee.log4jdbc-log4j2:log4jdbc-log4j2-jdbc4.1:1.16")
    implementation("org.springframework.boot:spring-boot-starter-oauth2-client")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("io.awspring.cloud:spring-cloud-starter-aws:2.4.4")
    implementation("commons-io:commons-io:2.7")
    testImplementation("org.springframework.security:spring-security-test")
    implementation("com.auth0:java-jwt:3.19.2")
    implementation("com.google.code.gson:gson:2.8.9")
    implementation("io.jsonwebtoken:jjwt-api:0.11.5")
    implementation("io.jsonwebtoken:jjwt-impl:0.11.5")
    implementation("io.jsonwebtoken:jjwt-jackson:0.11.5")
    implementation("io.jsonwebtoken:jjwt:0.9.1")
    implementation("org.springframework.security:spring-security-jwt:1.1.1.RELEASE")
    implementation("com.nimbusds:nimbus-jose-jwt:9.23")
    implementation("org.springframework.boot:spring-boot-starter-thymeleaf")
    implementation ("org.bouncycastle:bcpkix-jdk18on:1.72")

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
}
