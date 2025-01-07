FROM golang:1.23 as builder
WORKDIR /usr/src/app
COPY go.mod go.sum ./
RUN go mod download && go mod verify
ARG path
COPY . .
RUN go build -o main ${path}
CMD ["./main"]