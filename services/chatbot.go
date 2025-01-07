package services

import (
	"strings"

	"github.com/MyBeaconLabs/coding-challenge.git/schemas"
)

// The chatbot engine look for keyword and respond based on that.
// TODO -> We always return nil error here but generally you will be making call to external service which can error
func ChatbotConversation(msg schemas.Message) (string, error) {
	db := map[string][]string{
		"greeting": {"hi", "hello", "how are you"},
		"visa":     {"visa"},
		"student":  {"student", "study", "university"},
		"visitor":  {"visitor", "tourist", "pleasure"},
		"work":     {"work", "job"},
	}

	switch {
	case findElementInString(db["greeting"], msg.Content):
		return "Hello, hope you are doing good. How can I help you", nil
	case findElementInString(db["work"], msg.Content):
		return "In order to ge the work visa, you need to find a job first", nil
	case findElementInString(db["student"], msg.Content):
		return "In order to ge the study permit, you need an admission from a university", nil
	case findElementInString(db["visitor"], msg.Content):
		return "In order to ge the visitor visa, you need to apply through cic", nil
	case findElementInString(db["visa"], msg.Content):
		return "Awesome, I can help you with that, what kind of visa are you looking into?", nil
	default:
		return "sorry I did not get what you are asking, ask about type of visa", nil
	}
}

// find word in the text
func findElementInString(elements []string, text string) bool {
	for _, e := range elements {
		if strings.Contains(strings.ToLower(text), e) {
			return true
		}
	}
	return false
}
