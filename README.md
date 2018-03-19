# Gloo Docs

Generate Docker image containing latest Gloo docs.

`build-image.sh` generates the image used by the Jenkins job to create the docs image.

Currently the image used to generate docs has docker installed to make sure `make site`
works. Generating docs and creating image should be separate. Future fix me!

Actual generation and publishing of docker image is done in second stage.

