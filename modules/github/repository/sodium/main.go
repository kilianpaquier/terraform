package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"log/slog"
	"os"

	"golang.org/x/crypto/nacl/box"
)

type Query struct {
	SodiumPublicKey  string `json:"sodium_public_key"`
	SodiumSecretName string `json:"sodium_secret_name"`
}

func run(query Query, secret string) (string, error) {
	publicKeyBytes, err := base64.StdEncoding.DecodeString(query.SodiumPublicKey)
	if err != nil {
		return "", fmt.Errorf("decode string: %w", err)
	}
	if len(publicKeyBytes) > 32 {
		return "", fmt.Errorf("invalid public_key size '%d'", len(publicKeyBytes))
	}

	var pubKey [32]byte
	copy(pubKey[:], publicKeyBytes)

	sealed, err := box.SealAnonymous(nil, []byte(secret), &pubKey, nil)
	if err != nil {
		return "", fmt.Errorf("seal anonymous: %w", err)
	}
	return base64.StdEncoding.EncodeToString(sealed), nil
}

func main() {
	var query Query
	if err := json.NewDecoder(os.Stdin).Decode(&query); err != nil {
		slog.Error(err.Error())
		os.Exit(1)
	}

	secret := os.Getenv(query.SodiumSecretName)
	if secret == "" {
		slog.Error(fmt.Sprintf("missing '%s' environment variable", query.SodiumSecretName))
		os.Exit(1)
	}

	encrypted, err := run(query, secret)
	if err != nil {
		slog.Error(err.Error())
		os.Exit(1)
	}

	if err := json.NewEncoder(os.Stdout).Encode(map[string]string{"sodium_encrypted_value": encrypted}); err != nil {
		slog.Error(err.Error())
		os.Exit(1)
	}
}
