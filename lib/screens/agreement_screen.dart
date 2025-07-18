import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../common/constants.dart';
import '../common/privacy.dart';
import '../common/terms.dart';
import '../dto/auth/oauth_check_req.dart';
import '../service/auth_service.dart';

class AgreementScreen extends StatefulWidget {
  final OauthCheckReq oauthInfo;
  const AgreementScreen({super.key, required this.oauthInfo});

  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  bool agreeAll = false;
  bool agreeTerms = false;
  bool agreePrivacy = false;
  bool isExpandedTerms = false;
  bool isExpandedPrivacy = false;

  void _toggleAll(bool? value) {
    final newValue = value ?? false;
    setState(() {
      agreeAll = newValue;
      agreeTerms = newValue;
      agreePrivacy = newValue;
    });
  }

  void _toggleTerms(bool? value) {
    setState(() {
      agreeTerms = value ?? false;
      agreeAll = agreeTerms && agreePrivacy;
    });
  }

  void _togglePrivacy(bool? value) {
    setState(() {
      agreePrivacy = value ?? false;
      agreeAll = agreeTerms && agreePrivacy;
    });
  }

  void _saveAgreement() async {
    try {
      final authService = AuthService();

      await authService.registerUser(
        provider: widget.oauthInfo.provider,
        accessToken: widget.oauthInfo.accessToken,
      );

      context.go('/welcome');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 중 오류가 발생하였습니다.')),
      );
    }
  }

  Widget _buildAgreementTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String content,
    required bool isExpanded,
    required VoidCallback onExpand,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onExpand,
          child: Row(
            children: [
              Checkbox(value: value, onChanged: onChanged),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            ],
          ),
        ),
        if (isExpanded)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              content,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              '미래를 위한\n기록을 시작해보세요',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Checkbox(value: agreeAll, onChanged: _toggleAll),
                        const Text(
                          '모두 동의하기',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildAgreementTile(
                      title: '서비스 이용약관 (필수)',
                      value: agreeTerms,
                      onChanged: _toggleTerms,
                      content: termsOfService,
                      isExpanded: isExpandedTerms,
                      onExpand: () => setState(() => isExpandedTerms = !isExpandedTerms),
                    ),
                    _buildAgreementTile(
                      title: '개인정보 처리방침 (필수)',
                      value: agreePrivacy,
                      onChanged: _togglePrivacy,
                      content: privacyPolicy,
                      isExpanded: isExpandedPrivacy,
                      onExpand: () => setState(() => isExpandedPrivacy = !isExpandedPrivacy),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: agreeTerms && agreePrivacy
                  ? AppColors.primary
                  : Colors.grey.shade300,
            ),
            onPressed: agreeTerms && agreePrivacy ? _saveAgreement : null,
            child: const Text('시작하기'),
          ),
        ),
      ),
    );
  }
}