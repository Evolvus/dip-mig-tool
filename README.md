# dip-mig-tool
Data Integration Migration Tool for Transformation and Verification Reporting

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

prompt>execute.sh <<Countryid>>

The first parameter is <<Countryid>>. It lets you skip the country menu and directly takes you to the container menu for the country id provided.
  
3) Get Code mode
 
 prompt>execute.sh GETCODE
 
Since the development and check-in will happen in local repostiory specific to a bank, latest code needs to be taken before execution. This option will connect to the SVN/GIT/Any other source control and retrieve the latest code.

4) Spool mode

prompt>execute.sh SPOOL

Spool mode lets you spool the content of table into a file. This also uses the container to group set of SQL together.

