package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

	"github.com/MyBeaconLabs/coding-challenge.git/schemas"
	"github.com/MyBeaconLabs/coding-challenge.git/temporal/workflows"
	"go.temporal.io/api/enums/v1"
	"go.temporal.io/sdk/client"
)

// enable CORS for index.html
func enableCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}

// the handler manage the data and
func handler(w http.ResponseWriter, r *http.Request) {
	var msg schemas.Message
	_ = json.NewDecoder(r.Body).Decode(&msg)

	if msg.Content == "" {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	c, err := client.Dial(client.Options{
		HostPort:  os.Getenv("TEMPORAL_HOST_NAME"),
		Namespace: client.DefaultNamespace,
	})

	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	var res string
	wf, err := c.ExecuteWorkflow(r.Context(), client.StartWorkflowOptions{
		WorkflowIDReusePolicy: enums.WORKFLOW_ID_REUSE_POLICY_ALLOW_DUPLICATE,
		TaskQueue:             workflows.ChatBotTaskQueue,
	}, workflows.ChatBotWorkflow, msg)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	defer c.Close()
	wf.Get(r.Context(), &res)

	json.NewEncoder(w).Encode(res)
}

func main() {
	mu := http.NewServeMux()
	mu.HandleFunc("/chat", handler)
	log.Println("Server started at http://localhost:3002")
	log.Fatal(http.ListenAndServe(":3002", enableCORS(mu)))
}
