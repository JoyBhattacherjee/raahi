import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phone = TextEditingController();
  int _step = 0; // 0 = phone, 1 = otp
  bool _verifying = false;
  int _resendIn = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _phone.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    super.dispose();
  }

  void _sendCode() {
    FocusScope.of(context).unfocus();
    setState(() {
      _step = 1;
      _resendIn = 30;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_resendIn <= 1) {
        t.cancel();
        setState(() => _resendIn = 0);
      } else {
        setState(() => _resendIn--);
      }
    });
  }

  Future<void> _verify(String code) async {
    FocusScope.of(context).unfocus();
    setState(() => _verifying = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    AppScope.read(context).signIn(_phone.text);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.indigo,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              height: keyboardOpen ? 130 : 310,
              width: double.infinity,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const RaahiLogo(size: 56, onDark: true),
                      const SizedBox(height: 18),
                      const Text(
                        'Where to next?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      if (!keyboardOpen) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to book rides, track drivers and pay your way.',
                          style: TextStyle(
                            color: Colors.white.o(0.85),
                            fontSize: 15,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.theme.scaffoldBackgroundColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(36)),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    28,
                    32,
                    28,
                    24 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _step == 0 ? _phoneStep(context) : _otpStep(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _phoneStep(BuildContext context) {
    final valid = _phone.text.length == 10;
    return Column(
      key: const ValueKey('phone'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your mobile number',
          style: context.tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          "We'll text you a 4-digit code to verify it's you.",
          style: TextStyle(color: context.muted, fontSize: 14),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: context.soft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Text('🇮🇳', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text('+91',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
                decoration: const InputDecoration(
                  hintText: '98765 43210',
                  counterText: '',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Continue',
          icon: Icons.arrow_forward_rounded,
          onPressed: valid ? _sendCode : null,
        ),
        const SizedBox(height: 14),
        Center(
          child: TextButton(
            onPressed: () => AppScope.read(context).signIn(''),
            child: Text(
              'Skip & explore the demo',
              style: TextStyle(
                color: context.cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'By continuing you agree to our Terms of Service and Privacy Policy.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.muted, fontSize: 12, height: 1.5),
        ),
      ],
    );
  }

  Widget _otpStep(BuildContext context) {
    final resendLabel = _resendIn > 0
        ? 'Resend code in 0:${_resendIn.toString().padLeft(2, '0')}'
        : 'Resend code';
    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            _step = 0;
            _verifying = false;
          }),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_rounded, size: 20, color: context.muted),
              const SizedBox(width: 6),
              Text(
                'Change number',
                style: TextStyle(
                  color: context.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Verify your number',
          style: context.tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter the 4-digit code sent to +91 ${_phone.text}',
          style: TextStyle(color: context.muted, fontSize: 14),
        ),
        const SizedBox(height: 24),
        PinInput(length: 4, onCompleted: _verify),
        const SizedBox(height: 22),
        if (_verifying)
          const Center(child: CircularProgressIndicator(strokeWidth: 3))
        else ...[
          Center(
            child: Text(
              resendLabel,
              style: TextStyle(
                color: _resendIn > 0 ? context.muted : context.cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.amber.o(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.amber),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo mode: any 4-digit code will work.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Four-box PIN entry backed by a single hidden text field.
class PinInput extends StatefulWidget {
  const PinInput({super.key, required this.length, required this.onCompleted});

  final int length;
  final ValueChanged<String> onCompleted;

  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChange);
    _focus.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  void _onChange() {
    setState(() {});
    if (_controller.text.length == widget.length) {
      widget.onCompleted(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focus.requestFocus(),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.length, (i) {
              final filled = i < text.length;
              final active = i == text.length && _focus.hasFocus;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 68,
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.soft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: active
                        ? AppColors.indigo
                        : filled
                            ? AppColors.indigo.o(0.4)
                            : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  filled ? text[i] : '',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                maxLength: widget.length,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(counterText: ''),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
