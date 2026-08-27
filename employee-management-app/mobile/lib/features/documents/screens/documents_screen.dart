import 'package:flutter/material.dart';
import '../../common/module_screen.dart';
import '../providers/document_provider.dart';
class DocumentsScreen extends StatelessWidget { const DocumentsScreen({super.key}); @override Widget build(BuildContext context) => const ModuleScreen<DocumentProvider>(title: 'Document Management'); }
