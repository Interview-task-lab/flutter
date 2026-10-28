import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'test_wrapper.dart';

/// Test kodu. Gerçek bir doğrulama servisi yok.
const otpTestCode = '123456';

/// Klavye zorlukları:
/// - Maskeli telefon alanı: "(5xx) xxx xx xx" formatı yazarken uygulanır
/// - 6 kutulu OTP: rakam girince sonraki kutuya, silince önceki kutuya geçer
/// - "Doğrula" butonu ekranın altında; klavye açıkken üstünü kapatır
///   (`resizeToAvoidBottomInset: false`), önce klavye kapatılmalı
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  String? _result;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
    if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
  }

  void _verify() {
    final code = _controllers.map((c) => c.text).join();
    setState(() => _result = code == otpTestCode ? 'Doğrulandı' : 'Hatalı kod');
  }

  @override
  Widget build(BuildContext context) {
    return TestWrapper(
      dataTestId: 'otp-scaffold',
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('Klavye & OTP')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TestWrapper(
                dataTestId: 'phone-input',
                child: TextField(
                  keyboardType: TextInputType.phone,
                  inputFormatters: [PhoneInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Telefon',
                    hintText: '(5xx) xxx xx xx',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Doğrulama kodu (test: $otpTestCode)'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 6; i++)
                    SizedBox(
                      width: 44,
                      child: TestWrapper(
                        dataTestId: 'otp-$i',
                        child: TextField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(counterText: '', border: OutlineInputBorder()),
                          onChanged: (v) => _onOtpChanged(i, v),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_result != null)
                TestWrapper(
                  dataTestId: 'otp-result',
                  child: Text(
                    _result!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: _result == 'Doğrulandı' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              const Spacer(),
              TestWrapper(
                dataTestId: 'otp-submit-button',
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: _verify,
                  child: const Text('Doğrula', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rakamları "(5xx) xxx xx xx" biçimine çevirir, en fazla 10 rakam.
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final d = digits.length > 10 ? digits.substring(0, 10) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i == 0) buffer.write('(');
      if (i == 3) buffer.write(') ');
      if (i == 6 || i == 8) buffer.write(' ');
      buffer.write(d[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
