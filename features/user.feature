
Feature: user

  Scenario: login successful
    When I send and accept JSON
    When I set request body from "features/examples/login.json"
    When I send a POST request to "/app_api/session/authenticate/"
    Then the response status should be "200"
    Then the JSON response should follow "features/schemas/login_response.schema.json"
    Then the JSON response should have key "$.result.username" with "cucumbertest"
@working
  Scenario: login successful
      When I send and accept JSON
    When I set request body from "features/examples/login.json"
    When I send a POST request to "/app_api/session/authenticate/"
    Then the response status should be "200"
    Then the JSON response should follow "features/schemas/login_response.schema.json"
    Then the JSON response should have key "$.result.username" with "cucumbertest"
    When I grab "$.result.session_id" as "session"
    When I send and accept JSON
    When I set request body from "features/examples/login.json"
    When I send a POST request to "/app_api/session/authenticate/" with:
      | $..login | update_address |
      | $..password | 123456 |
      | $..id | {session} |
    Then the response status should be "200"
    Then the JSON response should follow "features/schemas/login_response.schema.json"
    Then the JSON response should have key "$.result.username" with "update_address"

  Scenario: logout
    Given I'm already logged in as "logout"
    When I set request body from "features/examples/logout.json"
    When I send a POST request to "/app_api/session/destroy/"
    Then the response status should be "200"
    Then the JSON response should follow "features/schemas/logout_response.schema.json"
    Then the JSON response should have key "$..title" with "注销成功"

  Scenario: change password
    Given I'm already logged in as "changepassword"
    When I set request body from "features/examples/change_password.json"
    When I send a POST request to "/app_api/session/change_password/"
    Then the response status should be "200"
    Then the JSON response should follow "features/schemas/change_password_response.schema.json"
    Then the JSON response should have key "$.result.msg" with "密码更改成功"

  Scenario: get my address list
    Given I'm already logged in as "cucumbertest"
    When I set request body from "features/examples/list_address.json"
    When I send a POST request to "/app_api/user/list_address"
    Then the response status should be "200"
    Then the JSON response should follow "features/schemas/list_address_response.schema.json"
    Then the JSON response should have key "$..county_name" with "西城区"
    Then the JSON response should have key "$..state_name" with "Arkansas"

  Scenario: update address
    Given I'm already logged in as "update_address"
    When I set request body from "features/examples/update_address.json"
    When I send a POST request to "/app_api/user/update_address"
    Then the response status should be "200"
    Then the JSON response should follow "features/schemas/update_address_response.schema.json"
    Given I'm already logged in as "update_address"
    When I set request body from "features/examples/list_address.json"
    When I send a POST request to "/app_api/user/list_address"
    Then the response status should be "200"
    Then the JSON response should follow "features/schemas/list_address_response.schema.json"
    Then the JSON response should have key "$..name" with "afterupdate"
