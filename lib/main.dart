import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/mata_kuliah_provider.dart';
import 'providers/focus_provider.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  await HiveService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MataKuliahProvider()),
        ChangeNotifierProvider(
            create: (_) => TaskProvider(notificationService)),
        ChangeNotifierProvider(create: (_) => FocusProvider()),
      ],
      child: const TugasKuApp(),
    ),
  );
}

class TugasKuApp extends StatelessWidget {
  const TugasKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TugasKu',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }

  ThemeData _buildLightTheme() {
    const primary = Color(0xFF7C3AED);
    const secondary = Color(0xFF0EA5E9);
    const bgColor = Color(0xFFF4F3FF);

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        error: Color(0xFFDC2626),
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF1E1040),
        outline: Color(0xFFE2E8F0),
        surfaceContainerHighest: bgColor,
        inverseSurface: Color(0xFF1E1040),
        onInverseSurface: Colors.white,
        inversePrimary: Color(0xFFEDE9FE),
        shadow: Colors.black,
        scrim: Colors.black,
        onSurfaceVariant: Color(0xFF4A4060),
        outlineVariant: Color(0xFFD1C4E9),
        primaryContainer: Color(0xFFEDE9FE),
        onPrimaryContainer: Color(0xFF1E1040),
        secondaryContainer: Color(0xFFE0F2FE),
        onSecondaryContainer: Color(0xFF0C3547),
        tertiaryContainer: Color(0xFFF3E8FF),
        onTertiaryContainer: Color(0xFF2D1057),
        tertiary: Color(0xFF9333EA),
        onTertiary: Colors.white,
        errorContainer: Color(0xFFFFE4E6),
        onErrorContainer: Color(0xFF7F1D1D),
        surfaceContainerLow: Color(0xFFF8F7FF),
        surfaceContainer: bgColor,
        surfaceDim: Color(0xFFE8E5F5),
        surfaceBright: Colors.white,
      ),
      scaffoldBackgroundColor: bgColor,
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF1E1040),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: Color(0xFF7C3AED)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: primary.withOpacity(0.1),
        indicatorColor: primary.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const primary = Color(0xFFA78BFA);
    const secondary = Color(0xFF38BDF8);
    const bgDark = Color(0xFF0F0D13);
    const surfaceDark = Color(0xFF1C1826);
    const cardDark = Color(0xFF231F32);

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: bgDark,
        secondary: secondary,
        onSecondary: bgDark,
        error: Color(0xFFDC2626),
        onError: Colors.white,
        surface: surfaceDark,
        onSurface: Color(0xFFDDD6FE),
        outline: Color(0xFF3D3550),
        surfaceContainerHighest: cardDark,
        inverseSurface: Color(0xFFEDE9FE),
        onInverseSurface: Color(0xFF1E1040),
        inversePrimary: Color(0xFF7C3AED),
        shadow: Colors.black,
        scrim: Colors.black,
        onSurfaceVariant: Color(0xFF9CA3AF),
        outlineVariant: Color(0xFF3D3550),
        primaryContainer: Color(0xFF3D1A78),
        onPrimaryContainer: Color(0xFFEDE9FE),
        secondaryContainer: Color(0xFF0C3547),
        onSecondaryContainer: Color(0xFFE0F2FE),
        tertiaryContainer: Color(0xFF2D1057),
        onTertiaryContainer: Color(0xFFF3E8FF),
        tertiary: Color(0xFFC084FC),
        onTertiary: bgDark,
        errorContainer: Color(0xFF7F1D1D),
        onErrorContainer: Color(0xFFFFE4E6),
        surfaceContainerLow: Color(0xFF150F20),
        surfaceContainer: surfaceDark,
        surfaceDim: bgDark,
        surfaceBright: cardDark,
      ),
      scaffoldBackgroundColor: bgDark,
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Color(0xFFEDE9FE),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: Color(0xFFA78BFA)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3D3550)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3D3550)),
        ),
        labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF150F20),
        elevation: 0,
        indicatorColor: primary.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2D2640)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFA78BFA),
        foregroundColor: Color(0xFF0F0D13),
        shape: StadiumBorder(),
      ),
    );
  }
}
