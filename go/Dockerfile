FROM golang:1.23-alpine AS build

WORKDIR /app

COPY go/go.mod .
RUN go mod download

COPY go/ .
RUN CGO_ENABLED=0 GOOS=linux go build -o helloworld .

FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app

COPY --from=build /app/helloworld .
COPY shared /shared

EXPOSE 5004

CMD ["./helloworld"]
