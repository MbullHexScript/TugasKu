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
    // Fresh Scholar (see DESIGN.md)
    const primary = Color(0xFF004445); // Deep Teal
    const secondary = Color(0xFF006C4B); // Vibrant Emerald
    const bgColor = Color(0xFFF9F9FF);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceLow = Color(0xFFF0F3FF);
    const surface = bgColor;
    const surfaceHigh = Color(0xFFDEE8FF);
    const surfaceHighest = Color(0xFFD8E3FB);
    const onSurface = Color(0xFF111C2D);
    const onSurfaceVariant = Color(0xFF3F4948);
    const outline = Color(0xFF6F7979);
    const outlineVariant = Color(0xFFBEC8C8);
    const primaryContainer = Color(0xFF0D5D5E);
    const onPrimaryContainer = Color(0xFF90D3D4);
    const inverseSurface = Color(0xFF263143);
    const onInverseSurface = Color(0xFFECF1FF);
    const inversePrimary = Color(0xFF8FD2D3);

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
        surface: surface,
        onSurface: onSurface,
        outline: outline,
        outlineVariant: outlineVariant,
        surfaceContainerLowest: surfaceLowest,
        surfaceContainerLow: surfaceLow,
        surfaceContainer: Color(0xFFE7EEFF),
        surfaceContainerHigh: surfaceHigh,
        surfaceContainerHighest: surfaceHighest,
        surfaceDim: Color(0xFFCFDAF2),
        surfaceBright: surfaceLowest,
        inverseSurface: inverseSurface,
        onInverseSurface: onInverseSurface,
        inversePrimary: inversePrimary,
        shadow: Colors.black,
        scrim: Colors.black,
        onSurfaceVariant: onSurfaceVariant,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondaryContainer: Color(0xFF64F9BC),
        onSecondaryContainer: Color(0xFF00714E),
        tertiaryContainer: Color(0xFF4A5654),
        onTertiaryContainer: Color(0xFFBECBC8),
        tertiary: Color(0xFF333F3D),
        onTertiary: Colors.white,
        errorContainer: Color(0xFFFFE4E6),
        onErrorContainer: Color(0xFF7F1D1D),
      ),
      scaffoldBackgroundColor: bgColor,
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
        iconTheme: IconThemeData(color: primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: secondary, width: 1.6),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceLowest,
        elevation: 0,
        indicatorColor: primary.withOpacity(0.10),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
      ),
      dividerTheme: DividerThemeData(color: outlineVariant.withOpacity(0.6)),
    );
  }

  ThemeData _buildDarkTheme() {
    const primary = Color(0xFF8FD2D3);
    const secondary = Color(0xFF64F9BC);
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
        onSurface: Color(0xFFECF1FF),
        outline: Color(0xFF3D4A4A),
        surfaceContainerHighest: cardDark,
        inverseSurface: Color(0xFFEDE9FE),
        onInverseSurface: Color(0xFF1E1040),
        inversePrimary: Color(0xFF004445),
        shadow: Colors.black,
        scrim: Colors.black,
        onSurfaceVariant: Color(0xFF9FB1B1),
        outlineVariant: Color(0xFF2B3434),
        primaryContainer: Color(0xFF0D5D5E),
        onPrimaryContainer: Color(0xFFAAEFEF),
        secondaryContainer: Color(0xFF005137),
        onSecondaryContainer: Color(0xFF68FCBF),
        tertiaryContainer: Color(0xFF2A3432),
        onTertiaryContainer: Color(0xFFD8E5E2),
        tertiary: Color(0xFFBECBC8),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Color(0xFFECF1FF),
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
        iconTheme: const IconThemeData(color: primary),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2B3434)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2B3434)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: secondary, width: 1.6),
        ),
        labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF150F20),
        elevation: 0,
        indicatorColor: primary.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2B3434)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Color(0xFF0F0D13),
        shape: StadiumBorder(),
      ),
    );
  }
}
