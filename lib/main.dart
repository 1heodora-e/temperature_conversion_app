import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For haptic feedback

void main() {
  runApp(TemperatureConverterApp());
}

class TemperatureConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Conversion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.system,
      home: TemperatureConverterScreen(),
    );
  }
}

class TemperatureConverterScreen extends StatefulWidget {
  @override
  _TemperatureConverterScreenState createState() =>
      _TemperatureConverterScreenState();
}

enum ConversionType { fToC, cToF }

class _TemperatureConverterScreenState extends State<TemperatureConverterScreen> {
  final TextEditingController _controller = TextEditingController();
  ConversionType _conversion = ConversionType.fToC;
  String _result = '';
  List<String> _history = [];

  void _convert() {
    final inputText = _controller.text.trim();
    if (inputText.isEmpty) {
      _showError('Please enter a temperature value');
      return;
    }

    final double? inputTemp = double.tryParse(inputText);
    if (inputTemp == null) {
      _showError('Invalid number format');
      return;
    }

    double convertedTemp;
    String historyEntry;

    if (_conversion == ConversionType.fToC) {
      convertedTemp = (inputTemp - 32) * 5 / 9;
      historyEntry =
      'F to C: ${inputTemp.toStringAsFixed(1)} => ${convertedTemp.toStringAsFixed(2)}';
    } else {
      convertedTemp = inputTemp * 9 / 5 + 32;
      historyEntry =
      'C to F: ${inputTemp.toStringAsFixed(1)} => ${convertedTemp.toStringAsFixed(2)}';
    }

    // Haptic feedback when conversion happens
    HapticFeedback.lightImpact();

    setState(() {
      _result = convertedTemp.toStringAsFixed(2);
      _history.insert(0, historyEntry);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background applied here
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Temperature Converter',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),

                        Text(
                          'Select Conversion',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),

                        ToggleButtons(
                          isSelected: [
                            _conversion == ConversionType.fToC,
                            _conversion == ConversionType.cToF
                          ],
                          onPressed: (index) {
                            setState(() {
                              _conversion = (index == 0)
                                  ? ConversionType.fToC
                                  : ConversionType.cToF;
                              _result = '';
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          selectedColor: Colors.white,
                          fillColor: Colors.blue.shade700,
                          color: Colors.blue.shade700,
                          constraints:
                          BoxConstraints(minHeight: 40, minWidth: 140),
                          children: [
                            Text('Fahrenheit → Celsius'),
                            Text('Celsius → Fahrenheit'),
                          ],
                        ),

                        SizedBox(height: 24),

                        TextFormField(
                          controller: _controller,
                          keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Enter temperature',
                            hintText: _conversion == ConversionType.fToC
                                ? 'e.g. 55.0'
                                : 'e.g. 12.5',
                            prefixIcon: Icon(Icons.thermostat),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                        SizedBox(height: 24),

                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _convert,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              textStyle: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            child: Text('Convert'),
                          ),
                        ),

                        // Animated result display
                        SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: _result.isEmpty
                              ? SizedBox.shrink(key: ValueKey('empty'))
                              : Card(
                            key: ValueKey(_result),
                            color: Colors.blue.shade100,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Result: $_result',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 32),

                        Text(
                          'Conversion History',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),

                        SizedBox(height: 8),

                        Container(
                          constraints: BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _history.isEmpty
                              ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'No history yet',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                              : ListView.separated(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            itemCount: _history.length,
                            separatorBuilder: (_, __) => Divider(),
                            itemBuilder: (_, index) {
                              return Text(
                                _history[index],
                                style: TextStyle(fontSize: 16),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
