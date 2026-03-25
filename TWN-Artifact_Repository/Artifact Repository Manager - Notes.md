---
created: 2026-03-09 08:17
updated: 2026-03-09
aliases:
up:
  - "[[TWN - Table Of Conents]]"
related:
source:
tags:
  - "#on/twn"
  - "#on/devops"
  - "#on/Artifact"
  - "#on/docker"
summary:
  - Artifact Repo Notes
status:
---
## Notes

### Repository Manager

- Multiple file types support 
	- Nexus 
	- Maven
	- Jfrog
	- NPM
- The idea to remember is that it makes sense to have a repo manager so it can store specific type of files. Help consolidate artifacts in one place. 


![[Screenshot 2026-03-09 at 8.22.23 AM.png]]



### Clean-up Policies 
- Should be implemented. 
- API for provisioning and automation 
- Important when on teams. 

### CI / CD Steps 


![[Screenshot 2026-03-09 at 8.25.44 AM.png]]


---
## Artifact Types
### Repository Types
- Each Produce different artifact types
- You need different repositories of all of them 
- Different Software for Each 

---
## Nexus 
### Repository Manager
- no need for different types
- Centralized for all types 
- Host your own repositories in nexus 
- Proxy for Public repositories 
	- Why would you want Proxy ?
		- Consolitate all of artifact management in one spot public, and private. 
- Available as opensource for free. 
- Proxy - you can make public repositories appear to be local or central
- Helm charts
### Integration with LDAP
- Integrate with LDAP and add permissions

### Flexible and power REST APPI for integration with other tools 


### Backup and Restore 
- Natively has storage for backup/restore
- Multi-format suppport (different file types - zip, tar, docker etc)
- Metadata tagging (labelling and tagging artigfacts)

### Cleanup Policies
- manage space automatically with lifecycle policies
	- Match conditions to automate cleanup

### Search functionality 

### User token support for system user authentication 
- system user support using tokens 

### Create own Repositories 
- Create repositories for the type you need 

---
## Install Nexus on remote server

Go to sonatype using install nexus and find file to download
copy link address 
In Remote server use wget to pull into /opt/ folder on remote server
```php
wget https://download.sonatype.com/nexus/3/nexus-3.72.0-04-unix.tar.gz
tar -zxvf nexus-3.72.0-04-unix.tar.gz
```

### Sonatype work and Nexus folders created
- Sonatype-work - data
	- You can backup this folder to get data back. 
- Nexus - Contains the runtime and application of nexus itself
	- Has the binaries to start nexus application and sonotype work
- allows you to update the binaries of nexus but still have the data in sonatype-work


---
## Repositories
### Types
- Proxy - repository that is linked to a public repository 
	- First check if component is local
		- If not go through proxy to retrieve component 
		- Nexus will act as a cache after getting components from remote. 
		- Next request will get it locally from cache 
			- This saves time 
	- Gives single repository endpoint
		- Gives you version control 
- Group - If you need multiple of the same type of repository you can group them behind single endpoint. 
	- Allows you to combine multiple repositories in a single Repo.  Single URL
- Hosted - Primary storage for  artifacts and components that for example the company owned 
	- Internal components 
	- Specific Releases - Production releases should go here after tested
		- Sometimes used by third-party releases that may not be externally available. "Company Internal " but 3rd party. 
	- Specific SnapShots - Development Versions go here and get tested. 


> [!Hint] Setup DEFAULT remote repositories for that specific repository type

maven global credentials are stored in .m2 folder on local user directory .m2 folder

---
## Nexus API 

#### How to access REST endpoint ?
- curl
- wget

``` lua
curl -u user:pwd -X GET 'http://143.244.171.154:8081/service/rest/v1/repositories'
```

---
## Blob Stores

### Types
- File system-based storage = File system is default. 
- Cloud based storage = S3 etc
- Blob store = physical storage layer, survives Nexus upgrades
### State 
State field = state of the blob store 
- Started --> Running as expected
- Failed --> Configuration issue , failed to initialize 
- Block count show number of blob currently stored

> [!Alert] ** Once a blob store is created it cannot be deleted !!
#### Location of blob stores on server 

```
/opt/sonatype-work/nexus3/blobs/default/content
```

### Consideration to take in to account
- How man blob stores will you create? 
- Which Size
- Which ones will be used for what 

---
## Component vs Asset
- Components = TopLevel of App. What we are uploading
- Assets = Physical packages or files that we are uploading 

- Component = logical artifact (name + version)
- Asset = physical files that make up a component (.jar, .pom, checksums)


### Docker 
- Components = Layers

---
## Clean up Policies 
- These help with lifecycle management and to clean up old snapshots
- Manage Space so that it doesn't fill up the drive cause issues
- Cleanup policies = automate artifact lifecycle, prevent disk fill
### Options
- Cleanup Days - Component Age
- Usage - Component Usage
- Repository 

When doing snapshot and removing from blob store just because your clean up job removes the component does not mean your blobs are removed. 
Check Blob stores to see.  Blob Count should show 0 but it wont you will need to run compact and then go to the cli to check 

![[Screenshot 2026-03-25 at 12.06.43 PM.png]]

```
root@ubuntu-s-4vcpu-8gb-nyc1-01:/opt/sonatype-work/nexus3/blobs/default/content# ls -l vol-39/chap-16/
total 0

```


