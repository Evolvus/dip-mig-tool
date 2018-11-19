# dip-mig-tool
Data Integration Migration Tool for Transformation and Verification Reporting.



## Introduction
The tool is unobtrusive and simplistic automation provider for data migration. It allows the data migration team to automate the executions in simple and predictable manner without adding absolutely any overhead to the execution.

In migration, execution timelines are the key to success. The design goal of this tool is to have the lowest performance and learning footprint at the same time provide complete control and automate migration execution.

All the logic of transformation and verification is externally built using RDBMS SQL. The SQL creates the output in an output table.
The output table are then spooled to a file again using RDBMS sqls.

These sqls are checked into the configured source control system.

This tool will then orchestrate the migration execution.


## Installation
Download and extract the zip file into a Unix/Linux directory.
https://github.com/Evolvus/dip-mig-tool/archive/master.zip

Run 
>execute.sh INSTALL

Respond to all the questions. It will create the folders and copy the required files in the migration location provided as part of installation.


## Execution

### Four Modes

1) Normal mode

>execute.sh

It will ask for the country for which you need migration. Then lets you execute the containers for that country.

2) Normal Country Specfic mode

>execute.sh "Country ID"

The first parameter is "Country ID". It lets you skip the country menu and directly takes you to the container menu for the country id provided.
  
3) Get Code mode
 
>execute.sh GETCODE
 
Since the development and check-in will happen in local repostiory specific to a bank, latest code needs to be taken before execution. This option will connect to the SVN/GIT/Any other source control and retrieve the latest code.

4) Spool mode

>execute.sh SPOOL

Spool mode lets you spool the content of table into a file. This also uses the container to group set of SQL together. Once the spooling is complete it lets you FTP it to the Windows Server location to convert to excel files.

## Containers
Since migrations are executed in chunks of modules, the tool provides containers to group the sqls based on execution.

There are two types of containers - 
1) Normal Containers - Normal Containers lets you group SQLs that execute transformation and verification. The output of which are stored in a output table.
As mentioned above you can execute normal containers using 
>execute.sh [country id]
2) Spool Containers - Once the Normal Containers are executed, the output from the ouptut table needs to be spooled to a file. This is achieved through Spool Container. The Spool Container has the group of SQLs that will spool the output from output table to the files.
>execute.sh SPOOL

Please note that the output table will have exact structure as required by the Loading tool or the verification report format.

## config.env
This is the configuration file for the tool. It contains all the required details for the tool to run. 

## Folders
There is an option to group all the required files per country or have all files grouped together. The config.env has a configuration called - COUNTRY_WISE Y(Yes) means files are grouped per country. N(No) means all files are grouped together.
The log files are always common for all countries.

1) sql - 
sql folder contains all the sqls that are required for transformation and verification. 

2) container - 
container folder contains all the containers that are used to group the sqls.

3) output - 
output folder will hold all the output files that gets generated out of the spooling

4) log - 
log folder will hold all the log files that gets generated as part of execution. The log files are always common for all countries.

The path of the above log folders can be configured in config.env.
The above structure is mandated by the tool. Within the above structure, the user of tool is free to build their own folder structure as they would find it convenient.

## Logging

Following logging is enabled by tool - 
1) Error - All errors are logged to the error log file
2) Warn - All warnings are logged to the warn log file
3) Info - All information are logged to the trace log file
4) All - Error, Warn and Info logs can also be directed to a single file called Log All file

Each of the above can be independently enabled (or disabled) in config.env.
The file names can also be configured in config.env.




## Technology
The tool was developed using bash Version 3+ [It can work in all versions. It just uses the features of Version 3+]
Plans are in place to upgrade to bash Version 4 which supports arrays. Support of arrays will make the tool more versatile.
