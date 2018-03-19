#!/usr/bin/env groovy
podTemplate(label: 'docs-builder',
containers: [
    containerTemplate(
        name: 'docs',
        image: 'soloio/gloo-docs:latest',
        ttyEnabled: true,
        command: 'cat'),
    containerTemplate(
        name: 'docker',
        image: 'docker:17.12',
        ttyEnabled: true,
        command: 'cat'),
],
envVars: [
    envVar(key: 'DOCKER_CONFIG', value: '/etc/docker')
],
volumes: [
    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
    secretVolume(secretName: 'soloio-docker-hub', mountPath: '/etc/docker'),
    secretVolume(secretName: 'soloio-github', mountPath: '/etc/github')
]) {

    properties([
        parameters ([
            booleanParam(
                defaultValue: false,
                description: 'Publish',
                name: 'PUBLISH')
        ])
    ])

    node('docs-builder') {
        stage('generate') {
            container('docs') {
                echo 'Generating docs...'
                sh '''
                    go get github.com/gogo/protobuf/...
                    go get github.com/ilackarms/protoc-gen-doc/...
                    export BASE=`pwd`
                    mkdir solo-io
                    cd solo-io
                    git clone https://github.com/solo-io/gloo.git
                    git clone https://github.com/solo-io/gloo-api.git
                    cd $GOPATH
                    mkdir -p src/github.com
                    cd src/github.com
                    ln -s $BASE/solo-io .
                    cd solo-io/gloo-api
                    dep ensure -v -vendor-only
                    cd ../gloo
                    dep ensure -v -vendor-only
                    export VERSION=`cat version`
                    export IMAGE_TAG=v$VERSION-$BUILD_NUMBER
                    make site
                '''
            }
        }

        stage('publish') {
            container('docker') {
                echo 'Publishing Docker image...'
                sh '''
                    cd solo-io/gloo
                    export VERSION=`cat version`
                    export IMAGE_TAG=v$VERSION-$BUILD_NUMBER
                    docker build -t soloio/nginx-docs:$IMAGE_TAG -t soloio/nginx-docs:latest -f Dockerfile.site .
                    if [ "$PUBLISH" = "true"]; then
                        docker push soloio/nginx-docs:$IMAGE_TAG
                        docker push soloio/nginx-docs:latest
                    fi
                '''
            }
        }

    }
}
