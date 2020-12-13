Feature: Login
    As an user, I want to be able to login to the app, so that I can use all the available features.

    Scenario: Login when password is incorrect
        Given I have "emailField" and "passwordField" and "signInButton"
        When I fill the "emailField" field with "teste@gmail.com"
        And I fill the "passwordField" field with "notapassword"
        When I tap the "signInButton" button
        Then I expect to be in "SignInPage" page
        And I expect the "warning" to be "The password is invalid or the user does not have a password."

    Scenario: Login when both email and password are correct
        Given I have "emailField" and "passwordField" and "signInButton"
        When I fill the "emailField" field with "teste@gmail.com"
        And I fill the "passwordField" field with "password"
        When I tap the "signInButton" button
        Then I pause for 2 seconds
        Then I expect to be in "ConferenceListPage" page