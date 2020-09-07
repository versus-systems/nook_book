FROM amazonlinux:latest

RUN yum update -y
RUN yum install -y autoconf gcc make ncurses-devel openssh tar wget zlib zlib-devel

WORKDIR ~

RUN wget http://erlang.org/download/otp_src_22.3.tar.gz && \
    wget https://github.com/elixir-lang/elixir/archive/v1.10.4.tar.gz

RUN tar -zxf otp_src_22.3.tar.gz && \
    cd otp_src_22.3 && \
    ./configure && \
    make && \
    make install

RUN tar -zxf v1.10.4.tar.gz && \
    cd elixir-1.10.4 && \
    export LANG=en_US.UTF-8 && \
    export LC_ALL=en_US.UTF-8 && \
    make && \
    make install
