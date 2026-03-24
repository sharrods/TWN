# TWN-DigitalOcean


# Module 5 — Cloud & DigitalOcean

## What I Built
Provisioned a DigitalOcean Droplet and deployed a 
Java application artifact built from Module 4.

## Droplet Specs
- Ubuntu 24.04
- 1CPU / 512 MB RAM

## Commands Used

### Create and connect to Droplet
ssh digitalocean1

### Install Java
root@ubuntu-s-1vcpu-512mb-10gb-nyc1-01:~# apt update
root@ubuntu-s-1vcpu-512mb-10gb-nyc1-01:~# apt install openjdk-17-jre-headless

root@ubuntu-s-1vcpu-512mb-10gb-nyc1-01:~# java --version
openjdk 17.0.18 2026-01-20
OpenJDK Runtime Environment (build 17.0.18+8-Ubuntu-124.04.1)
OpenJDK 64-Bit Server VM (build 17.0.18+8-Ubuntu-124.04.1, mixed mode, sharing)


### Copy JAR to server
scp java-react-example.jar digitalocean1:/root

############################## 
Run JAR file on Remote server
#############################

java -jar java-react-example.jar
root@ubuntu-s-1vcpu-512mb-10gb-nyc1-01:~# java -jar java-react-example.jar

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::               (v2.7.11)

2026-03-24 21:49:35.664  INFO 2977 --- [           main] com.coditorium.sandbox.Application       : Starting Application using Java 17.0.18 on ubuntu-s-1vcpu-512mb-10gb-nyc1-01 with PID 2977 (/root/java-react-example.jar started by root in /root)

026-03-24 21:49:40.606  INFO 2977 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port(s): 7071 (http) with context path ''

#################################
ISSUES
################################
- Tried to connect to port 7071 but was unable. 
- Checked netstat -tulpn | grep 7071 
    - RESOLVED  mapped wrong ip to name in my local laptop. 
- ssh-key configuration issue couldn't login as local user I created
    - RESOLVED have to pass -i and key + private (local) to Public (remote) 
- Private key (local) authenticates against Public key (remote server authorized_keys)
- Public vs Private key — private key stays local, public key lives on remote server
################################
Create User
################################
adduser sskinner
usermod -aG sudo sskinner
skinner@ubuntu-s-1vcpu-512mb-10gb-nyc1-01:~$
Created .ssh/authorized_keys folder 
Change folder permssions to .ssh=700; .ssh/authorized_keys=600


## Key Concepts
- Manual cloud provisioning
- Remote artifact deployment
- SSH-based server access
- netstat -lpnt (listening on internet)  
