import 'dart:developer';

import 'package:brd_issue_tracker/shared/models/user_model.dart';
import 'package:brd_issue_tracker/static_data.dart';
import 'package:dio/dio.dart';

Future<Map<String, List<UserModel>>?> allUsersApi(String token) async {
  Map<String, List<UserModel>> _userMap = {};
  try {
    final res = await Dio().get(
      "$host/api/viewUser",
      options: Options(headers: {"Authorization": token}),
    );
    if (res.statusCode != 200) {
      throw Exception("Invalid Status Code");
    }
    _userMap.clear();
    List allUser = res.data["data"];
    if (allUser.isEmpty) {
      _userMap.clear();
      return {};
    }
    for (var element in allUser) {
      if (_userMap[element["department"]] == null) {
        _userMap[element["department"]] = [];
      }
      _userMap[element["department"]]!.add(UserModel.formJson(element));
    }

    return {..._userMap};
  } catch (e) {
    log(e.toString(), name: "All User Api Exception");
  }
  return null;
}
