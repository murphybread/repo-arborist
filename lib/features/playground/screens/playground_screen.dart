import 'package:flutter/material.dart';
import 'package:template/features/playground/widgets/activity_timeline_card.dart';
import 'package:template/features/playground/widgets/stat_card.dart';

/// AI Playground 메인 화면
class PlaygroundScreen extends StatelessWidget {
  /// [PlaygroundScreen] 생성자
  const PlaygroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.5, -1),
            end: Alignment(0.5, 1),
            colors: [
              Color(0xFF0F172A),
              Color(0xFF0F172A),
              Color(0x800F172A),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // 헤더
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ai-playground',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.25,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 중앙 이미지
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 312,
                      child: Image.asset(
                        'assets/images/playground/tree_glow-56586a.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              // 통계 카드 섹션
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          StatCard(
                            label: 'Streak',
                            value: '12\ndays',
                          ),
                          SizedBox(width: 16),
                          StatCard(
                            label: 'Last 7d',
                            value: '25\ncommits',
                          ),
                          SizedBox(width: 16),
                          StatCard(
                            label: 'Growth',
                            value: '80%',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Activity Timeline
              const Padding(
                padding: EdgeInsets.all(16),
                child: ActivityTimelineCard(),
              ),

              // 하단 여백
              const SizedBox(height: 79.5),
            ],
          ),
        ),
      ),
    );
  }
}
