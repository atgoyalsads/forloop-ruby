# Jets Project

This README would normally document whatever steps are necessary to get the application up and running.

Things you might want to cover:

* Dependencies
* Configuration
* Database setup
* How to run the test suite
* Deployment instructions


User.find_by(contact: "6262539743").sessions.destroy_all
User.find_by(contact: "6262539743").received_rating_questions.destroy_all
User.find_by(contact: "6262539743").rating_questions.destroy_all
User.find_by(contact: "6262539743").dialedCalls.destroy_all
User.find_by(contact: "6262539743").receivedCalls.destroy_all
User.find_by(contact: "6262539743").callHistories.destroy_all
User.find_by(contact: "6262539743").destroy