import json
import random

class Chatbot:
    def __init__(self):
        with open('responses.json', 'r', encoding='utf-8') as f:
            self.responses = json.load(f)

    def get_response(self, user_input):
        user_input = user_input.lower()
        
        if any(greet in user_input for greet in ["hello", "hi"]):
            return random.choice(self.responses['greetings']['roman'])
        elif any(farewell in user_input for farewell in ["goodbye", "bye"]):
            return random.choice(self.responses['farewells']['roman'])
        elif "how are you" in user_input:
            return random.choice(self.responses['how_are_you']['roman'])
        else:
            return random.choice(self.responses['default']['roman'])

if __name__ == "__main__":
    chatbot = Chatbot()
    while True:
        user_input = input("You: ")
        if user_input.lower() in ["exit", "quit"]:
            break
        response = chatbot.get_response(user_input)
        print(f"Chatbot: {response}")