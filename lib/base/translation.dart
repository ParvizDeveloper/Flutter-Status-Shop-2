import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

String tr(BuildContext context, String key) {
  final p = Provider.of<LanguageProvider>(context, listen: false);
  return p.t(key);
}