import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:toolbox/core/dialogs.dart';
import 'package:toolbox/gen/strings.g.dart';
import 'package:url_launcher/url_launcher.dart';

class MathTexPage extends StatefulWidget {
  const MathTexPage({super.key});

  @override
  State<MathTexPage> createState() => _MathTexPage();
}

class _MathTexPage extends State<MathTexPage> {
  final TextEditingController _textFieldController = TextEditingController();
  final String syntaxMathjaxTexHelpWebsiteUrl = "https://treeofmath.github.io/tex-commands-in-mathjax/TeXSyntax.htm#alphaList";

  bool _isLoading = true;

  String _mathTex = "";
  String? _mathTexSvgData;
  Color _selectedColor = Colors.black;

  final List<Color> colors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.deepOrange,
    Colors.orange,
    Colors.amber,
    Colors.yellow,
    Colors.lime,
    Colors.lightGreen,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.lightBlue,
    Colors.blue,
    Colors.indigo,
    Colors.deepPurple,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    if (TeXRenderingServer.port != null) {
      setState(() {
        _isLoading = false;
      });
    } else {
      TeXRenderingServer.start().then((value) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _selectedColor = Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black;
      }
    });
  }

  Future<void> exportToImage() async {
    if (_mathTexSvgData == null) {
      showOkTextDialog(context, t.generic.error, t.tools.mathtex.error.please_wait_until_the_preview_is_loaded);
      return;
    }
    Uint8List? svgFileBytes = Uint8List.fromList(_mathTexSvgData?.codeUnits ?? []);
    String fileName = _textFieldController.text.isEmpty ? "mathtex" : _textFieldController.text;
    fileName = "${fileName.replaceAll(RegExp(r"[^a-zA-Z0-9]"), "_")}.svg";
    final params = SaveFileDialogParams(data: svgFileBytes, fileName: fileName, mimeTypesFilter: ["image/svg+xml"]);
    await FlutterFileDialog.saveFile(params: params);
  }

  Future<void> openSyntaxHelpWebsite() async {
    if (await canLaunchUrl(Uri.parse(syntaxMathjaxTexHelpWebsiteUrl))) {
      await launchUrl(Uri.parse(syntaxMathjaxTexHelpWebsiteUrl), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        showOkTextDialog(context, t.generic.error, t.tools.mathtex.error.could_not_open_help_website);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.tools.mathtex.title),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                showCustomButtonsTextDialog(
                  context,
                  t.tools.mathtex.get_help,
                  t.tools.mathtex.help_content,
                  [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        openSyntaxHelpWebsite();
                      },
                      child: Text(t.tools.mathtex.open_help_website),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(t.generic.ok),
                    ),
                  ],
                );
              },
              icon: Icon(Icons.help_outline),
              tooltip: t.tools.mathtex.get_help,
            ),
          ],
        ),
        body: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Input Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.functions_outlined,
                                      color: colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    t.tools.mathtex.texExpression,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _textFieldController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: t.tools.mathtex.enter_a_mathematical_expression_in_tex_format,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _mathTex = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_mathTex.trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        // Preview Card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.preview_outlined, color: colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      t.tools.mathtex.preview,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  height: 90,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Math2SVG(
                                        math: _mathTex,
                                        teXInputType: MathInputType.teX,
                                        formulaWidgetBuilder: (context, svg) {
                                          _mathTexSvgData = svg;
                                          return SvgPicture.string(
                                            _mathTexSvgData ?? "",
                                            colorFilter: ColorFilter.mode(_selectedColor, BlendMode.srcIn),
                                            height: 50,
                                            alignment: Alignment.center,
                                          );
                                        },
                                        errorWidgetBuilder: (context, error) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                                            decoration: BoxDecoration(
                                              color: colorScheme.errorContainer,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: [
                                                Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
                                                const SizedBox(height: 4),
                                                Text(
                                                  t.tools.mathtex.error.an_error_occurred_while_rendering_the_mathtex,
                                                  style: TextStyle(
                                                    color: colorScheme.onErrorContainer,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Color Picker Card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.palette_outlined, color: colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      t.tools.mathtex.color,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        for (Color color in colors)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              onTap: () {
                                                setState(() {
                                                  _selectedColor = color;
                                                });
                                              },
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: _selectedColor ==
                                                            color
                                                        ? colorScheme.primary
                                                        : Colors.transparent,
                                                    width: 3,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Export Button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.download),
                            label: Text(t.tools.mathtex.export_to_image),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              exportToImage();
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
