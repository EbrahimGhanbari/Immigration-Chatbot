package workflows

import (
	"time"

	"github.com/MyBeaconLabs/coding-challenge.git/schemas"
	"github.com/MyBeaconLabs/coding-challenge.git/temporal/activities"
	log "github.com/MyBeaconLabs/coding-challenge.git/temporal/logger"
	"go.temporal.io/sdk/temporal"
	"go.temporal.io/sdk/workflow"
)

func chatbotContext(ctx workflow.Context) workflow.Context {
	return workflow.WithActivityOptions(
		ctx,
		workflow.ActivityOptions{
			TaskQueue:              ChatBotTaskQueue,
			StartToCloseTimeout:    time.Hour * 1,
			ScheduleToCloseTimeout: time.Hour * 1,
			HeartbeatTimeout:       time.Minute * 20,
			RetryPolicy:            &temporal.RetryPolicy{MaximumAttempts: 5},
		})
}

// the chatbot workflow, call the chatbot activity.
func ChatBotWorkflow(ctx workflow.Context, msg schemas.Message) (string, error) {
	logger := log.GetWorkflowLogger(ctx)
	logger.Info(log.LogStartingWorkflowString, "Message", msg)

	// The chatbot result is undeterministic so it has to be in the activity so temporal can track its state
	var res string
	err := workflow.ExecuteActivity(chatbotContext(ctx), activities.GetChatBotResponse, msg).Get(ctx, &res)
	if err != nil {
		return "", err
	}

	logger.Info(log.LogCompletedWorkflowString)
	return res, nil
}
