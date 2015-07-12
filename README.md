# intigua-node

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What the Intigua module affects](#what-the-intigua-module-affects)
    * [Setup requirements](#setup-requirements)
4. [Usage](#usage)
    * [Basic Module Configuration](#basic-module-configuration)
    * [Assigning Tags](#assigning-tags)
    * [Directly deploying a management service](#Directly-deploying-a-management-service)
5. [Platform Support](#platform-support)

## Overview

The Intigua module helps Puppet users deploy and manage agent-based and agentless server management tools (backup, monitoring, security, etc.) on Puppet-controlled nodes, through integration with Intigua.

## Module Description

This module lets Puppet classes and resources be used together with Intigua in order to determine, deploy and maintain the needed set of management services to each node. Together with the Intigua server, the module continuously ensures correct setup, configuration and health of agent-based and agentless tools on the server through its lifetime, including agent CPU and memory throttling, registration of agents with backends, and automated remediation of failures.

Some examples of management tools which can be operated in this manner are: monitoring tools such as Microsoft SCOM, VMware vRealize Hyperic, and Zabbix; Log collection and analytics tools such as Splunk and VMware Log Insight; Backup tools such as Symantec NetBackup and EMC NetWorker; and endpoint security tools such as Symantec Endpoint Protection.

The module first ensures the node is connected to Intigua, by setting up the Intigua connector if it's not already there. Once connected, the module can be used to apply Intigua-managed server management tools.

## Setup

### What the Intigua Module Affects

* The Intigua connector on the node
* Management tools deployed to the node via Intigua, including:
  * Management agents
  * Server-side tool configurations for managing the node, residing not on the node itself but on on the server consoles of individual management tools
  * Cloud-hosted configurations of cloud-based tools used to manage this node
* Intigua tags for the node (often indirectly affecting the set of management tools)

### Setup Requirements

HTTPS connectivity from the node to the Intigua server is required.

## Usage

### Basic Module Configuration
The following basic configuration is required so that the module can connect to Intigua:

```puppet
class { 'intigua':
  ensure => present,
  api_endpoint => "https://intigua.acme.com/vmanage-server/rest/rest-api/"
  api_user => "puppet"
  api_key => "D2EA7069-C14B-41B3-9E19-47AF05057C75"
}
```

### Assigning Tags
The `intigua::tag` resource lets Puppet tag the node for Intigua. Typical tags may refer to the type or usage of the server. The Intigua server management policy (defined in Intigua) can use these tags to determine which management services are appropriate for the node.

```puppet
intigua::tag { 'dev':
    ensure  => present,
}
intigua::tag { 'db':
    ensure  => present,
}
intigua::tag { 'finance-app':
    ensure  => present,
}
```

Any changes to the management policy, such as updates to tool software and configuration, can now be applied by operations teams directly through Intigua, in a contained manner and without requiring further interaction with Puppet.



### Directly deploying a management service
```puppet
intigua::managementservice { 'Netbackup':
    ensure  => present,
    intigua_version => '7.6.5',
    intigua_config  => 'Gold backup',
}
```

This resource generates a request to the Intigua API to deploy a management service to the node.
While useful in some cases, it's typically recommended to use tags, giving IT operations teams using Intigua better control of the entire server management landscape.

### Create your own class
You can create you own class for a managment service for better readability:
```puppet
define intigua::netbackup {

  intiguanode::managementservice { 'Netbackup':
    ensure  => present,
    intigua_version => '7.6.5',
    intigua_config  => $title,
  }
}
```
to use it, simply:
```puppet
class managment {
  class { 'intigua':
    ensure => present,
    api_endpoint => "https://intigua.acme.com/vmanage-server/rest/rest-api/"
    api_user => "puppet"
    api_key => "D2EA7069-C14B-41B3-9E19-47AF05057C75"
  }

  intigua::netbackup {'Gold backup':}
  }
```



## Platform Support

This module has been tested with various Puppet versions and Intigua management services on Windows and Linux nodes.
