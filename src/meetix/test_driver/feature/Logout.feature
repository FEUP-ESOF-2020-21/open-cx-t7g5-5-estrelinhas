Feature: Logout
    As an user, I want to be able to logout

    Scenario: Logout
        Given I'm logged in and in "ConferenceListPage"
        When I open the drawer
        And I tap the "logoutButton" button
        Then I expect to be in "SignInPage" page