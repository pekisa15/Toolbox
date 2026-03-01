import 'package:flutter/material.dart';
import 'package:toolbox/gen/strings.g.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class RandomColorPage extends StatefulWidget {
  const RandomColorPage({super.key});
  @override
  State<RandomColorPage> createState() => _RandomColorPage();
}

class _RandomColorPage extends State<RandomColorPage> {
  Color _color = const Color(0xFFFFFFFF);

  @override
  void initState() {
    changeColor();
    super.initState();
  }

  void changeColor() {
    setState(() {
      _color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
          .withOpacity(1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(t.tools.randomcolor.title),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 0.0),
                  child: Text(
                    t.tools.randomcolor.hint,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: GestureDetector(
                      onTap: () {
                        changeColor();
                      },
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Container(
                          color: _color,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.color_lens_outlined, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              t.tools.randomcolor.tap_to_copy,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600,),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: "#${_color.toARGB32().toRadixString(16).toUpperCase().substring(2)}"));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.tools.randomcolor.copied_to_clipboard)),
                            );
                          },
                          child: Text(
                            "#${_color.toARGB32().toRadixString(16).toUpperCase().substring(2)}",
                            style: const TextStyle(fontSize: 24, fontFamily: "Roboto", fontWeight: FontWeight.bold)
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: "rgb(${(_color.r * 255).toInt()}, ${(_color.g * 255).toInt()}, ${(_color.b * 255).toInt()})"));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.tools.randomcolor.copied_to_clipboard)),
                            );
                          },
                          child: Text(
                            "R: ${(_color.r * 255).toInt()}\nG: ${(_color.g * 255).toInt()}\nB: ${(_color.b * 255).toInt()}",
                            style: const TextStyle(fontSize: 24, fontFamily: "Roboto", fontWeight: FontWeight.bold)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
