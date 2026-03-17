import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../settings/presentation/settings_home_screen.dart';
import '../providers/onboarding_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _pageIndex = 0;

  static const _steps = [
    _OnboardingStep(
      title: 'Plan your workflow',
      message:
          'Cognitive Task Planning System turns tasks, goals, and your real timetable into a work plan that you can actually execute.',
      icon: Icons.track_changes_rounded,
    ),
    _OnboardingStep(
      title: 'Start with your timetable',
      message:
          'Add your fixed busy hours first so the scheduler can find usable focus windows.',
      icon: Icons.calendar_view_week_rounded,
    ),
    _OnboardingStep(
      title: 'Add a first task or goal',
      message:
          'You can create tasks directly or use goals and AI planning to break larger work into milestones.',
      icon: Icons.checklist_rounded,
    ),
    _OnboardingStep(
      title: 'Generate and execute',
      message:
          'Generate a schedule, start focus sessions, and recover missed work when plans drift.',
      icon: Icons.auto_awesome_rounded,
    ),
    _OnboardingStep(
      title: 'Notifications and sync',
      message:
          'Reminders and personal sync are optional. You can configure them later from Settings.',
      icon: Icons.notifications_active_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingActionControllerProvider.notifier).markViewed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(onboardingActionControllerProvider);
    final lastPage = _pageIndex == _steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          TextButton(
            onPressed: actionState.isLoading ? null : _skip,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _steps.length,
                  onPageChanged: (value) {
                    setState(() {
                      _pageIndex = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(step.icon, size: 72),
                            const SizedBox(height: 24),
                            Text(
                              step.title,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              step.message,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            if (index == _steps.length - 1) ...[
                              const SizedBox(height: 24),
                              FilledButton.tonalIcon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const SettingsHomeScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.settings_outlined),
                                label: const Text('Review settings later'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (index) {
                  final selected = index == _pageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selected ? 28 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (_pageIndex > 0)
                    OutlinedButton(
                      onPressed: actionState.isLoading
                          ? null
                          : () => _controller.previousPage(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                            ),
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox.shrink(),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: actionState.isLoading
                        ? null
                        : lastPage
                        ? _finish
                        : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                          ),
                    icon: Icon(
                      lastPage
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                    ),
                    label: Text(lastPage ? 'Finish' : 'Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _finish() async {
    await ref.read(onboardingActionControllerProvider.notifier).complete();
  }

  Future<void> _skip() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Skip onboarding?'),
          content: const Text(
            'You can reopen onboarding later from Settings if you want a guided setup again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Stay'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Skip'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await ref.read(onboardingActionControllerProvider.notifier).skip();
    if (mounted) {
      await AppRouter.openSettings(context);
    }
  }
}

class _OnboardingStep {
  const _OnboardingStep({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;
}
