# Stress test of Unreal Engine 4 Dedicated Server

A tool that leverages AWS to see how much client an UE4 dedicated server can handle.

## Prerequisites

Install the following before using this tool:

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

All configuration files are in `conf/[region]` directory.

## Run

Launch server:

    ./launch-server.sh [region]
    
Launch client:

    ./launch-client.sh [region]

## View Results

Two **custom** metrics of the server are posted to AWS CloudWatch:

### Client

How many client are currently online.

### CPU

How much percentage the server process utilizes the CPU (100% means occupies 1 entire core).

