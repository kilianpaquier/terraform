package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/url"
	"os"

	"github.com/google/go-github/v78/github"
	"github.com/hashicorp/go-cleanhttp"
)

type Query struct {
	Environment        string `json:"environment"`
	GitHubTokenEnvName string `json:"github_token_env_name"`
	Owner              string `json:"owner"`
	Repository         string `json:"repository"`
}

func run(ctx context.Context, query Query) (string, error) {
	token := os.Getenv(query.GitHubTokenEnvName)
	if token == "" {
		return "", fmt.Errorf("missing '%s' environment variable", query.GitHubTokenEnvName)
	}
	client := github.NewClient(cleanhttp.DefaultClient()).WithAuthToken(token)

	repository, _, err := client.Repositories.Get(ctx, query.Owner, query.Repository)
	if err != nil {
		return "", fmt.Errorf("get repository '%s/%s': %w", query.Owner, query.Repository, err)
	}

	publicKey, _, err := client.Actions.GetEnvPublicKey(ctx, int(repository.GetID()), url.PathEscape(query.Environment))
	if err != nil {
		return "", fmt.Errorf("get environment '%s' public key: %w", query.Environment, err)
	}
	return publicKey.GetKey(), nil
}

func main() {
	var query Query
	if err := json.NewDecoder(os.Stdin).Decode(&query); err != nil {
		slog.Error(err.Error())
		os.Exit(1)
	}

	key, err := run(context.Background(), query)
	if err != nil {
		slog.Error(err.Error())
		os.Exit(1)
	}

	if err := json.NewEncoder(os.Stdout).Encode(map[string]string{"key": key}); err != nil {
		slog.Error(err.Error())
		os.Exit(1)
	}
}
