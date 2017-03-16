# Depy
### Simple and nearly dependency free deployment tool.  
Written in bash 4 the tool does not have any major dependencies. Everything you need to have installed locally is:
 * `git` (*download the project and for updates*)
 * `ssh` (*communicate with the server*)
 * `rsync` (*transfer files*)
 * `zip` (*pack releases*)

On the server you need to have:
* `unzip` (unpack releases)

These are basic tools which you probably have installed already on your system.

## Installation
 ```bash
git clone https://github.com/ivandokov/depy.git
cd depy
./install
```

## Usage
```
SYNOPSIS
    depy [ARGUMENT] [TARGET]

ARGUMENTS
    init
        create the required configuration files in .depy directory. This is the only argument which does not require to specify target server.

    setup [TARGET]
        create required directories structure on the remote server.

    deploy [TARGET] [-i|--incremental]
        1) runs pre hooks locally. If any of the hooks fails* the deployment is cancelled and marked as failed
        2) transfer files to the target server
        3) runs remote hooks. If any of the hooks fails* the deployment is cancelled and marked as failed. The failed release will be deleted
        4) linking release to be the current / active release
        5) clean up old releases on the target server
        6) runs post hooks locally. If any of the hooks fails* the deployment marked as failed, but the deployment is successful and release is not deleted
        * exit with status other than 0
        
        -i|--incremental flag will change the deployment process. It will duplicate the latest release on the server and upload only the changes. This will decrease the deployment time
        
    releases [TARGET]
        list all existing releases on the target server

    rollback [TARGET] [RELEASE]
        rollback to the specified release on the target server

    pack
        create package with the files to be deployed. This can be used for manual deployment
        
    
    You can specify -v|--verbose flag to enable verbose mode and see detailed information about the process. 
```

## Configuration
The initialization creates directory `.depy`. There you will find all configuration files for this project.
The file `.depy/config` is the main file. There you describe your server details, hooks ignored directories and folders and others.
The file is a simple bash file and most of the variables are bash arrays. Since bash doesn't have good support for nested structures some of the configurations are a little bit weird.

### Servers
In this array you should describe all the servers which you will use for deployment. Then array is self explanatory.
```bash
servers=(
    [production.host]=192.168.20.20
    [production.port]=22
    [production.user]=ubuntu
    [production.identity]=~/.ssh/id_rsa
    [production.cwd]=/home/ubuntu/test
)
```

### Hooks
The hooks are bash scripts which are executed in a specific moment of the deployment process and are located in `.depy/hooks/`.  
```bash 
preHooks=(
    pre
)
```
**preHooks** are executed locally in the project directory before the actual deployment process. They are great place to make sure that you are not deploying broken code to the server. You can use them to execute tests, builds, etc.
If any of the hooks exit with code different than 0 (error) the deployment process will be canceled and marked as failed.  

```bash
remoteHooks=(
    remote
)
```
**remoteHooks** are executed on the server in the release folder before the linking of the release as current. These hooks are used to install dependencies, make builds and clean up work on the server. If any of the hooks exit with code different than 0 (error) the deployment process will be canceled and marked as failed.  

```bash
postHooks=(
    post
)
```
**postHooks** are executed locally in the project directory after the actual deployment process. These hooks are used for clean up work, announcing deploy status (for example in a Slack channel), etc. If any of the hooks exit with code different than 0 (error) the deployment process will be marked as failed, but cannot be canceled because the remote stuff are already done.

```bash
ignores=(
    .git
    .gitignore
)
```
**ignores** holds the directories and files which will be excluded from the deploying process. They will not be uploaded to the server. **Important** the supported patterns can be found in zip documentation at https://linux.die.net/man/1/zip for --exclude argument

```bash
shared=(
    logs
)
```
**shared** holds the directories and files which will be shared between all releases. After the first release the shared directories and files will be moved to `shared` directory on the server and a symlink will be created for each one to the release directory. All other releases will **remove these files and directories** and will use symlink to the `shared` directory.

```bash
keepReleases=4
```
**keepReleases** is the count of releases to keep on the server which can be used for rollback
 
 ## License
 
MIT License

Copyright (c) 2017 Ivan Dokov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
