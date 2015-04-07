﻿# A Simple Deployment Puppet Lab

This small project lab demonstrates the ability (and my understanding of how) to deploy a simple Ruby Sinatra application using Puppet and Git. 

Using the publicly available Sinatra application found at https://github.com/tnh/simple-sinatra-app, a **Ubuntu 14.10** virtual machine running under **Microsoft Azure**, I have been able to fully construct the following solution.

## Pre-requisites
### Hosting machine
Now any machine could be used to demonstrate this, but a nice clean machine image is always a nice starting point to fully know that there are no conflicts that could prove more difficult to diagnose if using say your development machine that is tailored to your specific requirements, not necessarily those of the application. In my instance I have used a virtual machine running Ubuntu 14.10 hosted at Microsoft Azure web hosting service. Why, because I could and I have a current free MSDN subscription courtesy of work.

As part of the virtual machine configuration, make sure that you enable an end point to the ```HTTP``` port ```80``` and map to port ```80``` for ease sake, so you can see your deployed application remotely.

### Software
Once you have your virtual machine up and running, some software to get things started will need to be installed.

Firstly start by updating the base machine image with any pending updates

```bash
sudo apt-get update && sudo apt-get upgrade -y
```

Next we need to get install the key software packages we will need to get everything started.

```bash
sudo apt-get install -y git puppet
```

This will install the two key packages ```git``` and ```puppet```.

## Our Puppet configuration
### The Git repository
Next we can start by putting together our Puppet configuration files which will be stored in Git, using the web service **GitHub**.

To me, the first thing was to create my GitHub respository for saving my files. If you already have a GitHub account, great. If not, start by joining up here - https://github.com/join. 

Next, create a new repository by selecting one of the option on your landing page when you log in. In the create repository page enter in a name for your repository (```puppet-lab``` shall do for this), a description, the scope type of public or private if you have paid for a subscription and a couple of initialisation option including a ```README``` file, an gitignore file structure and a licence type.  Once that is done, you can now clone this to your development machine to start working.

On the command line;

```bash
clone https://github.com/<github_name>/puppt-lab.git
cd puppt-lab
```

You may want to set your user details at this point before you start committing any changes. Simple run the following commands replacing the user name and email values.

```bash
git config --add user.name <user_name>
git config --add user.email <email_address>
git config --list

user.name=<user_name>
user.email=<email_address>
core.symlinks=false
core.repositoryformatversion=0
core.filemode=true
core.logallrefupdates=true
remote.origin.url=https://github.com/<github_name>/puppt-lab.git
remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
branch.master.remote=origin
branch.master.merge=refs/heads/master
```

All the other key value pairs are from when the repository was cloned.

###Puppet files
Now we have a project folder called ```puppet-lab```. Next we need to start by creating our initial folder structure. There are two main folders we require here called ``` manifests``` and ```modules```.

In the modules folder we need to create further folders to break up our required  packages, services and files. The folders we need are ```git```, ```nginx```, ```ruby``` and ```simple-deployment```. In each of these create their own ```manifests``` folder. Lastly a sub-folder under ```./modules/simple-deployment``` called ```templates```. We should have a folder structure that looks like the following.

```
.
├── .git
├── manifests
└── modules
    ├── git
    │   └── manifests
    ├── nginx
    │   └── manifests
    ├── ruby
    │   └── manifests
    └── simple-deployment
        ├── manifests
        └── templates
```

For each module, the manifest folder will need to contain an ```init.pp``` that Puppet will use as the definition of each of the modules.

#### Module: git
The manifest for the ```git``` module is largely thanks to Pindi Albert at http://www.pindi.us/blog/getting-started-puppet.

```puppet
# file: ./modules/git/manifests/init.pp

class git {
    package { 'git':
        ensure => installed,
    }
}

define git::clone ( $path, $dir) {
    exec { "clone-$name-$path":
        command => "/usr/bin/git clone $name $path/$dir",
        creates => "$path/$dir",
        require => File[$path],
    }
}
```
The class ```git``` just ensure that the package is installed. The definition ```git::clone``` is our function to perform the actual clone of the Sinatra application we wish to deploy.

#### Module: nginx

```puppet
# file: ./modules/nginx/manifests/init.pp

# Manage nginx webserver
class nginx {
	package { 'apache2.2-common':
		ensure => absent,
	}
	
	package { 'nginx':
		ensure => installed,
		require => Package['apache2.2-common'],
	}
	
	service { 'nginx':
		ensure => running,
		require => Package['nginx'],
		enable => true,
	}
	
	file { '/etc/nginx/sites-enabled/default':
		ensure => absent,
	}

	file { '/var/www':
		ensure => directory,
		owner => 'www-data',
		group => 'www-data',
		mode => 775,
	}
	
}
```

#### Module: ruby


#### Module: simple-deployment








```
.
├── .git
│   └── ...
├── manifests
│   ├── nodes.pp
│   └── sites.pp
├── modules
│   ├── git
│   │   └── manifests
│   │       └── init.pp
│   ├── nginx
│   │   └── manifests
│   │       └── init.pp
│   ├── ruby
│   │   └── manifests
│   │       └── init.pp
│   └── simple-deployment
│       ├── manifests
│       │   └── init.pp
│       └── templates
│           ├── exec-simple-deployment
│           ├── nginx-site.conf.erb
│           └── simple-deployment-daemon
├── apply
├── .gitignore
├── LICENSE
├── pull-updates
└── README.md
```
