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
- Steps
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

- Types: string, boolean, integer, enum, executor, steps, environment
- Parameters are declared by name under a job, command, or executor
- Pipeline parameters are defined at the top level of a project configuration. Note: pipeline params can only support a few types

https://circleci.com/docs/2.0/reusing-config/#using-the-parameters-declaration

---

- Define the parameters before using the params
- Pass parameters explicitly

```yaml
version: 2.1

jobs:
   build:
     parameters:
       access-key:
         type: env_var_name
         default: AWS_ACCESS_KEY
       secret-key:
         type: env_var_name
         default: AWS_SECRET_KEY
       command:
         type: string
     docker:
       - image: ubuntu:latest
         auth:
           username: mydockerhub-user
           password: $DOCKERHUB_PASSWORD  # context / project UI env-var reference
     steps:
       - run: |
           s3cmd --access_key ${<< parameters.access-key >>} \\
                 --secret_key ${<< parameters.secret-key >>} \\
                 << parameters.command >>
workflows:
  workflow:
    jobs:
      - build:
          access-key: FOO_BAR
          secret-key: BIN_BAZ
          command: ls s3://some/where
```

---

# Steps

---
Job `pre-steps`, `post-steps`. Useful for execute steps without modifying the job

https://circleci.com/docs/2.0/reusing-config/#using-pre-and-post-steps

```yaml
# config.yml
version: 2.1
jobs:
  bar:
    machine: true
    steps:
      - checkout
      - run:
          command: echo "building"
      - run:
          command: echo "testing"
workflows:
  build:
    jobs:
      - bar:
          pre-steps:
            - run:
                command: echo "install custom dependency"
          post-steps:
            - run:
                command: echo "upload artifact to s3"
```

---

Conditional steps: `when`, `unless`
https://circleci.com/docs/2.0/reusing-config/#defining-conditional-steps

---

# Dynamic Configuration
Generate the `config.yml` dynamically

---
**Use case**: only run RSpec when any `.rb` file is modified, or Jest for `.js`
</br>
How to do it:
- Diff the current branch with the base branch to get modified files
- Generate the CircleCI config based on those changes

https://circleci.com/docs/2.0/dynamic-config/#getting-started-with-dynamic-config-in-circleci

---

https://circleci.com/docs/2.0/configuration-cookbook/?section=examples-and-guides#dynamic-configuration

```yaml
version: 2.1

# this allows you to use CircleCI's dynamic configuration feature
setup: true

# the continuation orb is required in order to use dynamic configuration
orbs:
  continuation: circleci/continuation@0.1.2

# our defined job, and its steps
jobs:
  setup:
    executor: continuation/default # can also be cimg/ruby
    steps:
      - checkout # checkout code
      - run: # run a command
          name: Generate config
          command: |
            ./generate-config > generated_config.yml
      - continuation/continue:
          configuration_path: generated_config.yml # use newly generated config to continue

# our single workflow, that triggers the setup job defined above
workflows:
  setup:
    jobs:
      - setup

```

---

- We can write our script to generate the config (more control)
- Or we can use `path-filtering` job of CircleCI to automate that (easy, less control)
https://circleci.com/docs/2.0/configuration-cookbook/?section=examples-and-guides#configyml

---

## Exercise 5:
1. Read the `config-template.yml`
2. Read the `generate_config.rb` and run it
3. (Optional) `circleci config validate .circleci/config-generated.yml`
4. Write the `config.yml` using dynamic configuration syntax
5. Change the `js/foo.js` to trigger only the Jest test job


