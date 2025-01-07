package main

import (
	"log"

	"github.com/MyBeaconLabs/coding-challenge.git/temporal/activities"
	"github.com/MyBeaconLabs/coding-challenge.git/temporal/workers"
	"github.com/MyBeaconLabs/coding-challenge.git/temporal/workflows"
	"go.temporal.io/sdk/worker"
)

// run chatbot worker
func runWorker() error {
	w, err := workers.NewWorker(workflows.ChatBotTaskQueue, worker.Options{})
	if err != nil || w == nil {
		return err
	}
	defer w.Stop()

	//register workflow and activities
	workflows.RegisterToChatbot(w)
	activities.RegisterToChatBot(w)

	return w.Run(worker.InterruptCh())
}

func main() {
	if err := runWorker(); err != nil {
		log.Fatalln(err)
	}
}
