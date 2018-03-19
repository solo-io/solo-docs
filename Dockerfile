FROM golang:1.10

RUN curl -L https://github.com/google/protobuf/releases/download/v3.5.1/protoc-3.5.1-linux-x86_64.zip -o protoc.zip && \
   apt-get update && \
   apt install unzip && \
   unzip protoc.zip && \
   cp bin/protoc /usr/local/bin && \
   cp -r include/* /usr/local/include && \
   rm -rf protoc.zip bin include readme.txt && \
   curl -L -o get-pip.py https://bootstrap.pypa.io/get-pip.py && \
   python get-pip.py && \
   pip install mkdocs && \
   git clone https://github.com/cjsheets/mkdocs-rtd-dropdown.git && \
   cd mkdocs-rtd-dropdown && \
   python setup.py install && \
   cd .. && \
   rm -rf get-pip.py mkdocs-rtd-dropdown && \
   go get -u github.com/golang/dep/cmd/dep && \
   curl -L https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64/docker-ce_17.12.1~ce-0~debian_amd64.deb -o docker.deb && \
   (dpkg -i docker.deb || true) && \
   apt-get --yes -f install && \
   rm docker.deb && \
   apt-get clean

CMD ["/bin/bash"]
