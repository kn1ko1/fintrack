# backend/go_services/Dockerfile
FROM golang:1.16

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o auth ./auth

CMD ["./auth"]