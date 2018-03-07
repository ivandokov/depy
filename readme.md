# Depy
### Simple and nearly dependency free deployment tool.  
Written in `bash`* the tool does not have any major dependencies. Everything you need to have installed locally is:
 * `git` (*download Depy and for updates*)
 * `ssh` (*communicate with the server*)
 * `rsync` (*transfer files*)
 * `zip` (*pack releases*)

On the server you need to have:
* `unzip` (unpack releases)


***\* Bash version 4.\* is required. Version 3 is not currently supported.***

These are basic tools which you probably have installed already on your system.

## Installation
 ```bash
git clone https://github.com/ivandokov/depy.git /opt/depy
cd /opt/depy
./install
```

## Configuration
The initialization creates multiple files in the current directory. The main configuration and **only mandatory file** is `.depy`. There you define your server connection details and other deployment configurations.

### Servers
To define a server connection you should have a similar block like the one below. The server name is the first part of the variables. For example `production_host` or `staging_host`. All variables are required for a server.
```bash
production_host=192.168.20.20
production_port=22
production_user=ubuntu
production_key=~/.ssh/id_rsa
production_dir=/home/ubuntu/website
```

### Deploy target
Specify the directory which you want to deploy. By default it is the current directory. In case you need to deploy a specific directory, for example if you are using Angular and you have to deploy the `dist` directory this is the variable to change.
```bash
deploy_target=./
```

### Keep releases
```bash
keep_releases=4
```
This is the count of releases to keep on the server which can be used for rollback.

### Shared
```bash
shared=(
    logs
)
```
This array holds the files and folders which will be shared between all releases. After the first release the shared files and folders will be moved to `shared` directory on the server and symlinks will be created for each one to the release directories. All other releases will **remove these files and folders** and will use symlinks to the `shared` directory.
**Note**: Currently there is a limitation. The shared files and folders must be a top level. Nested ones are not working properly.

### Hooks
The hooks are bash scripts which are executed in a specific moment of the deployment process and are with specific names.

#### Pre hook
```bash 
.depy-pre.sh
```
This is an **optional** script that is executed locally in the project directory before the actual deployment process. It is a great place to make sure that you are not deploying broken code to the server. You can use it to execute tests, builds, etc.
If the hook exit with code different than 0 (error) the deployment process will be canceled and marked as failed.

These hook receives the following arguments:
* `$1` - the release name
* `$2` - 0 for full release, 1 for incremental

#### Remote hook
```bash
.depy-remote.sh
``` 
This is an **optional** script that is executed on the server in the new release folder before the linking of the release as current. This hook is used to install dependencies, make builds and for clean up work on the server. If the hook exit with code different than 0 (error) the deployment process will be canceled and marked as failed.

The hook receives the following arguments:
* `$1` - 0 for full release, 1 for incremental

#### Post hook
```bash
.depy-post.sh
```
This is an **optional** script that is executed locally in the project directory after the actual deployment process. This hook is used for clean up work, announcing deploy status (for example in a Slack channel), etc. If the hook exit with code different than 0 (error) the deployment process will be marked as failed, but cannot be canceled because the remote stuff are already done.

The hook receives the following arguments:
* `$1` - the release name
* `$2` - 0 for full release, 1 for incremental


### Ignores
```bash
.depyignore
```
This is an optional file that holds list of files and folders which will be excluded from the deploying process. They will not be uploaded to the server.
**Important** - the supported patterns can be found in zip documentation at https://linux.die.net/man/1/zip for `--exclude` argument. The regex matching is a tricky and we suggest using `depy pack-list` to see which files will be packed for the release.

## Usage
Depy comes with bash autocompletion for easier usage.

### init
`depy init` - create the required configuration files in `depy` directory.

### setup
`depy setup [TARGET]` - create required folders structure on the specified server.

### deploy
`depy deploy [TARGET] [-i|--incremental]`
1) runs pre hook locally. If the hook fails (exit with status other than 0) the deployment is cancelled and marked as failed
2) transfer files to the target server
3) runs remote hook. If the hook fails (exit with status other than 0) the deployment is cancelled and marked as failed. The failed release will be deleted
4) linking release to be the current / active release
5) clean up old releases on the target server
6) runs post hook locally. If the hook fails* the deployment marked as failed, but the deployment is successful and release is not deleted

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
You can specify `-v|--verbose` flag for all arguments to enable verbose mode and see detailed information about the process. `-vv|--vverbose` increases the verbosity of the output.

## Development
If you want to help us make Depy better you can use the development demo project from our [depy-dev](https://github.com/ivandokov/depy-dev) repository. There you will find Vagrantfile used to launch testing virtual machine where you can deploy the demo-project.