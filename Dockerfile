FROM ubuntu:14.04

# install some desired packages
RUN apt-get update -y && apt-get install -y \
  mercurial \
  git \
  curl \
  vim \
  screen \
  gnupg2 \
  nano \
  openssl \
  whois 

# Setup user "dev"
RUN useradd --create-home -m -s /bin/bash -G sudo -p $(mkpasswd -m sha-512 dev-password) dev
RUN echo "dev  ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chown -R dev: /home/dev
COPY ./inputrc "/home/dev/.inputrc"
RUN sudo chown dev:dev "/home/dev/.inputrc"

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

# Create a shared data volume
# We need to create an empty file, otherwise the volume will
# belong to root.
# This is probably a Docker bug.
RUN mkdir /var/shared/
RUN touch /var/shared/placeholder
RUN chown -R dev:dev /var/shared
VOLUME /var/shared

#ADD vimrc /home/dev/.vimrc
#ADD vim /home/dev/.vim
#ADD bash_profile /home/dev/.bash_profile
#ADD gitconfig /home/dev/.gitconfig

# Link in shared parts of the home directory
#RUN ln -s /var/shared/.ssh
#RUN ln -s /var/shared/.bash_history
#RUN ln -s /var/shared/.maintainercfg

# Add a fun prompt for dev user
# alien:"\xF0\x9F\x91\xBD" fish:"\xF0\x9F\x90\xA0" elephant:"\xF0\x9F\x91\xBD" moneybag:"\xF0\x9F\x92\xB0"
RUN echo 'PS1="\[$(tput bold)$(tput setaf 4)\]dev-box $(echo -e "\xF0\x9F\x92\xB0") \[$(tput sgr0)\] [\\u@\\h]:\\W \\$ "' >> /home/dev/.bashrc && \
    echo 'alias ls="ls --color=auto"' >> /home/dev/.bashrc

# Add timestamp to history.
RUN echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> /home/dev/.bashrc

# Alias for tree view of commit history.
RUN git config --global alias.tree "log --all --graph --decorate=short --color --format=format:'%C(bold blue)%h%C(reset) %C(auto)%d%C(reset)\n         %C(blink yellow)[%cr]%C(reset)  %x09%C(white)%an: %s %C(reset)'"
# cache is useless to keep
RUN apt-get autoremove -y
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# switch to dev user
ENV USER dev
ENV HOME /home/dev
WORKDIR /home/dev
USER dev


COPY dev-box-start.sh /home/dev/dev-box-start.sh
CMD ["/bin/bash", "/home/dev/dev-box-start.sh"]
