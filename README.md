Rivet
========

Rivet is a small utility which allows you to describe an autoscaling groups and it's launch configurations as yaml.  You can then sync those changes to AWS.

Rivet allows you to provide a template and it's options which will be rendered as user-data for your launch configurations.  It is currently opinionated and assumes you are trying to build
a bootstrap script for chef installed via gems.  You can of course provide it with any template you desire, and in future releases this system will become more flexible and less opinionated.

Rivet is also opinionated about how it names launch configurations, as it generates unique deterministic names for them and automatically assigns the proper launch configuration to your
autoscaling group based upon it's generated identity.

Installation
============

gem install rivet

Usage
=====


