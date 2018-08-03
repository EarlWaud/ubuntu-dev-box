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
  openssh-server \
  openssh-client \
  nano \
  openssl \
  libreadline6 \
  libreadline6-dev \
  zlib1g \
  zlib1g-dev \
  libssl-dev \
  libyaml-dev \
  libsqlite3-dev \
  sqlite3 \
  libxml2-dev \
  libxslt-dev \
  autoconf \
  libc6-dev \
  ncurses-dev \
  whois 


# basics
#automake libtool bison subversion pkg-config

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

# Install Ruby and Rails dependencies
# install RVM, Ruby, and Bundler
RUN curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
RUN curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.0"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"
RUN sudo usermod -aG rvm root
RUN sudo usermod -aG rvm dev
RUN /bin/bash -l -c "rvm install ruby --default"
RUN /bin/bash -l -c "rvm install ruby-dev --default"

# Install Rails
RUN /bin/bash -l -c "gem install rails"

RUN echo "export PATH=$PATH:/usr/local/rvm/gems/ruby-2.5.1-dev/bin:/usr/local/rvm/gems/ruby-2.5.1-dev@global/bin:/usr/local/rvm/rubies/ruby-2.5.1-dev/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/rvm/bin" >> /home/dev/.bashrc

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

RUN echo "dev  ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN chown -R dev: /home/dev
USER dev

RUN curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

# Add a fun prompt for dev user
# alien:"\xF0\x9F\x91\xBD" fish:"\xF0\x9F\x90\xA0" elephant:"\xF0\x9F\x91\xBD" moneybag:"\xF0\x9F\x92\xB0"
RUN echo 'PS1="\[$(tput bold)$(tput setaf 4)\]dev-box $(echo -e "\xF0\x9F\x92\xB0") \[$(tput sgr0)\] [\\u@\\h]:\\W \\$ "' >> /home/dev/.bashrc && \
    echo 'alias ls="ls --color=auto"' >> /home/dev/.bashrc

COPY dev-box-start.sh /home/dev/dev-box-start.sh
CMD ["/bin/bash", "/home/dev/dev-box-start.sh"]
