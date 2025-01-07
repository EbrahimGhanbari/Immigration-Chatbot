package log

import (
	"context"

	"go.temporal.io/sdk/activity"
	"go.temporal.io/sdk/log"
	"go.temporal.io/sdk/workflow"
)

const (
	LogStartingWorkflowString  = "Starting Workflow"
	LogCompletedWorkflowString = "Completed Workflow"
	LogStartingActivityString  = "Starting Activity"
	LogCompletedActivityString = "Completed Activity"
)

func GetActivityLogger(ctx context.Context) (logger log.Logger) {
	return activity.GetLogger(ctx)
}

func GetWorkflowLogger(ctx workflow.Context) log.Logger {
	return workflow.GetLogger(ctx)
}
