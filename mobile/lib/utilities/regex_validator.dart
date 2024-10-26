import 'dart:core';

bool validateRegEx(String regEx) {
  try {
    RegExp(regEx);
    return true;
  } catch (e) {
    return false;
  }
}
