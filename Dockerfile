FROM golang:latest
RUN mkdir -p /go/src/app/
COPY builderService /go/src/app/builderService
COPY factoryMethod /go/src/app/factoryMethod
COPY postService /go/src/app/postService
COPY singleton /go/src/app/singleton
COPY main /go/src/app/main
EXPOSE 8080
WORKDIR /go/src/app/
RUN go get -d -v ./...
RUN go install -v ./...
RUN mkdir -p /go/src/etcd/
RUN apt-get update && apt-get -y upgrade
# build-essential supplies compilers for c/cpp files. Curl allows to download source-code
RUN apt-get install -y build-essential curl
WORKDIR /go/src/
ENV ETCD_VER v3.3.13

# choose either URL
# Got appropriate version etcd by following instructions present at
# https://github.com/etcd-io/etcd/releases for Linux
ENV GOOGLE_URL https://storage.googleapis.com/etcd
ENV GITHUB_URL https://github.com/etcd-io/etcd/releases/download
ENV DOWNLOAD_URL ${GITHUB_URL}

RUN mkdir -p /tmp/etcd-download-test

RUN curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
RUN tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1
RUN rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

RUN /tmp/etcd-download-test/etcd --version
ENV ETCDCTL_API 3
RUN /tmp/etcd-download-test/etcdctl version
#RUN curl -o build_etcd.sh -SL https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/etcd/3.3.13/build_etcd.sh
#USER root
#RUN ./build_etcd.sh
CMD ["main"]
