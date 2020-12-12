import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';

class CheckGivenWidgets
    extends Given3WithWorld<String, String, String, FlutterWorld> {
  @override
  Future<void> executeStep(String input1, String input2, String input3) async {
    final textinput1 = find.byValueKey(input1);
    final textinput2 = find.byValueKey(input2);
    final button = find.byValueKey(input3);
    await FlutterDriverUtils.isPresent(world.driver, textinput1);
    await FlutterDriverUtils.isPresent(world.driver, textinput2);
    await FlutterDriverUtils.isPresent(world.driver, button);
  }

  @override
  RegExp get pattern => RegExp(r"I have {string} and {string} and {string}");
}

class CheckFieldWidget extends Then2WithWorld<String, String, FlutterWorld> {
@override
Future<void> executeStep(String field, String input) async {
  final finder = find.byValueKey(field);
  await FlutterDriverUtils.enterText(world.driver, finder, input);
}

@override
RegExp get pattern => RegExp(r"I fill {string} field with {string}");
}

class ClickLoginButton extends Then1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(String loginbtn) async {
    final loginfinder = find.byValueKey(loginbtn);
    await FlutterDriverUtils.tap(world.driver, loginfinder);
  }

  @override
  RegExp get pattern => RegExp(r"I tap the {string} button");
}

class ExpectToBeInPage extends Given1WithWorld<String, FlutterWorld> {
  ExpectToBeInPage() : super(StepDefinitionConfiguration()..timeout = Duration(seconds: 10));

  @override
  RegExp get pattern => RegExp(r"I expect to be in {string}");

  @override
  Future<void> executeStep(String name) async {
    //await FlutterDriverUtils.waitForFlutter(world.driver);
    bool isInPage = await FlutterDriverUtils.isPresent(world.driver, find.byValueKey(name));
    expectMatch(isInPage, true);
  }
}