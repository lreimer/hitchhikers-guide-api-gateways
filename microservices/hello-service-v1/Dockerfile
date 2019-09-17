FROM golang:1.7.3-alpine

ENV SOURCES /go/src/github.com/lreimer/hello-service-v1/

COPY . ${SOURCES}

RUN cd ${SOURCES} && CGO_ENABLED=0 go install -a

ENTRYPOINT hello-service-v1
EXPOSE 8080
