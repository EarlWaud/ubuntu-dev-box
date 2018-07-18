# ubuntu-dev-box
Trying out a ubuntu container as developer box

This developer environment is based on Ubuntu 14.04 LTS
&nbsp;

The user is "dev"

# build
```make all```
&nbsp;
or
&nbsp;
```docker image build -t ubuntu-devbox .```

# run
```make run```
&nbsp;
or
&nbsp;
```docker container run -it --name devbox --privileged ubuntu-devbox:latest```


# clean up everything
```make clean```
&nbsp;
or
&nbsp;

```
docker container rm devbox
docker image rm --force ubuntu-devbox:latest
```

# TODO
fix the hard coding of the path

fix ruby

add helm

add test scripts for testing stuff like Artifactory pull and push for each type of Artifact

