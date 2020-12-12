Feature: Login
    User should be able to login if both the email and password are correct
    Scenario: when email and password are in the specified format and login is clicked
        Given I have "emailField" and "passwordField" and "signInButton"
        When I fill "emailField" field with "teste@gmail.com"
        And I fill "passwordField" field with "password"
        Then I tap the "signInButton" button
        Then I pause for 2 seconds
        Then I expect to be in "ConferenceListPage"