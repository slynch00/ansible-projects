# Ansible scripts for Jenkins

## Mount Jenkins Elastic File System
##### Used for mounting EFS to swarm workers

### OVERVIEW
This project captures the steps used to build a Jenkins deployment with high availability using AWS EFS and Docker Swarm. The ansible script is used to mount an efs target on each swarm worker. Specifically, this is for the home directory of Jenkins which will allow all plugins, users, and jobs to be stored in efs. It is intended to be used with Docker Swarm and Jenkins docker containers. Therefore, this is run on each swarm worker assuming all manager availability is drained.

**Assumption:** All prerequisites are available. For example, an AWS account is in place with the Elastic File System (EFS) service available. A Docker Swarm cluster is built and Ansible is installed. 

### OBJECTIVE
The objective is to complete an installation that is resilient to availability failure. Success criteria will be for events such as killing the Jenkins service or adding new containers results in no loss of data for users, plugins and jobs. 

This ansible script mounts an efs filesystem on each swarm worker so that the jenkins containers can mount that file system as a volume mount for the home directory.
