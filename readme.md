# Depy
### Simple and dependency free deployment tool.  
Written in bash 4 the tool does not have any dependencies except `ssh` and `rsync` which are basic tools for any *nix OS and Windows 10 with Ubuntu.
 
All you need is to download `depy` file and place it in a directory which is in your `$PATH`. For Ubuntu and macOS the directory `/usr/local/bin` is perfect for this case. You can do it easily with:
 
 ```bash
wget -q https://raw.githubusercontent.com/ivandokov/depy/master/depy; sudo mv depy /usr/local/bin/depy
```

## Usage

Initialize depy for current directory / project.
```bash
depy init
```

Setup server with name `<server>`
```bash
depy setup <server>
```

Deploy to server with name `<server>`
```bash
depy deploy <server>
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
**ignores** holds the directories and files which will be excluded from the deploying process. They will not be uploaded to the server.

```bash
shared=(
    logs
)
```
**shared** holds the directories and files which will be shared between all releases. After the first release the shared directories and files will be moved to `shared` directory on the server and a symlink will be created for each one to the release directory. All other releases will **remove these files and directories** and will use symlink to the `shared` directory.