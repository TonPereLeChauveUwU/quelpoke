# Étape 1 : build de l'appli
FROM golang:1.22 AS builder

WORKDIR /app

# Copier les fichiers Go et le template
COPY go.mod ./
COPY main.go ./
COPY index.tmpl.html ./

# Télécharger les dépendances (au cas où)
RUN go mod tidy

# Compiler un binaire statique
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o quelpoke .

# Étape 2 : image finale minimale
FROM gcr.io/distroless/base-debian12

WORKDIR /app

# Copier le binaire compilé
COPY --from=builder /app/quelpoke /app/quelpoke

# Le binaire contient le template via go:embed, donc rien d'autre à copier. [file:3]

# Variables d'environnement par défaut
ENV ADDR=0.0.0.0
ENV PORT=8080
ENV VERSION=docker

EXPOSE 8080

ENTRYPOINT ["/app/quelpoke"]
