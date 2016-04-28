# Stress test of Unreal Engine 4 Dedicated Server

A tool that leverages AWS to see how much client an UE4 dedicated server can handle.

## Prerequisites

Before using this tool, the following needs to be installed on both EC2 instances (via AMI) and your computer:

### AWS CLI

[https://aws.amazon.com/cli/](https://aws.amazon.com/cli/)

**Mac OS X**

    brew install awscli

**Linux (Ubuntu)**

```bash
sudo apt-get install python-pip

# Install AWS CLI using pip
# To upgrade an existing AWS CLI installation, use the --upgrade option:
#   sudo pip install --upgrade awscli
sudo pip install awscli

# Enable Command Completion for AWS CLI
echo 'complete -C $(which aws_completer) aws' >> ~/.bash_completion
```

### jq

[https://stedolan.github.io/jq/](https://stedolan.github.io/jq/)

**Mac OS X**

    brew install jq

**Linux (Ubuntu)**

    sudo apt-get install jq

## Configure

All configuration files are in `conf/[env]` directory.

Default configs are in `conf/_default` directory, they are loaded first, copy them to another directory to override the default value.

## Run

Launch server:

    ./launch-server.sh [env]

Launch clients:

    ./launch-client.sh [env] [instance-count]

Terminate server:

    ./terminate-server.sh [env]

Terminate clients:

    ./terminate-clients.sh [env]

## View Results

Two **custom** metrics of the server are posted to AWS CloudWatch:

### Client

How many client are currently online.

### CPU

How much percentage the server process utilizes the CPU (100% means occupies 1 entire core).

