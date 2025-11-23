import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:wordshool/config/themes/colors.dart';

class LegalMarkdownPage extends StatelessWidget {
  final String title;
  final String assetPath;

  const LegalMarkdownPage({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(assetPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load content.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            );
          }
          return SafeArea(
            child: Markdown(
              data: snapshot.data ?? '',
              styleSheet: MarkdownStyleSheet(
                h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: MyColors.white,
                    ),
                h2: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: MyColors.white,
                    ),
                h3: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: MyColors.white,
                    ),
                h4: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: MyColors.white,
                    ),
                h5: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: MyColors.white,
                    ),
                h6: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: MyColors.white,
                    ),
                p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MyColors.white,
                    ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              selectable: true,
            ),
          );
        },
      ),
    );
  }
}
