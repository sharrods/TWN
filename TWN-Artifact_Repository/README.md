# Module 6 — Artifact Repository (Nexus)

## What I Built
Deployed a Nexus Repository Manager on a DigitalOcean 
Droplet and configured hosted repositories for Maven 
and npm artifacts. Pushed build artifacts from Module 4 
to Nexus instead of manually copying files.

## Droplet Specs
- Ubuntu 24.04
- 4vCPU / 8GB RAM (Nexus requires more memory)


## Nexus Setup Commands
### Install Java (Nexus requirement)
apt update
apt install openjdk-17-jre-headless

### Download Nexus from sonatype to /opt
wget https://download.sonatype.com/nexus/3/nexus-3.72.0-04-unix.tar.gz
tar -zxvf nexus-3.72.0-04-unix.tar.gz

mv nexus-3* nexus

### Create Nexus service user
adduser nexus
chown -R nexus:nexus /opt/nexus
chown -R nexus:nexus /opt/sonatype-work

### Run Nexus as nexus user
root@ubuntu-s-4vcpu-8gb-nyc1-01:/opt# vim nexus-3.72.0-04/bin/nexus.rc
root@ubuntu-s-4vcpu-8gb-nyc1-01:/opt# cat nexus-3.72.0-04/bin/nexus.rc
#run_as_user="nexus"
nexus@ubuntu-s-4vcpu-8gb-nyc1-01:~$ /opt/nexus-3.72.0-04/bin/nexus start
Starting nexus

### Verify Nexus is running
ps aux | grep nexus
nexus       3412  290  9.5 6590268 776304 pts/0  Sl   00:41   0:59 /usr/lib/jvm/java-17-openjdk-amd64/bin/java -server

### Install net-tools
sudo apt install net-tools
nexus is not in the sudoers file.
usermod -aG sudo nexus
netstat -tlpn | grep 8081
tcp6       0      0 :::8081                 :::*                    LISTEN      3412/java


## Accessing Nexus
- URL: http://143.244.171.154:8081
- Default user: admin
- Initial password location: /opt/sonatype-work/nexus3/admin.password
- Enable anonymous access


### Create nexus user for upload to repository
- user: sharrod
- create nexus roleID: nx-java 
- create role name: nx-java
- create permission for role: nx-java 



### Upload Jar File to existing hosted repo on nexus


### Repository Types Created
| Type | Name | Purpose |
|------|------|---------|
| hosted | maven-releases | Store release JAR artifacts |
| hosted | maven-snapshots | Store snapshot JAR artifacts |
| proxy | maven-central | Proxy for aven Central |
| group | maven-group | Combines all Maven repos |



## Pushing Artifacts to Nexus

### Maven - configure pom.xml distributionManagement
<distributionManagement>
    <repository>
        <id>nexus</id>
        <url>http://<droplet-ip>:8081/repository/maven-releases/</url>
    </repository>
    <snapshotRepository>
        <id>nexus</id>
        <url>http://<droplet-ip>:8081/repository/maven-snapshots/</url>
    </snapshotRepository>
</distributionManagement>

### Maven - configure settings.xml credentials
<servers>
    <server>
        <id>nexus</id>
        <username>admin</username>
        <password>your-password</password>
    </server>
</servers>

### Deploy artifact to Nexus
mvn deploy

### npm - configure registry
npm config set registry http://<droplet-ip>:8081/repository/npm-hosted/
npm publish

## Issues and Resolutions
- [Document any issues you hit and how you fixed them]

## Key Concepts
- Artifact repository as the handoff point between build and deploy
- Snapshot vs Release artifacts — never deploy SNAPSHOT to production
- Repository types: hosted (store), proxy (cache), group (combine)
- Nexus runs as its own service user — principle of least privilege
- Maven settings.xml stores credentials, pom.xml stores repo location
