# BiauHuei API

API to securely store and retrieve the bids information for private ROSCAs played traditionally by Taiwanese.

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/account/[account_id]/groups`: returns leaded or participated groups for the given account ID
- GET `api/v1/group/[group_id]/account/[account_id]`: returns the assigned group information for the given account ID
- POST `api/v1/account/authenticate`: authenticates with a given account
- POST `api/v1/account/new`: creates a new account
- POST `api/v1/group/new`: creates a new group
- POST `api/v1/bid/new`: submits a bid

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
ruby spec/api_spec.rb
```

## Execute

Run this API using:

```shell
rackup
```
