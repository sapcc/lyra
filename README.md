# Lyra - The Converged Cloud automation service

Lyra is the high-level automation service. Its main focus is to store and orchestrate automations. Lyra uses [Arc](https://github.com/sapcc/arc), which is the low-level job execution service.

The automation service provides different types of automations. Currently the service supports two types:


  * [**Chef:**](#chef-automation-specific-attributes) Run chef-zero/solo
  * [**Script:**](#script-automation-specific-attributes) Execute shell scripts


## Automation Common Attributes

- **name:** should be short and alphanumeric without white spaces

- **repository_credentials:** credentials needed to access the repository (e.g.: git token or ssh key). This attribute can just be set and it is not being displayed by listing or getting automations

- **repository_authentication_enabled:** this attribute it is set to true when a repository_credentials is set (default: false)

- **repository_revision:** a branch, tag, or commit to be synchronized with the repository (default: master)

- **timeout:** time in seconds after which an automation run is aborted (default: 3600)


## Chef Automation Specific Attributes
A Chef automation provides the following parameters:

- **repository:** repository containing the chef cookbooks. Git is the only supported repository type
(e.g. [https://github.com/sapcc/automation-tests.git](https://github.com/sapcc/automation-tests.git))

- **runlist[\*\*](#array-of-strings):** describes the sequence of recipes which should be executed (e.g.: recipe[nginx::default],role[staging])

- **attributes:** JSON object providing additional Chef attributes which are passed to Chef run
(e.g.: {"app": { "revision": "master", repo:"git://..." }})

- **chef_version:** Specifies the Chef version which should be installed in case no Chef is already installed

- **debug:** Debug mode will not delete the temporary working directory on the instance when the automation job exists. This allows you to inspect the bundled automation artifacts, modify them and run the automation manually. Enabling debug mode for an extended period of time can exhaust  your instances disk space as each automation run will leave a directory behind. Also be aware that the payload may contain secrets which are persisted to disk indefinitely when debug mode is enabled. (default false)


## Script Automation Specific Attributes

A Script automation provides the following parameters:

- **repository:** Repository containing the script to run. Git is the only supported repository type
(e.g. [https://github.com/sapcc/automation-tests.git](https://github.com/sapcc/automation-tests.git))

- **path:** Path to the script file to run (e.g. /script.sh)

- **arguments[\*\*](#array-of-strings):** Arguments that should be passed to the script

- **environment[*](#key-value-pair):** Environment variables should be set


## API Documentation
The Lyra API documenation is shipped inline with the service. You can access the documentation by going to document root of a Lyra Service endpoint. E.g. http://localhost:3000


## Lyra CLI
[Lyra CLI](https://github.com/sapcc/lyra-cli) enables you to interact with the SAPCC automation services using commands in your command-line shell. It is currently supported on Windows, Linux and Mac.


## Development setup

To run the application wiht bakcground jobs run also Que:

    bundle exec que --log-internals    


---

##### Key Value Pair:
Key-value pairs are separated by ':' or '='. Start a new pair by hitting the Enter key. You can also copy and paste a string containing tags following this pattern: 'key1:value1¡key2=value2...'

##### Array of Strings:
Array of strings are separated by ','. Start a new entry by hitting the Enter key. You can also copy and paste a string containing strings following this pattern: 'value1¡value2...'
