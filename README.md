# devhops

## Table of Contents

1. [Description](#description)
2. [Setup](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)

## Description

This module helps deploying infrastructure for DevHops Workshops in various regions.

It assumes a "Demo Reboot" Puppetmaster AMI is available in your region.

The module uses module-level hiera to store all configuration. The hierarchy is expressed as follows in hiera.yaml:

```yaml
  - name: "AWS region-level user-level data"
    path: "%{::aws_region}/%{::user}.yaml"

  - name: "User-level data"
    path: "%{::user}.yaml"

  - name: "AWS region-level data"
    path: "%{::aws_region}/common.yaml"

  - name: "Common data"
    path: "common.yaml"
```

## Setup

### AWS setup

1. Make sure you have your AWS credentials (Access key and Secret key).
2. If you don't already have one, make sure you create an AWS SSH keypair in the region you are going to use.

(To create a keypair, go to <https://console.aws.amazon.com/ec2/v2/home#KeyPairs>)

### Setup on your Mac

```bash
brew install awscli
aws configure # needed for your AWS access
export AWS_REGION=$your_region # speeds up puppet aws module tremendously
export FACTER_aws_region=$your_region # needed for hiera
export FACTER_user=$your_user_name # needed for hiera
sudo /opt/puppetlabs/puppet/bin/gem install aws-sdk retries --no-ri --no-rdoc
puppet module install puppetlabs/aws
puppet module install puppetlabs/stdlib
```

## Usage

### Clone the devhops repo

```bash
git clone https://github.com/puppetlabs-seteam/devhops.git
```

### Configure hiera

- cd to the module dir `cd devhops`
- Configure region-specific AMI ids in the hash `devhops::amis` in the `data/common.yaml` file
- If not done yet, create the file `data/${FACTER_aws_region}/common.yaml` and configure
  region-specific AWS variables
- If not done yet, reserve a static IP for your master by doing:
  `aws ec2 allocate-address --region ${FACTER_aws_region}`
- Create the file `data/${FACTER_aws_region}/${FACTER_user}.yaml` and add
  your `devhops::key_name` and `devhops::master_ip`
- Create the file `data/${FACTER_user}.yaml` and configure user-specific variabls (such as tags)

### Provision the master

- run `tasks/provision.sh master`

### Provision count linux agents

- run `tasks/provision.sh linux_node count`

### Provision count windows agents

- run `tasks/provision.sh windows_node count`

### Provision the Puppet Discovery VM

- run `tasks/provision.sh discovery`

### Provision the Windows Domain Controller

- run `tasks/provision.sh windc`

### Configure the control repo

First, make sure to install bolt.

Next run the following task on the local machine. This will push the contents of the control repo you specify to Puppetmaster's local GOGS server (which is hosted at http://$puppet_ip:3000). Optionally, you can add your own public key to GOGS so you can start pusing your changes to the PM riectly.

```bash
bolt task run devhops::conf_control_repo --modulepath .. -n $master_ip control_repo="https://github.com/puppetlabs-seteam/control-repo-devhops.git" public_key_name=$key_name public_key_value="$($your_pub_key)" -u root -p #--debug --verbose
```
## Limitations
