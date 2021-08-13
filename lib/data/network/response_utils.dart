import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shopit/model/http_exception.dart';

bool isResponseSuccess(http.Response response) =>
    response.statusCode >= 200 && response.statusCode <= 300;

void tryResponseBody({
  required http.Response response,
  required Function(Map<String, dynamic>) responseBodyAction,
  Function(Exception exception)? failureAction,
}) {
  if (!isResponseSuccess(response)) {
    print(response.statusCode);
    failureAction?.call(HttpExceptions(response));
    return;
  }

  if (response.body.toLowerCase() == 'null') {
    responseBodyAction({});
    return;
  }

  responseBodyAction(jsonDecode(response.body));
}