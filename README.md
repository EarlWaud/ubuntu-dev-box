# ubuntu-dev-box
Trying out a ubuntu container as developer box

This developer environment is based on Ubuntu 14.04 LTS

The user is "dev"

# build
```make all```

or

```docker image build -t ubuntu-devbox .```

# run
```make run```

or

```docker container run -it --name devbox --privileged ubuntu-devbox:latest```


# clean up everything
```make clean```

or


```
docker container rm devbox
docker image rm --force ubuntu-devbox:latest
```

# TODO
fix/update the volume mounts

fix the hard coding of the path for rmv, ruby, and rails

add test scripts for testing stuff like Artifactory pull and push for each type of Artifact

install yarm for NPM work

