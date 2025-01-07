package services

import (
	"testing"

	"github.com/MyBeaconLabs/coding-challenge.git/schemas"
)

// **disclaimer -> This unit test code is created by chatgpt
func TestFindElementInString(t *testing.T) {
	tests := []struct {
		name     string
		elements []string
		text     string
		expected bool
	}{
		{
			name:     "Element Found - Exact Match",
			elements: []string{"hello", "world"},
			text:     "hello",
			expected: true,
		},
		{
			name:     "Element Found - Case Insensitive",
			elements: []string{"hello", "world"},
			text:     "HeLLo there",
			expected: true,
		},
		{
			name:     "Element Not Found",
			elements: []string{"foo", "bar"},
			text:     "hello world",
			expected: false,
		},
		{
			name:     "Empty Elements",
			elements: []string{},
			text:     "hello",
			expected: false,
		},
		{
			name:     "Empty Text",
			elements: []string{"hello", "world"},
			text:     "",
			expected: false,
		},
		{
			name:     "Substring Match",
			elements: []string{"hello", "world"},
			text:     "sayhello",
			expected: true,
		},
		{
			name:     "No Match in Larger Text",
			elements: []string{"foo", "bar"},
			text:     "The quick brown fox jumps over the lazy dog",
			expected: false,
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			result := findElementInString(test.elements, test.text)
			if result != test.expected {
				t.Errorf("findElementInString(%v, %q) = %v; want %v", test.elements, test.text, result, test.expected)
			}
		})
	}
}

func TestChatbotConversation(t *testing.T) {
	tests := []struct {
		name     string
		message  schemas.Message
		expected string
	}{
		{
			name:     "Greeting Message",
			message:  schemas.Message{User: "testUser", Content: "hello"},
			expected: "Hello, hope you are doing good. How can I help you",
		},
		{
			name:     "Work Visa Query",
			message:  schemas.Message{User: "testUser", Content: "I am looking for a job"},
			expected: "In order to ge the work visa, you need to find a job first",
		},
		{
			name:     "Student Visa Query",
			message:  schemas.Message{Content: "I want to study at a university"},
			expected: "In order to ge the study permit, you need an admission from a university",
		},
		{
			name:     "Visitor Visa Query",
			message:  schemas.Message{User: "testUser", Content: "I am a tourist"},
			expected: "In order to ge the visitor visa, you need to apply through cic",
		},
		{
			name:     "Generic Visa Query",
			message:  schemas.Message{User: "testUser", Content: "tell me about visa"},
			expected: "Awesome, I can help you with that, what kind of visa are you looking into?",
		},
		{
			name:     "Unknown Query",
			message:  schemas.Message{User: "testUser", Content: "Can you help with housing?"},
			expected: "sorry I did not get what you are asking, ask about type of visa",
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			response, err := ChatbotConversation(test.message)

			// Check for no error
			if err != nil {
				t.Errorf("Unexpected error: %v", err)
			}

			// Check if the response matches the expected output
			if response != test.expected {
				t.Errorf("ChatbotConversation(%v) = %q; want %q", test.message.Content, response, test.expected)
			}
		})
	}
}
