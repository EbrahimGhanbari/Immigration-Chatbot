package activities

import (
	"go.temporal.io/sdk/worker"
)

// Register the activities to the relevant worker
func RegisterToChatBot(registry worker.ActivityRegistry) {
	registry.RegisterActivity(GetChatBotResponse)
}
