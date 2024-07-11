FROM golang:1.22.5-alpine as builder

WORKDIR /go/src/github.com/corka149/jarvis

COPY . .

RUN go get -d -v ./...

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o jarvis ./cmd/main.go

FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /go/src/github.com/corka149/jarvis/jarvis .

RUN chmod +x jarvis

CMD ["./jarvis"]
