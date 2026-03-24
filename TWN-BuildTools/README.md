# Build Tols and Package Manager 





# Installing Build Tools
# Hombrew and Intellij previously installed before this module 
# Git was already installed
# Tools used for this module 
mvn, gradle, npm , yarn 


# Apps Added from Repo

### Downloaded the appps from TWN Repo and cloned them locally

Using intellij opened project java-maven-app

### JDk was not configured. 

❯ java -version
openjdk version "17.0.18" 2026-01-20
OpenJDK Runtime Environment Homebrew (build 17.0.18+0)
OpenJDK 64-Bit Server VM Homebrew (build 17.0.18+0, mixed mode, sharing)


### Maven Install 
mvn -v
Apache Maven 3.9.11 (3e54c93a704957b63ee3494413a2b544fd3d825b)
Maven home: /usr/local/Cellar/maven/3.9.11/libexec
Java version: 17.0.18, vendor: Homebrew, runtime: /usr/local/Cellar/openjdk@17/17.0.18/libexec/openjdk.jdk/Contents/Home
Default locale: en_US, platform encoding: UTF-8
OS name: "mac os x", version: "15.2", arch: "x86_64", family: "mac"


mvn install
[INFO] Scanning for projects...
[INFO] 
[INFO] ---------------------< com.example:java-maven-app >---------------------
[INFO] Building java-maven-app 1.1.0-SNAPSHOT
[INFO]   from pom.xml
[INFO] --------------------------------[ jar ]---------------------------------
[INFO] 
[INFO] --- resources:3.3.1:resources (default-resources) @ java-maven-app ---
[WARNING] Using platform encoding (UTF-8 actually) to copy filtered resources, i.e. build is platform dependent!
[INFO] Copying 1 resource from src/main/resources to target/classes
[INFO] 
[INFO] --- compiler:3.11.0:compile (default-compile) @ java-maven-app ---
[INFO] Nothing to compile - all classes are up to date
[INFO] 
[INFO] --- resources:3.3.1:testResources (default-testResources) @ java-maven-app ---
[WARNING] Using platform encoding (UTF-8 actually) to copy filtered resources, i.e. build is platform dependent!
[INFO] skip non existing resourceDirectory /Users/sharrods/Documents/Techworld-with-nana/TWN-BuildTools/java-maven-app/src/test/resources
[INFO] 
[INFO] --- compiler:3.11.0:testCompile (default-testCompile) @ java-maven-app ---
[INFO] No sources to compile
[INFO] 
[INFO] --- surefire:3.2.5:test (default-test) @ java-maven-app ---
[INFO] No tests to run.
[INFO] 
[INFO] --- jar:3.4.1:jar (default-jar) @ java-maven-app ---
[INFO] 
[INFO] --- spring-boot:3.0.5:repackage (default) @ java-maven-app ---
[INFO] Replacing main artifact with repackaged archive
[INFO] 
[INFO] --- install:3.1.2:install (default-install) @ java-maven-app ---
[INFO] Installing /Users/sharrods/Documents/Techworld-with-nana/TWN-BuildTools/java-maven-app/pom.xml to /Users/sharrods/.m2/repository/com/example/java-maven-app/1.1.0-SNAPSHOT/java-maven-app-1.1.0-SNAPSHOT.pom
[INFO] Installing /Users/sharrods/Documents/Techworld-with-nana/TWN-BuildTools/java-maven-app/target/java-maven-app-1.1.0-SNAPSHOT.jar to /Users/sharrods/.m2/repository/com/example/java-maven-app/1.1.0-SNAPSHOT/java-maven-app-1.1.0-SNAPSHOT.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  2.190 s
[INFO] Finished at: 2026-03-24T12:37:47-06:00
[INFO] -----------------------------------------------------------------------


### Gradle Install
gradle -v

------------------------------------------------------------
Gradle 8.14.4
------------------------------------------------------------

Build time:    2026-01-23 16:30:23 UTC
Revision:      ad5ff774b4b0e9a8a0cf1a14ca70d7230003c3ad

Kotlin:        2.0.21
Groovy:        3.0.25
Ant:           Apache Ant(TM) version 1.10.15 compiled on August 25 2024
Launcher JVM:  17.0.18 (Homebrew 17.0.18+0)
Daemon JVM:    /usr/local/Cellar/openjdk@17/17.0.18/libexec/openjdk.jdk/Contents/Home (no JDK specified, using current Java home)
OS:            Mac OS X 15.2 x86_64


### Gradle Build Success

gradle build
Starting a Gradle Daemon (subsequent builds will be faster)

[Incubating] Problems report is available at: file:///Users/sharrods/Documents/Techworld-with-nana/TWN-BuildTools/java-app/build/reports/problems/problems-report.html

Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0.

You can use '--warning-mode all' to show the individual deprecation warnings and determine if they come from your own scripts or plugins.

For more on this, please refer to https://docs.gradle.org/8.14.4/userguide/command_line_interface.html#sec:command_line_warnings in the Gradle documentation.

BUILD SUCCESSFUL in 13s
5 actionable tasks: 5 up-to-date


### React Nodejs Exmaple
### Needed node and NPM 

❯ npm -v
11.6.2
❯ node -v
v25.2.1


❯ npm start

> react-nodejs-example@1.0.0 start
> node server.bundle.js

Server listening on the port::3080


### Build javascript artifact with npm 
❯ npm pack
npm warn gitignore-fallback No .npmignore file found, using .gitignore for file exclusion. Consider creating a .npmignore file to explicitly control published files.
npm warn gitignore-fallback No .npmignore file found, using .gitignore for file exclusion. Consider creating a .npmignore file to explicitly control published files.
npm notice
npm notice 📦  nodejs-app@1.0.0
npm notice Tarball Contents
npm notice 155B Dockerfile
npm notice 92B Readme.md
npm notice 586B app/server.js
npm notice 789B nodejs-app-1.0.0.tgz
npm notice 313B package.json
npm notice Tarball Details
npm notice name: nodejs-app
npm notice version: 1.0.0
npm notice filename: nodejs-app-1.0.0.tgz
npm notice package size: 1.7 kB
npm notice unpacked size: 1.9 kB
npm notice shasum: 021618e28999f4e544e8ae97faacef2b3285c3cc
npm notice integrity: sha512-AKTbfLJL6Aoja[...]0Kf3edkLwTeRA==
npm notice total files: 5
npm notice
nodejs-app-1.0.0.tgz


 


