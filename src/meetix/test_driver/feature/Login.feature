Feature: Login
    As an user, I want to be able to login to the app, so that I can use all the available features.

    Scenario: When email or password are incorrect and SignIn is clicked
            Given I have "emailField" and "passwordField" and "signInButton"
            When I fill "emailField" field with "teste@gmail.com"
            And I fill "passwordField" field with "notapassword"
            Then I tap the "signInButton" button
            Then I expect to be in "SignInPage"

    Scenario: When both email and password are correct and SignIn is clicked
        Given I have "emailField" and "passwordField" and "signInButton"
        When I fill "emailField" field with "teste@gmail.com"
        And I fill "passwordField" field with "password"
        Then I tap the "signInButton" button
        Then I pause for 2 seconds
        Then I expect to be in "ConferenceListPage"