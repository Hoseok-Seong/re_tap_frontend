import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../common/constants.dart';
import '../dto/user/fcm_token_req.dart';
import '../provider/auth_provider.dart';
import '../provider/user_provider.dart';
import '../service/auth_service.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  WelcomeScreen({super.key});

  final authService = AuthService();

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final TextEditingController _nicknameController = TextEditingController();

  bool get _isNicknameFilled => _nicknameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submitNickname() async {
    final nickname = _nicknameController.text.trim();

    try {
      await ref.read(updateNicknameProvider(nickname).future);
      await registerFcmToken(ref);

      ref.read(authStateProvider.notifier).state = AuthState.loggedIn;
      context.go('/home');
    } catch (e) {
      String errorMessage = '닉네임 저장에 실패했어요';

      if (e is DioException) {
        final code = e.response?.data['code'];
        if (code == 'U005') {
          errorMessage = '이미 사용 중인 닉네임이에요';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> registerFcmToken(WidgetRef ref) async {
    final token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      final req = FcmTokenReq(fcmToken: token);

      try {
        await ref.read(updateFcmTokenProvider(req).future);
        print('✅ FCM 토큰 서버에 전송 완료');
      } catch (e) {
        print('❌ FCM 토큰 전송 실패: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true, // 키보드 올라와도 UI 줄어들도록
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      const Icon(Icons.eco,
                          size: 80, color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(
                        '환영합니다!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '미래를 위한 기록을 시작해보세요',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _nicknameController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: '닉네임을 입력하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isNicknameFilled
                                ? AppColors.primary
                                : Colors.grey.shade300,
                          ),
                          onPressed: _isNicknameFilled ? _submitNickname : null,
                          child: const Text('시작하기'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}