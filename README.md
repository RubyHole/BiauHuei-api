# BiauHuei API

API to securely store and retrieve the bids information for private ROSCAs played traditionally by Taiwanese.

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/accounts/existed/[username]`: checks whether an [username] is existed
- GET `api/v1/groups`: returns leaded or participated groups
- GET `api/v1/groups/[group_id]`: returns the assigned group information
- POST `api/v1/auth/register`: email verification of registration
- POST `api/v1/accounts/authenticate`: authenticates with a given account
- POST `api/v1/accounts/authenticate/google_sso`: authenticates with google single sign-on (SSO)
- POST `api/v1/accounts/authenticate/github_sso`: authenticates with github single sign-on (SSO)
- POST `api/v1/accounts/new`: creates a new account
- POST `api/v1/groups/new`: creates a new group
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
