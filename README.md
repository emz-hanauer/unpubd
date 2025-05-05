# unpubd
A docker container and management tools for running a local dart package respository.

Prebuild docker images for unpubd

## Changes over noojee/unpubd
* dart 3 support
* google secret manager support to store the tokens
* preshared token and email support (no Oauth needed)

## Easy start
Just put down your own `docker-compose`
```yaml
networks:
  unpubd:
    driver: bridge

volumes:
  mongodata:

services:
  mongodb:
    image: mongo
    restart: unless-stopped
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_INITDB_ROOT_USERNAME}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_INITDB_ROOT_PASSWORD}
      MONGO_INITDB_DATABASE: ${MONGO_INITDB_DATABASE}
    volumes:
      - mongodata:/data/db
    networks:
      - unpubd

  unpubd:
    image: ghrc.io/petrleocompel/unpubd:latest
    restart: unless-stopped
    depends_on:
      - mongodb
    environment:
      MONGO_ROOT_USERNAME: ${MONGO_ROOT_USERNAME}
      MONGO_ROOT_PASSWORD: ${MONGO_ROOT_PASSWORD}
      MONGO_DATABASE: ${MONGO_DATABASE}
      MONGO_HOST: ${MONGO_HOST:-mongodb} 
      MONGO_PORT: ${MONGO_PORT:-27017}
      UNPUBD_PORT: ${UNPUBD_PORT:-4000}
      GOOGLE_SECRET_NAME: ${GOOGLE_SECRET_NAME}
      GOOGLE_SECRET_REFRESH_TOKEN: ${GOOGLE_SECRET_REFRESH_TOKEN}
      GOOGLE_SERVICE_ACCOUNT_JSON_BASE64: ${GOOGLE_SERVICE_ACCOUNT_JSON_BASE64}
      PRESHARED_ALLOWED_TOKENS: ${PRESHARED_ALLOWED_TOKENS}
      PRESHARED_UPLOAD_EMAIL: ${PRESHARED_UPLOAD_EMAIL}
      PRESHARED_UPLOAD_TOKENS: ${PRESHARED_UPLOAD_TOKENS}
      TZ: ${TZ}
    links:
      - mongodb
    networks:
      - unpubd
    ports:
      - ${UNPUBD_PORT:-4000}:${UNPUBD_PORT:-4000}
```
and `.env` file
```
MONGO_INITDB_ROOT_USERNAME="admin"
MONGO_INITDB_ROOT_PASSWORD="admin"
MONGO_INITDB_DATABASE="admin"
MONGO_ROOT_USERNAME="admin"
MONGO_ROOT_PASSWORD="admin"
MONGO_DATABASE="admin"
MONGO_HOST="mongodb"
MONGO_PORT="27017"
UNPUBD_PORT="4000"

# not required
# read only tokens
PRESHARED_ALLOWED_TOKENS="x,y,b"
# rw tokens
PRESHARED_UPLOAD_EMAIL="info@example.com"
PRESHARED_UPLOAD_TOKENS="x,y,b"
# google secret manager
GOOGLE_SERVICE_ACCOUNT_JSON_BASE64="x"
# replce <> with your values
GOOGLE_SECRET_NAME="/projects/<0000000000>/secrets/<my-secret>/versions/latest"
# http refresh url token for refreshing tokens - your random string - openssl rand -hex 64
GOOGLE_SECRET_REFRESH_TOKEN="x"
```

---

Unpubd is essentially an installer for the unpub package.

The install creates two docker containers mongo, and unpubd.

Mongo provides the database for the packages and unpubd the web interface and api for the dart pub command.

Once installed and configured you can publish packages to a local repository.

Unpubd also acts as local proxy for pub.dev.

To use unpubd you can either use the unpub command in place of 'dart pub' or set up an environment variable PUB_HOSTED_URL which will cause dart pub to use your local repository.

# Sponsored by OnePub
Unpubd was created by the [OnePub](https://onepub.dev) team.

If you don't want to roll your own private repository then OnePub provides a SAAS solution
with a generous free tier.

OnePub allows you to privately share dart packages between your own projects or with colleagues.
Try it for free and publish your first private package in seconds.

> Note: 
> If you try the beta and send me a note with your thoughts, via the 'Contact OnePub' link on the home page and mention unpubd, I will organise you a free upgrade to 5 pro seats, which might fix your unpubd problem ;)

FYI: we still plan on supporting unpubd.
## Publish a private package in six commands:

```bash
dart pub global activate onepub
onepub login
dart create mytool
cd mytool
onepub pub private
dart pub publish
```

