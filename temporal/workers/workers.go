package workers

import (
	"go.temporal.io/sdk/client"
	"go.temporal.io/sdk/worker"
)

// NewWorker build new worker for temporal.
func NewWorker(taskQueue string, options worker.Options) (worker.Worker, error) {
	c, err := client.Dial(client.Options{
		HostPort:  client.DefaultHostPort,
		Namespace: client.DefaultNamespace,
	})
	if err != nil {
		return nil, err
	}

	return worker.New(c, taskQueue, options), nil
}
