---
created: 2026-03-06 07:40
updated: 2026-03-06
aliases:
up:
  - "[[TWN - Table Of Conents]]"
related:
source:
tags:
summary:
  - Build tool 
status:
---

## Backend and Fronend
- [.] Frontend = React
- [x] Backend = NodeJs, Python , Java
- [ ] 
## Build Tools and Package Manager Tools
- JAR or WAR files are packaged files. 
- Artifacts are files that contain all code and libraries needed. 
### Package using npm
- You can package the package.json with the artifcat 
```json
npm pack
```

- NPM and Yarn can do dependency management. 
- It will create a tar.gz file 
- NPM is not a build tool but it will pack into a tart zip file. 

### Run a javascript locally 
- You can run java script applicatioin locally using 
```json
npm start 
```

- Seperate frontend package.json and frontend packa.json. This helps to make it quicker. 

## How to download automatcially 

- Use the "^" to Install version 4.x but not 5.x 

![[Screenshot 2026-03-06 at 7.48.39 AM.png]]


## Webpack Tool
- Bundle javascript
- Build both frontend and backend. 



---
# 10 - Common Concepts and Differences of Build Tools

## Patterns in all these tools

- Dependency File
	- package.json
	- pom.xml
	- build.gradle
- Repository for dependencies 
	- 
- Command line tool
	- test
	- start app
	- build app
- Package managers


---
# Publish an Artifact

## 
- Need to push to artifact repository. Most tools have commands to push directly to repo. 
- Publishing an Artifcat 
- 
## Docker and artifacts 
### Publishing was made easier by using docker. 
- packages everything 
- no zip file or packet.json 
- docker images are artifacts as well just easier 
- now artifacts that don't have to seperate type
- no need to use jar or npm so you don't need them you can just use the image for docker. 

#### You still need to build the image when using docker. 
![[Screenshot 2026-03-06 at 8.07.57 AM.png]]

