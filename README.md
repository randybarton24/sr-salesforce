# SFDX  App

## Dev, Build and Test


## Resources


## Description of Files and Directories


## Issues

Initialize SFDX Project:
 - 
sfdx-project-{sandboxName}
 - force-app
 - mdapi-src
 - package.xml


1. Pull repo from Github
 - Command Pallette> git clone > {url from Github}

Authorize org:

Push latest repo to sandbox:
sfdx force:source:convert -d mdapi-src
sfdx force:mdapi:deploy

Make changes in sandbox:

Pull changes from sandbox:
sfdx force:source:retrieve -x package.xml -u

Get Work Request in SF
Find a sandbox not in use
Authenticate sandbox
Branch from Master in Github
Clone from Github branch to Local
Convert source to mdapi
Deploy source from local to sandbox
Make/test changes to config/code local/sandbox
Retrieve source from sandbox to local
Stage local files to be committed
Commit files locally
Push commit from local to github
Repeat until feature complete
Open pull request when feature complete
Review pull request
Merge pull request
CI Build to Org