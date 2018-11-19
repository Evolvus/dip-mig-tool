# dip-mig-tool
Data Integration Migration Tool for Transformation and Verification Reporting.

## Installation
Download the zip file containing all the files

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

Spool mode lets you spool the content of table into a file. This also uses the container to group set of SQL together.



## Introduction
The tool is unobtrusive and simplistic automation provider for data migration. It allows the data migration team to automate the executions in simple and predictable manner without adding absolutely any overhead to the execution.

In migration, execution timelines are the key to success. The design goal of this tool is to have the lowest performance and learning footprint at the same time provide complete control and automate migration execution.

All the logic of transformation and verification is built using RDBMS SQL. The SQL creates the output in an output table.
The output table are then spooled to a file again using RDBMS sqls.

### Containers
Since migrations are executed in chunks of modules, the tool provides containers to group the sqls based on execution.

There are two types of containers - 
1) Normal Containers - Normal Containers lets you group SQLs that execute transformation and verification. The output of which are stored in a output table.
2) Spool Containers - Once the Normal Containers are executed, the output from the ouptut table needs to be spooled to a file. This is achieved through Spool Container. The Spool Container has the group of SQLs that will spool the output from output table to the files.

Please note that the output table will have exact structure as required by the Loading tool or the verification report format.

## Technology
The tool was developed using bash Version 3+ [It can work in all versions. It just uses the features of Version 3+]
Plans are in place to upgrade to bash Version 4 which supports arrays. Support of arrays will make the tool more versatile.
