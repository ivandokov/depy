# Depy
### Simple and nearly dependency free deployment tool.  
Written in `bash` the tool does not have any major dependencies. Everything you need to have installed locally is:
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
The initialization creates `.depy` directory. There you will find all configuration files and hooks.
The file `.depy/config` is the main file. There you describe your server details, hooks, ignored files and folders and others. The file is a simple bash file with variables.

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

#### Pre hooks
```bash 
pre_hooks=(
    pre
)
```
They are executed locally in the project directory before the actual deployment process. They are great place to make sure that you are not deploying broken code to the server. You can use them to execute tests, builds, etc.
If any of the hooks exit with code different than 0 (error) the deployment process will be canceled and marked as failed.

#### Remote hooks 
```bash
remote_hooks=(
    remote
)
``` 
They are executed on the server in the release folder before the linking of the release as current. These hooks are used to install dependencies, make builds and clean up work on the server. If any of the hooks exit with code different than 0 (error) the deployment process will be canceled and marked as failed.

Each hook receives one parameter which is the directory name of the release so if you want to run code on the release you have to `cd "$1"`.

#### Post hooks
```bash
post_hooks=(
    post
)
```
They are executed locally in the project directory after the actual deployment process. These hooks are used for clean up work, announcing deploy status (for example in a Slack channel), etc. If any of the hooks exit with code different than 0 (error) the deployment process will be marked as failed, but cannot be canceled because the remote stuff are already done.

### Ignores
```bash
ignores=(
    "*.git*"
)
```
This array holds the files and folders which will be excluded from the deploying process. They will not be uploaded to the server.  
**Important** the supported patterns can be found in zip documentation at https://linux.die.net/man/1/zip for `--exclude` argument. The regex matching is a tricky and we suggest using `depy pack-list` to see which files will be packed for the release.

### Shared
```bash
shared=(
    logs
)
```
This array holds the files and folders which will be shared between all releases. After the first release the shared files and folders will be moved to `shared` directory on the server and symlinks will be created for each one to the release directories. All other releases will **remove these files and folders** and will use symlinks to the `shared` directory.

### Keep releases
```bash
keep_releases=4
```
This is the count of releases to keep on the server which can be used for rollback.

## Usage
Depy comes with bash autocompletion for easier usage.

### init
`depy init` - create the required configuration files in `.depy` directory.

### setup
`depy setup [TARGET]` - create required folders structure on the specified server.

### deploy
`depy deploy [TARGET] [-i|--incremental]`
1) runs pre hooks locally. If any of the hooks fails (exit with status other than 0) the deployment is cancelled and marked as failed
2) transfer files to the target server
3) runs remote hooks. If any of the hooks fails (exit with status other than 0) the deployment is cancelled and marked as failed. The failed release will be deleted
4) linking release to be the current / active release
5) clean up old releases on the target server
6) runs post hooks locally. If any of the hooks fails* the deployment marked as failed, but the deployment is successful and release is not deleted

`-i|--incremental` flag will change the deployment flow to incremental. It will duplicate the latest release on the server and upload only the changes using rsync. This will decrease the deployment time for larger projects.

### releases
`depy releases [TARGET]` - list all existing releases on the target server.

### rollback
`depy rollback [TARGET] [RELEASE]` - rollback to the specified release on the target server.

### pack
`depy pack` - create package with the files to be deployed. This can be used for manual deployment.

### pack-list
`depy pack-list` - list all files and directories which will be part of the package for deployment. This can be used for testing ignore directives.

### update
`depy update [--beta|--dev]` - updates Depy to the latest stable version. If --beta is specified the updater will download the latest beta version. If --dev version is specified the updated will download the latest development version.

### Verbose mode
You can specify `-v|--verbose` flag for all arguments to enable verbose mode and see detailed information about the process. 