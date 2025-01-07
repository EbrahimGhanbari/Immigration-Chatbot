package activities

import (
	"context"

	"github.com/MyBeaconLabs/coding-challenge.git/schemas"
	"github.com/MyBeaconLabs/coding-challenge.git/services"
	log "github.com/MyBeaconLabs/coding-challenge.git/temporal/logger"
)

// this activity get data from chatbot engine
func GetChatBotResponse(ctx context.Context, msg schemas.Message) (string, error) {
	logger := log.GetActivityLogger(ctx)
	logger.Info(log.LogStartingActivityString, "Message", msg)

	res, err := services.ChatbotConversation(msg)
	if err != nil {
		return "", err
	}

	logger.Info(log.LogCompletedActivityString)
	return res, nil
}
