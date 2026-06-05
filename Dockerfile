# syntax=docker/dockerfile:1

# ETAP 1: Builder
FROM golang:alpine AS builder
WORKDIR /app

# GitHub Actions udostępni nam pliki robocze w kontekście budowania, 
# więc po prostu kopiujemy je z dysku serwera CI.
COPY main.go .

RUN apk add --no-cache ca-certificates
RUN go mod init weatherapp && \
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o weatherapp main.go

# ETAP 2: Docelowy minimalny obraz
FROM scratch
LABEL org.opencontainers.image.authors="Jakub Gwo"

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/weatherapp /weatherapp

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["/weatherapp", "-health"]
CMD ["/weatherapp"]