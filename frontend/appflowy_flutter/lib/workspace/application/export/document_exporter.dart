import 'dart:convert';

import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/plugins/document/application/document_data_pb_extension.dart';
import 'package:appflowy/plugins/document/application/prelude.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/parsers/document_markdown_parsers.dart';
import 'package:appflowy_backend/protobuf/flowy-error/errors.pb.dart';
import 'package:appflowy_backend/protobuf/flowy-folder2/view.pb.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';

const List<NodeParser> _customParsers = [
  DividerNodeParser(),
  MathEquationNodeParser(),
  CodeBlockNodeParser(),
  CalloutNodeParser(),
  ToggleListNodeParser(),
  CustomImageNodeParser(),
];

enum DocumentExportType {
  json,
  markdown,
  text,
}

class DocumentExporter {
  const DocumentExporter(
    this.view,
  );

  final ViewPB view;

  Future<Either<FlowyError, String>> export(DocumentExportType type) async {
    final documentService = DocumentService();
    final result = await documentService.openDocument(view: view);
    return result.fold((error) => left(error), (r) {
      final document = r.toDocument();
      if (document == null) {
        return left(
          FlowyError(
            msg: LocaleKeys.settings_files_exportFileFail.tr(),
          ),
        );
      }
      switch (type) {
        case DocumentExportType.json:
          return right(jsonEncode(document));
        case DocumentExportType.markdown:
          final markdown = documentToMarkdown(
            document,
            customParsers: _customParsers,
          );
          return right(markdown);
        case DocumentExportType.text:
          throw UnimplementedError();
      }
    });
  }
}
