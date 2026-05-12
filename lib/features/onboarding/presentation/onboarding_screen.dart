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
  String _selectedUseCase = 'Study';
  String _selectedStyle = 'Structured';
  String _selectedStarter = 'Balanced weekly system';

  static const _steps = [
    _OnboardingStep(
      title: 'Welcome to CogniPlan',
      message:
          'A local-first planning workspace for serious execution: goals, routines, schedules, focus, review, and knowledge in one place.',
      icon: Icons.track_changes_rounded,
    ),
    _OnboardingStep(
      title: 'Start from your real week',
      message:
          'Add your timetable first, then let tasks and routines fit around the week you actually live.',
      icon: Icons.calendar_view_week_rounded,
    ),
    _OnboardingStep(
      title: 'Keep plans reviewable',
      message:
          'Use routines, focus sessions, insights, and revision workflows without losing trust in your local data.',
      icon: Icons.fact_check_rounded,
    ),
    _OnboardingStep(
      title: 'Choose your starting shape',
      message:
          'Pick a use case, planning style, and starter direction. You can change all of this later.',
      icon: Icons.tune_rounded,
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
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Card(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(28),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(step.icon, size: 64),
                                      const SizedBox(height: 24),
                                      Text(
                                        step.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
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
                                        const SizedBox(height: 28),
                                        _ChoiceSection(
                                          title: 'Primary use case',
                                          options: const [
                                            'Study',
                                            'Research',
                                            'Fitness',
                                            'Work',
                                            'Personal planning',
                                          ],
                                          selected: _selectedUseCase,
                                          onSelected: (value) =>
                                              setState(() => _selectedUseCase = value),
                                        ),
                                        const SizedBox(height: 16),
                                        _ChoiceSection(
                                          title: 'Planning style',
                                          options: const [
                                            'Simple',
                                            'Structured',
                                            'Advanced',
                                          ],
                                          selected: _selectedStyle,
                                          onSelected: (value) =>
                                              setState(() => _selectedStyle = value),
                                        ),
                                        const SizedBox(height: 16),
                                        _ChoiceSection(
                                          title: 'Starter direction',
                                          options: const [
                                            'Balanced weekly system',
                                            'Routine-first setup',
                                            'Goal and planner focus',
                                          ],
                                          selected: _selectedStarter,
                                          onSelected: (value) =>
                                              setState(() => _selectedStarter = value),
                                        ),
                                        const SizedBox(height: 20),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          alignment: WrapAlignment.center,
                                          children: [
                                            FilledButton.tonalIcon(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute<void>(
                                                    builder: (_) =>
                                                        const SettingsHomeScreen(),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.settings_outlined),
                                              label: const Text('Review settings'),
                                            ),
                                            FilledButton.tonalIcon(
                                              onPressed: () {
                                                AppRouter.openPlanningAssistant(
                                                  context,
                                                  initialPrompt:
                                                      'Create a ${_selectedStyle.toLowerCase()} ${_selectedUseCase.toLowerCase()} planning system.',
                                                );
                                              },
                                              icon: const Icon(Icons.auto_awesome_rounded),
                                              label: const Text('Open assistant'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
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
                      lastPage ? Icons.check_rounded : Icons.arrow_forward_rounded,
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
            'You can reopen onboarding later from Settings if you want the guided setup again.',
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

class _ChoiceSection extends StatelessWidget {
  const _ChoiceSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map(
                (option) => ChoiceChip(
                  label: Text(option),
                  selected: selected == option,
                  onSelected: (_) => onSelected(option),
                ),
              )
              .toList(),
        ),
      ],
    );
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
