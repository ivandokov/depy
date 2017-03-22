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

## Configuration
The initialization creates directory `.depy`. There you will find all configuration files for this project.
The file `.depy/config` is the main file. There you describe your server details, hooks, ignored directories and folders and others.
The file is a simple bash file with variables.

### Servers
To define a server connection you should have a similar block like the one below. The server name is the first part of the variables. For example `production_host` or `staging_host`. All variables are required for a server.
```bash
production_host=192.168.20.20
production_port=22
production_user=ubuntu
production_identity=~/.ssh/id_rsa
production_cwd=/home/ubuntu/website
```

### Hooks
The hooks are bash scripts which are executed in a specific moment of the deployment process and are located in `.depy/hooks/`.  
```bash 
pre_hooks=(
    pre
)
```
**pre_hooks** are executed locally in the project directory before the actual deployment process. They are great place to make sure that you are not deploying broken code to the server. You can use them to execute tests, builds, etc.
If any of the hooks exit with code different than 0 (error) the deployment process will be canceled and marked as failed.  

```bash
remote_hooks=(
    remote
)
```
**remote_hooks** are executed on the server in the release folder before the linking of the release as current. These hooks are used to install dependencies, make builds and clean up work on the server. If any of the hooks exit with code different than 0 (error) the deployment process will be canceled and marked as failed.  

```bash
post_hooks=(
    post
)
```
**post_hooks** are executed locally in the project directory after the actual deployment process. These hooks are used for clean up work, announcing deploy status (for example in a Slack channel), etc. If any of the hooks exit with code different than 0 (error) the deployment process will be marked as failed, but cannot be canceled because the remote stuff are already done.

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
keep_releases=4
```
**keep_releases** is the count of releases to keep on the server which can be used for rollback

## Usage
Depy comes with bash autocompletion for easier usage.

### Init
`depy init` - create the required configuration files in .depy directory. This is the only argument which does not require to specify target server.

### Setup
`depy setup [TARGET]` - create required directories structure on the remote server.

### Deploy
`depy deploy [TARGET] [-i|--incremental]`
1) runs pre hooks locally. If any of the hooks fails* the deployment is cancelled and marked as failed
2) transfer files to the target server
3) runs remote hooks. If any of the hooks fails (exit with status other than 0) the deployment is cancelled and marked as failed. The failed release will be deleted
4) linking release to be the current / active release
5) clean up old releases on the target server
6) runs post hooks locally. If any of the hooks fails* the deployment marked as failed, but the deployment is successful and release is not deleted

`-i|--incremental` flag will change the deployment flow to incremental. It will duplicate the latest release on the server and upload only the changes using rsync. This will decrease the deployment time for larger projects.

### Releases
`depy releases [TARGET]` - list all existing releases on the target server

### Rollback
`depy rollback [TARGET] [RELEASE]` - rollback to the specified release on the target server

### Pack
`depy pack` - create package with the files to be deployed. This can be used for manual deployment

### Update
`depy update [--beta|--dev]` - updates Depy to the latest stable version. If --beta is specified the updater will download the latest beta version. If --dev version is specified the updated will download the latest development version

### Verbose mode
You can specify `-v|--verbose` flag for all arguments to enable verbose mode and see detailed information about the process. 