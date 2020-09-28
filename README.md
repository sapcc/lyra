# Lyra - The Converged Cloud automation service

Lyra is the high-level automation service. Its main focus is to store and orchestrate automations. Lyra uses [Arc](https://github.com/sapcc/arc), which is the low-level job execution service.

The automation service provides different types of automations. Currently the service supports two types:

  * **Chef:** Run chef-zero/solo
  * **Script:** Execute shell scripts


## Chef Template
A Chef template provides the following parameters:

- **Name:** Should be short and alphanumeric without white spaces.

- **Repository:** Repository containing the chef cookbooks. Git is the only supported repository type
(e.g. [https://github.com/sapcc/automation-tests.git](https://github.com/sapcc/automation-tests.git))

- **Repository version:** A branch, tag, or commit to be synchronized with the repository (default: master)

- **Timeout:** Time in seconds after which an automation run is aborted (default: 3600)

- **Runlist[**](#array-string):** Describes the sequence of recipes which should be executed (e.g.: recipe[nginx::default],role[staging])

- **Attributes:** JSON object providing additional Chef attributes which are passed to Chef run
(e.g.: {"app": { "revision": "master", repo:"git://..." }})

- **Chef version:** Specifies the Chef version which should be installed in case no Chef is already installed

- **Debug:** Debug mode will not delete the temporary working directory on the instance when the automation job exists. This allows you to inspect the bundled automation artifacts, modify them and run the automation manually. Enabling debug mode for an extended period of time can exhaust  your instances disk space as each automation run will leave a directory behind. Also be aware that the payload may contain secrets which are persisted to disk indefinitely when debug mode is enabled. (default false)


## Script Template

A Script template provides the following parameters:

- **Name:** Should be short and alphanumeric without white spaces.

- **Repository:** Repository containing the script to run. Git is the only supported repository type
(e.g. [https://github.com/sapcc/automation-tests.git](https://github.com/sapcc/automation-tests.git))

- **Repository version:** A branch, tag, or commit to be synchronized with the repository (default: master)

- **Timeout:** Time in seconds after which an automation run is aborted (default: 3600)

- **Path:** Path to the script file to run (e.g. /script.sh)

- **Arguments[**](#array-string):** Arguments that should be passed to the script

- **Environment[*](#key-value-pair):** Environment variables should be set


## API Documentation
The Lyra API documenation is shipped inline with the service. You can access the documentation by going to document root of a Lyra Service endpoint. E.g. http://localhost:3000


## Lyra CLI
[Lyra CLI](https://github.com/sapcc/lyra-cli) enables you to interact with the SAPCC automation services using commands in your command-line shell. It is currently supported on Windows, Linux and Mac.


## Development setup

To run the application wiht bakcground jobs run also Que:

    bundle exec que --log-internals    
