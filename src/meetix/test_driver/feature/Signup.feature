Feature: Signup
    As an user, I create an account in Meetix, so that I have access to all the available features.

    Background:
        Given I'm in "SignInPage" page
        When I tap the "signUpButton" button
        Then I expect to be in "SignUpPage" page

    Scenario: Sign up when email is already associated with an account
        Given I have "nameField" and "emailField" and "passwordField" and "signInButton"
        When I fill the "nameField" field with "teste"
        And I fill the "emailField" field with "teste@gmail.com"
        And I fill the "passwordField" field with "anything"
        When I tap the "signUpButton" button
        Then I expect to be in "SignUpPage" page
        And I expect the "warning" to be "The email address is already in use by another account."

    Scenario: Sign up when email is not valid
         Given I have "nameField" and "emailField" and "passwordField" and "signInButton"
         When I fill the "nameField" field with "teste"
         And I fill the "emailField" field with "notanemail"
         And I fill the "passwordField" field with "anything"
         When I tap the "signUpButton" button
         Then I expect to be in "SignUpPage" page
         And I expect the "warning" to be "The email address is badly formatted."