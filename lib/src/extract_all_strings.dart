// ignore_for_file: implementation_imports
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/src/dart/ast/ast.dart';

class StringCollection {
  final List<String> simpleStrings = [];
  final List<String> adjacentStrings = [];
  final List<String> interpolatedStrings = [];
}

StringCollection extractAllStrings(String content) {
  final parseResult = parseString(
    content: content,
    featureSet: FeatureSet.latestLanguageVersion(),
  );

  final visitor = _StringLiteralVisitor();
  parseResult.unit.visitChildren(visitor);

  return visitor.stringCollection;
}

class _StringLiteralVisitor extends RecursiveAstVisitor<void> {
  final StringCollection stringCollection = StringCollection();

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    stringCollection.simpleStrings.add(node.value);
  }

  @override
  void visitAdjacentStrings(AdjacentStrings node) {
    for (var string in node.strings) {
      if (string is SimpleStringLiteral) {
        stringCollection.adjacentStrings.add(string.value);
      }
    }
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    stringCollection.interpolatedStrings.add(node.toSource());
  }

  @override
  // ignore: override_on_non_overriding_member
  void visitStringLiteral(StringLiteral node) {
    // General visit method for string literals
    if (node is SimpleStringLiteral) {
      visitSimpleStringLiteral(node);
    } else if (node is AdjacentStrings) {
      visitAdjacentStrings(node);
    } else if (node is StringInterpolation) {
      visitStringInterpolation(node);
    }
  }
}
