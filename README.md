# Galaxy Flavor Testing

Galaxy Flavors are the easiest way to get production ready, specifically tailored tool collections in the hand of users.
To read more about it by visiting the [Galaxy website](http://galaxyproject.org/) and the [Galaxy Docker project](https://github.com/bgruening/docker-galaxy-stable).

This projects hosts scripts for different CI services to unify and ease the testing of such flavors.

## Travis

Copy the included [`example_travis.yml`](example_travis.yml) into your github repository of your Galaxy flavor, name it `.travis.yml` and it will be tested automatically.

Note: You need to activate Travis as described [here.](https://travis-ci.org/getting_started)

Finally, you can add an SVG at the top of your readme describing whether your tests pass if your flavor is publicly available on github. At the top of your repository's README.md, add (substituting the proper `OWNER` and `REPO` of course):

```
[![Build Status](https://api.travis-ci.org/OWNER/REPO.svg)](https://travis-ci.org/OWNER/REPO)
```

## GitHub Actions

Copy the included [`example_github_actions.yml`](example_github_actions.yml) into a `.github/workflows/` directory in the github repository of your Galaxy flavor, name it `test.yml` and it will be tested automatically.

Finally, you can add an SVG at the top of your readme describing whether your tests pass if your flavor is publicly available on github. At the top of your repository's README.md, add (substituting the proper `OWNER` and `REPO` of course):

```
![Test Docker image building](https://github.com/OWNER/REPO/workflows/Test%20Docker%20image%20building/badge.svg)
```

## CircleCI

Copy the included [`example_circleci_config.yml`](example_circleci_config.yml) into a `.circleci/` directory in the github repository of your Galaxy flavor, name it `config.yml` and it will be tested automatically.
