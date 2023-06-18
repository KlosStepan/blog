---
title: GitHub Workflows for CI/CD
date: "2023-06-18T11:20:00.000Z"
---

Continuous integration & Continuous delivery `CI/CD` can be very useful technique when used properly for automating mundane tasks in your development process.

In this post I will show you 3 different **workflows** (or pipelines) that serve different purposes:
1. CI pipeline for PHP application testing CRUD functionality,
2. CD pipeline for React.js frontend deployment into DigitalOcean Kubernetes cluster,
3. CD pipeline for Vue/Nuxt frontend for deployment into Azure AKS.

Each workflow is a scripted array of steps streamlinng some mundane process runnable `on push` or `executed manually`.
## CI pipeline for PHP application testing CRUD functionality
```yaml
name: PHP 7.4 Tests

on:
  push:
    branches:
      - master

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      database:
        image: mysql:8
        env:
          MYSQL_ROOT_PASSWORD: my_secret_pass
        options: >-
          --health-cmd="mysqladmin ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3
        ports:
          - 3306:3306

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '7.4'
          extensions: mbstring, mysqli

      - name: Set env variables
        env:
          ACTIONS_ALLOW_UNSECURE_COMMANDS: 'true'
        run: |
          echo "::set-env name=DATABASE_HOST::0.0.0.0"
          echo "::set-env name=DATABASE_USER::root"
          echo "::set-env name=DATABASE_PASS::my_secret_pass"
          echo "::set-env name=DATABASE_NAME::plavani"
      
      - name: Load MySQL schema and data
        run: mysql -h ${DATABASE_HOST} -u ${DATABASE_USER} --password=${DATABASE_PASS} < ./_db/1_create_proc_schema_init_data.sql

      - name: Prepare env
        run: composer install --no-interaction --no-progress

      - name: Run PHPUnit
        run: vendor/bin/phpunit
```  

## CD pipeline for React.js frontend deployment into DOKS cluster
```yaml
name: Build->push->deploy 'lnmap' into my DigitalOcean Kubernetes cluster

on:
  workflow_dispatch:

jobs:

  build-push-deploy:

    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Install doctl
      uses: digitalocean/action-doctl@v2
      with:
        token: ${{ secrets.DIGITALOCEAN_ACCESS_TOKEN }}

    - name: Build Docker image
      run: docker build -t stepanklos/lightning_map:$(echo $GITHUB_SHA | head -c7) .

    - name: Dockerhub login
      run: docker login --username ${{ secrets.DOCKER_USERNAME }} --password ${{ secrets.DOCKER_PASSWORD }}

    - name: Push image to Dockerhub
      run: docker push stepanklos/lightning_map:$(echo $GITHUB_SHA | head -c7)

    - name: Update deployment file
      run: TAG=$(echo $GITHUB_SHA | head -c7) && sed -i 's|<IMAGE>|stepanklos/lightning_map:'${TAG}'|' $GITHUB_WORKSPACE/config/deployment.yaml

    - name: Save DigitalOcean kubeconfig with short-lived credentials
      run: doctl kubernetes cluster kubeconfig save --expiry-seconds 600 ${{ secrets.CLUSTER_NAME }}

    - name: Deploy to DigitalOcean Kubernetes
      run: kubectl apply -f $GITHUB_WORKSPACE/config/deployment.yaml

    - name: Verify Deployment
      run: kubectl rollout status deployment/lnmap


```
## CD pipeline for Vue/Nuxt frontend for deployment into Azure AKS
```yaml
name: Build->push 'geoportal-frontend' into ACR //TODO deployment into AKS

on:
  workflow_dispatch:
  
jobs:

  build-push:

    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3
      
    - name: Build Docker image
      run: docker build -t cr98w54wcn2395hcjhu85u.azurecr.io/geoportal-frontend-test-1:$(echo $GITHUB_SHA | head -c7) .

    # TODO script another steps
```
