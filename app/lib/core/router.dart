import 'package:go_router/go_router.dart';

import '../features/auth/token_storage.dart';
import '../features/databases/presentation/database_screen.dart';
import '../features/pages/presentation/page_editor_screen.dart';
import '../features/pages/presentation/page_list_screen.dart';
import '../features/pages/presentation/setup_screen.dart';
import '../features/pages/presentation/trash_screen.dart';
import '../shared/widgets/shell_layout.dart';

final router = GoRouter(
  initialLocation: '/pages',
  redirect: (context, state) async {
    final storage = TokenStorage();
    final configured = await storage.isConfigured;
    if (!configured && state.matchedLocation != '/setup') return '/setup';
    return null;
  },
  routes: [
    GoRoute(
      path: '/setup',
      builder: (context, state) => const SetupScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => ShellLayout(child: child),
      routes: [
        GoRoute(
          path: '/pages',
          builder: (context, state) => const PageListScreen(),
          routes: [
            GoRoute(
              path: ':pageId',
              builder: (context, state) => PageEditorScreen(
                pageId: state.pathParameters['pageId']!,
              ),
            ),
            GoRoute(
              path: ':pageId/db',
              builder: (context, state) => DatabaseScreen(
                pageId: state.pathParameters['pageId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/trash',
          builder: (context, state) => const TrashScreen(),
        ),
      ],
    ),
  ],
);
