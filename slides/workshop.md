---
title: CirclCI Workshop
author: Huy Vu
---

# CicleCI Workshop
## Technical Talk 24 April 2022
### By: Huy Vu

---
# Setup
1. Use your personal Github account
2. Fork this repo: https://github.com/khanhhuy/circleci-mini-workshop
3. Go to CircleCI, login with your Github
4. Enable CircleCi with your new repo, use default config
5. Clone the repo at your local
   - Checkout branch: `circleci-project-setup`

---

# Topics

## Part 1: Basic
- Configuration structure
- Command, Job, Workflow, Cache
- Executor, Image
- Environment
- Data persistence

## Part 2: Reusability
- Parameter
- Dynamic configuration

---

# Configuration structure
https://circleci.com/docs/2.0/concepts/#configuration
https://circleci.com/docs/assets/img/docs/config-elements.png

```yaml
# Use the latest 2.1 version of CircleCI pipeline process engine.
# See: https://circleci.com/docs/2.0/configuration-reference
version: 2.1

# Define a job to be invoked later in a workflow.
# See: https://circleci.com/docs/2.0/configuration-reference/#jobs
jobs:
  build:
    docker:
      - image: cimg/ruby:3.1.0
    steps:
      - run: echo "hello world"

# Invoke jobs via workflows
# See: https://circleci.com/docs/2.0/configuration-reference/#workflows
workflows:
  sample: # This is the name of the workflow, feel free to change it to better match your workflow.
    # Inside the workflow, you define the jobs you want to run.
    jobs:
      - build

```

---

# Main concepts:
- Command: a single command e.g. bundle install, jest...
- Steps: list of commands
- Jobs
    - Contain steps
    - Contain execution environment
- Workflows:
    - Responsible for orchestrating multiple jobs.
    - E.g. job A requires job A. Or, B & C can run in parrallel
- Pipeline: Represents the entirety of your configuration

---

- Config file location: `.circle/config.yml` 

---

## Exercise 1
- Read `config0.yml`
- Then, create a config file to run `rspec`
- Use image: `cimg/ruby:2.7.4`
- Steps
  - checkout
  - bundle install
  - bundle exec rspec ./spec/test1.rb

https://circleci.com/docs/2.0/configuration-reference/#run
https://circleci.com/docs/2.0/configuration-reference/#checkout

---

## Solution
- Walkthrough `config-ex1.yml`

--- 

## Exercise 2
- Add `rubocop` job before `rspec`
- Require `rubocop` step to pass before running `rspec`

---
Will it work?
```yaml
version: 2.1

jobs:
  test-rubocop:
    working_directory: ~/holistics
    docker:
      - image: cimg/ruby:2.7.4
    steps:
      - checkout
      - run:
          command: bundle install 
      - run:
          command: bundle exec rubocop
  test-rspec:
    working_directory: ~/holistics
    docker:
      - image: cimg/ruby:2.7.4
    steps:
      - run:
          command: bundle exec rspec

workflows:
  exercise1: 
    jobs:
      - test-rubocop
      - test-rspec:
          requires:
            - test-rubocop
```

---

- We need to `checkout` and `bundle` install again in the `rspec` steps
- Installing dependencies take much time

---
# Cache

https://circleci.com/docs/2.0/caching/
```yaml
- restore_cache:
    key: gem-cache-v1-{{ arch }}-{{ .Branch }}-{{ checksum "Gemfile.lock" }}
- run: bundle install --path vendor/bundle
- save_cache:
    key: gem-cache-v1-{{ arch }}-{{ .Branch }}-{{ checksum "Gemfile.lock" }}
    paths:
      - vendor/bundle
```

---

## Exercise 2
- Add `rubocop` job before `rspec` job
- Require `rubocop` step to pass before running `rspec`
  - Store/restore cache at the `bundle install` step

---

## Solution
- Walkthrough `config-ex2.yml`

---

# Executor & Images

[https://circleci.com/docs/2.0/executor-intro/](https://circleci.com/docs/2.0/executor-intro/)

https://circleci.com/docs/2.0/custom-images/

**Our custom images**

[https://github.com/holistics/holistics-circleci-image/blob/master/Dockerfile](https://github.com/holistics/holistics-circleci-image/blob/master/Dockerfile)

[https://github.com/holistics/node_utils/blob/master/Dockerfile](https://github.com/holistics/node_utils/blob/master/Dockerfile)

---

# Commands
https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-commands

---

## Exercise 3
- Refactor exercise 2 using executors and commands

https://circleci.com/docs/2.0/configuration-reference/#executors-requires-version-21

https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-commands

---
# Environment

https://circleci.com/docs/2.0/env-vars/#order-of-precedence

[https://circleci.com/docs/2.0/env-vars/#built-in-environment-variables](https://circleci.com/docs/2.0/env-vars/#built-in-environment-variables)

---

# Data persistence
- Use case: how to view rspec coverage?

[https://circleci.com/docs/2.0/artifacts/#uploading-artifacts](https://circleci.com/docs/2.0/artifacts/#uploading-artifacts)

---
## Exercise 4
- From exercise 3, store the directory `coverage` which generated after `rspec` is run

---
**Done**: configuration, cache, image, jobs, workflow, pipelines, environments, data persistence

**Walkthrough**: `test_rails_app` job in Holistics cloud

---
# Part 2: Reusability
---

# Parameters