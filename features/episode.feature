Feature: Clinician creates episode for patient
  As a logged in clinician
  I want to start a new episode for a patient
  So I can track their treatment on the system

  Background:
    Given an authenticated clinician called Barney
    And a patient called "Fred"

  Scenario: Barney creates new episode for Fred
    When Barney views Freds patient details card
    Then Barney should see "Create Episode"
