// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void redirectToOAuth(String url) {
  html.window.location.href = url;
}
