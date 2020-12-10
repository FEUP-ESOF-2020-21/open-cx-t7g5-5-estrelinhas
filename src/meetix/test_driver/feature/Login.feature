Feature: Login screen Validates and then Logs In
    Scenario: when email and password are in the specified format and login is clicked
        Given I have "emailField" and "passwordField" and "signInButton"
        When I fill "emailField" field with "teste@gmail.com"
        And I fill "passwordField" field with "password"
        Then I tap the "signInButton" button
        Then I should have "HomePage" on screen