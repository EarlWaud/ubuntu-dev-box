FROM ubuntu:14.04

# install some desired packages
RUN apt-get update -y && apt-get install -y \
  mercurial \
  git \
  python \
  curl \
  vim \
  strace \
  diffstat \
  pkg-config \
  cmake \
  build-essential \
  tcpdump \
  screen \
  gnupg2 \
  whois 

# Setup user "dev"
RUN useradd --create-home -m -s /bin/bash -G sudo -p $(mkpasswd -m sha-512 intuit01) dev

# Install docker-cd
RUN apt-get update -y && apt-get install -y \
  apt-transport-https \
  ca-certificates \
  software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
RUN apt-get update -y && apt-get install -y docker-ce
RUN usermod -aG docker dev
RUN update-rc.d docker enable

#install docker-compose
RUN curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose 
RUN chmod +x /usr/local/bin/docker-compose

# Install Ruby and Rails dependencies
#RUN gpg2 --keyserver hkp://keys.gnupg.net:80 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN gpg --keyserver $(getent hosts keys.gnupg.net | awk '{ print $1 }' | head -1) --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN gpg --keyserver $(getent hosts keys.gnupg.net | awk '{ print $1 }' | head -1) --recv-keys 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.0"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"
RUN usermod -aG rvm root
RUN usermod -aG rvm dev
RUN /bin/bash -l -c "rvm install ruby --default"
RUN /bin/bash -l -c "rvm install ruby-dev --default"

#RUN apt-get update && apt-get install -y \
#  ruby \
#  ruby-dev \
#  build-essential \
#  libxml2-dev \
#  libxslt1-dev \
#  zlib1g-dev \
#  libsqlite3-dev 

# Install Rails
RUN /bin/bash -l -c "gem install rails"
#RUN gem install rails

# Install npm
RUN apt-get install -y nodejs npm

# Install Pyton pre-reqs
RUN apt-get update -y && apt-get install -y \
  build-essential \ 
  libpq-dev \
  libssl-dev \ 
  openssl \ 
  libffi-dev \ 
  zlib1g-dev

# Install Pyton
RUN apt-get update -y && apt-get install -y \
  python3-pip \ 
  python3-dev

# Install go
#RUN curl https://go.googlecode.com/files/go1.2.1.linux-amd64.tar.gz | tar -C /usr/local -zx
RUN curl https://storage.googleapis.com/golang/go1.9.1.linux-amd64.tar.gz | tar -C /usr/local -zx
ENV GOROOT /usr/local/go
ENV PATH /usr/local/go/bin:$PATH
RUN echo $GOPATH

# Setup go home environment
RUN mkdir -p /home/dev/go /home/dev/bin /home/dev/lib /home/dev/include
ENV PATH /home/dev/bin:$PATH
ENV PKG_CONFIG_PATH /home/dev/lib/pkgconfig
ENV LD_LIBRARY_PATH /home/dev/lib
#ENV GOPATH /home/dev/go:$GOPATH
ENV GOPATH /home/dev/go

#RUN go get github.com/dotcloud/gordon/pulls

# Create a shared data volume
# We need to create an empty file, otherwise the volume will
# belong to root.
# This is probably a Docker bug.
RUN mkdir /var/shared/
RUN touch /var/shared/placeholder
RUN chown -R dev:dev /var/shared
VOLUME /var/shared

WORKDIR /home/dev
ENV HOME /home/dev
#ADD vimrc /home/dev/.vimrc
#ADD vim /home/dev/.vim
#ADD bash_profile /home/dev/.bash_profile
#ADD gitconfig /home/dev/.gitconfig

# Link in shared parts of the home directory
RUN ln -s /var/shared/.ssh
RUN ln -s /var/shared/.bash_history
RUN ln -s /var/shared/.maintainercfg

RUN echo 'PS1="\[$(tput bold)$(tput setaf 4)\]dev-box $(echo -e "\xF0\x9F\x91\xBD") \[$(tput sgr0)\] [\\u@\\h]:\\W \\$ "' >> /root/.bashrc && \
    echo 'alias ls="ls --color=auto"' >> /root/.bashrc


RUN chown -R dev: /home/dev
USER dev

COPY dev-box-start.sh /home/dev/dev-box-start.sh
CMD ["/bin/bash", "/home/dev/dev-box-start.sh"]
