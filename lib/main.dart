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

  // Hive wajib selesai dulu sebelum runApp
  // HiveService.init sudah register semua adapter termasuk NotificationLogAdapter
  await HiveService.init();

  // Notifikasi NON-BLOCKING
  final notificationService = NotificationService();
  notificationService.init();

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
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }

  ThemeData _buildLightTheme() {
    const primary = Color(0xFF004445);
    const secondary = Color(0xFF006C4B);
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999)),
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
      dividerTheme:
          DividerThemeData(color: outlineVariant.withOpacity(0.6)),
    );
  }

  ThemeData _buildDarkTheme() {
    const primary = Color(0xFF004445);
    const secondary = Color(0xFF006C4B);
    const bgColor = Color(0xFFF9F9FF);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceLow = Color(0xFFF0F3FF);
    const surfaceHigh = Color(0xFFDEE8FF);
    const surfaceHighest = Color(0xFFD8E3FB);
    const onSurface = Color(0xFF111C2D);
    const onSurfaceVariant = Color(0xFF3F4948);
    const outline = Color(0xFF6F7979);
    const outlineVariant = Color(0xFFBEC8C8);

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
        surface: bgColor,
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
        inverseSurface: Color(0xFF263143),
        onInverseSurface: Color(0xFFECF1FF),
        inversePrimary: Color(0xFF8FD2D3),
        shadow: Colors.black,
        scrim: Colors.black,
        onSurfaceVariant: onSurfaceVariant,
        primaryContainer: Color(0xFF0D5D5E),
        onPrimaryContainer: Color(0xFF90D3D4),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
        labelStyle: const TextStyle(color: Color(0xFF3F4948)),
        hintStyle: const TextStyle(color: Color(0xFF6F7979)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLowest,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceLowest,
        elevation: 0,
        indicatorColor: primary.withOpacity(0.10),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme:
          DividerThemeData(color: outlineVariant.withOpacity(0.6)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
      ),
    );
  }
}
