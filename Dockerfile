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
   curl -L https://github.com/cjsheets/mkdocs-rtd-dropdown/archive/v0.0.9.zip -o theme.zip && \
   unzip theme.zip && \
   cd mkdocs-rtd-dropdown-0.0.9 && \
   python setup.py install && \
   cd .. && \
   rm -rf get-pip.py theme.zip mkdocs-rtd-dropdown-0.0.9 && \
   go get -u github.com/golang/dep/cmd/dep && \
   apt-get clean

CMD ["/bin/bash"]