See the OnePub blog on [publishing your first package.](https://onepub.dev/show/71ddbfcc-209c-48e1-9afd-d30f54016a7a)

# Installation

## Prerequisites
* Docker
* docker-compose

## To install unpubd
Start by installing the prequesites note above.

Then run.

```bash
dart pub global activate unpubd
unpubd install
```

When you install unpubd it will ask you for a port no. (defaults to 4000) to expose unpubd on.
You can changes this to any port between 1025 and 65000). Just make sure the port isn't already in use.

# Starting unpubd

To start unpubd in the foreground

```bash
unpubd up
```

To start unpubd in the background

```bash
unpub up --detach
```

# Stopping unpubd

If you are using unpubd in the foreground then just hit ctrl-c to terminate the app.

If th unpubd is running in the background run:
```bash
unpubd stop
```

# Using unpubd

The pub get/outdated/upgrade/publish commands all interact with pub.dev

See the OnePub blog on [publishing your first package.](https://onepub.dev/show/71ddbfcc-209c-48e1-9afd-d30f54016a7a) Whilst it is written for OnePub it also covers of the basics of publishing a package.

Note: both `flutter pub` and `dart pub`  work the with the same changes desribed below.

Two methods are available to redirect the pub command to use your local package repository.

## 1) set PUB_HOSTED_URL environment variable

If you set the PUB_HOSTED_URL environment variable to point to your local repository then both dart pub and flutter pub will use your local repo.

You need to configure the environment variable so it is avialable in your shell.

Once PUB_HOSTED_URL is created you can run any pub command and your local repository will be used.

### On linux:
export PUB_HOSTED_URL=http://localhost:4000

### On Windows
Add the same URL to your PATH via the registry.

### On MacOS
Drop me a line if you know the details :)


## 2) use unpub
The unpub command (as opposed to unpubd which we used during the install) is simply a pass through mechanism to dart pub.
The unpub command dynamically sets the PUB_HOSTED_URL and then calls dart pub with the same arguments.

* unpub - for user of the Dart SDK use: 
* funpub - For users of the Flutter SDK use: 

This approach has the advantage in that if you need to revert to using pub.dev you can just revert to using dart pub/flutter pub  and you don't have to create any environment variables.

## Publishing to unpubd
To publish your packages to unpubd (rather than pub.dev) you need to add a 'publish_to' key to your packages pubspec.yaml.

```yaml
name: dcli
description: Dart console SDK
version: 1.0.0
repository: https://github.com/noojee/dcli
homepage: dcli.noojee.dev

publish_to: http://your-unpubd-server.com
```

Now when you run `pub publish` for your package it will be published to your unpubd server.

## Added dependencies
If you run dart pub with the PUB_HOSTED_URL or unpub then pub will automatically try to pull  dependencies from unpubd.

However you can also ensure that your package dependencies are always pulled from unpubd by altering the dependency in pubspec.yaml to a 'hosted' dependency.

```yaml
dependencies:
  dcli:
    hosted:
      url: http://your-unpubd-server.com
      version: ˆ1.0.0
```      

This technique is also useful if you are preparing a PR for a public package.
You can first publish it to your unpubd server and test it internally before pushing the PR.

I find this particularly useful while you are waiting for a public package to accept and publish your PR.

# unpubd Commands
unpubd suports a number of commands

## unpubd install
Installs unpubd and the docker containser

## unpubd reset
Deletes the docker containers and volumes.

WARNING: all of you local packages will be deleted.

## unpub up
Starts the unpubd and mongo docker containsers.

## unpub down
Shuts down the unpubd and mongo containers.


# Building
This section is for developers of unpubd.

## prerequisites
* Docker
* docker-compose
* dcli (pub global activate dcli)
* pub_release (pub global activate pub_release)
* critical_test (pub global activate critical_test)

## Release
To create a release of unpubd

```bash
dcli pack
tool/build.dart
pub_release
```

The release process builds and publishes docker images to the Noojee repository (you need to be an admin on the docker hub noojee repo) and publishes the package to pub.dev.

### faster docker builds

When making source code changes that need require a rebuild of you docker images you can use the --clone switch.

```bash
tool\build.dart --clone
```

This command will only re-clone the source from git hub and only rebuild the docker steps required.

If you need to force a full rebuild of the docker container use:

```bash
tool\build.dart --clean
```

# Diagnosing problems.
If you are having problems accessing your unpubd server here are a few things you can try.

1) To see the status of your unpubd service.

    Run: `unpubd doctor`

 2) Check the logs

    ```
    docker logs unpubd
    docker logs mongo
    ```




