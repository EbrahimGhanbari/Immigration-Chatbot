package workflows

import (
	"go.temporal.io/sdk/worker"
)

const (
	ChatBotTaskQueue = "coding-challenge.chatbot"
)

func RegisterToChatbot(registry worker.WorkflowRegistry) {
	registry.RegisterWorkflow(ChatBotWorkflow)
}
