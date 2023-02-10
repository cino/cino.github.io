+++
author = "Ricardo Cino"
title = "Every repository should contain a DevContainer"
slug = "every-repository-should-contain-a-devcontainer"
date = "2023-02-09"
tags = [
    "vscode",
    "microsoft",
    "devcontainer",
    "container",
    "docker",
    "rancher"
]
+++
Almost a year ago I visited an AWS User Group (Amsterdam) meetup where someone gave a presentation on using Microsoft [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) in your projects. Even though I tried it before, this gave me the momentum to actually commit to it and have never looked back. And I want you to do the same.

<!--more-->

## But, why should I?

There are multiple reasons for using (Dev) Containers on in your workflow, first of all it's nice to have you're development configuration `as code` which makes it reproducible. When working on a project for a period and putting it on the shelf, you might delete the repository from your machine and once you need it clone it back in, when using Dev Containers you can instantly spin up the container and continue where you left off. No need to figure out how the setup worked.

A second benefit, when working in a team of developers; having **all** the exact same environment is extremely beneficial. There will be no need to install all the dependencies and quirky software that you once required but forgot to document how to make it work etc.

As my current position is in a Developer Experience team I must mention that for onboarding purposes this amazing, when you are using it correctly you'll only have to help your new collegue by cloning the repository and spin up the containers and you are ready to start working on the project.

My favourite benefit is that when you are working for multiple customers on a various number of projects which changes programming language versions a lot you get real sick, real soon of switching up your system. When you're working with containers you'll be much happier.

Also, say goodbye to the famous line;
> Works on my machine

## How?

Microsoft have created an additional configuration file named "devcontainer.json" where you specify a couple of things:

- The container you need to run
- Visual Studio Code customizations (For example, default plugins)
- Port forwarding
- Mounts
- [and more](https://containers.dev/implementors/json_reference/)

Most importantly you want to look into the build section in the json file, this is how you specify what your container should be running and this usually contains a Dockerfile reference. For example in the repository of this website I have the following

    "build": {
        "dockerfile": "Dockerfile",
        "args": {
            "VARIANT": "hugo",
            "VERSION": "latest",
            "NODE_VERSION": "14"
        }
    },

This section only says to look to the Dockerfile which is available in the same repository with these arguments. The arguments can be different for each Dockerfile depending on how you would use them. When you have 1 Dockerfile specific for your project this might be obsolete, however when you would be re-using a Dockerfile it is quite handy to be able to modify versions.

And because we are referencing a local Dockerfile we can do anything we'd like in mentioned Dockerfile. As this project is a Hugo generated website and all being done with this DevContainer I have used an existing Dockerfile from the internet which pre-installed Hugo in the container.

While this is a pretty simple Dockerfile nothing more was needed, besides adding a few global npm packages to streamline the theme development. The point I'm trying to make is that you can configure everything you need for the development process in the Dockerfile and guarantee a working development flow the next time you need to work on it.

DevContainer config for this website is visible on Github: <https://github.com/cino/cino.github.io/tree/main/.devcontainer>

## Rancher or Docker-Desktop

Recently I moved from Docker-Desktop to the [Rancher Desktop](https://rancherdesktop.io/) application to managed the underlying docker infrastructure as the [license was modified](https://www.knowledgehut.com/blog/devops/docker-license-change) for Docker Desktop which doesn't allow (big) business usage in the free tier anymore. Rancher does, simple..

### Additional Resources

- [Official Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Example Dev Containers Definitions](https://github.com/microsoft/vscode-dev-containers/tree/main/containers)
