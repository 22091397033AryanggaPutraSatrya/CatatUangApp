import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pemasukan_screen.dart';
import 'screens/pengeluaran_screen.dart';
import 'screens/profile.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  //
  // ByteData data = await PlatformAssetBundle().load('assets/ca/catatuangryts.000webhostapp.com.crt');
  // SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Keuangan Harian',
      theme: ThemeData(
        primaryColor: Color(0xFF27374D), // Warna utama
        hintColor: Color(0xFF526D82), // Warna aksen
        scaffoldBackgroundColor: Color(0xFFDDE6ED), // Warna latar belakang scaffold
        cardColor: Color(0xFF9DB2BF), // Warna kartu

        // Mengatur tema untuk AppBar
        appBarTheme: AppBarTheme(
          color: Color(0xFF27374D),
          iconTheme: IconThemeData(color: Colors.white), toolbarTextStyle: TextTheme(
            titleLarge: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ).bodyMedium, titleTextStyle: TextTheme(
            titleLarge: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ).titleLarge,
        ),

        // Mengatur tema untuk tombol
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Color(0xFF526D82), // Warna teks tombol
          ),
        ),
// Mengatur tema untuk TextButton
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF526D82), // Warna teks tombol
          ),
        ),

        // Mengatur tema untuk teks
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF27374D)),
          bodyMedium: TextStyle(color: Color(0xFF27374D)),
        ),

        // Mengatur tema untuk input
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0xFF526D82)),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF526D82)),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF27374D)),
          ),
        ),

        cardTheme: CardTheme(
          color: Color(0xFF9DB2BF),
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),

        dialogTheme: DialogTheme(
          backgroundColor: Color(0xFF9DB2BF), // Warna latar belakang dialog
          titleTextStyle: TextStyle(
            color: Color(0xFF27374D),
            fontSize: 20,
          ),
          contentTextStyle: TextStyle(
            color: Color(0xFF27374D),
            fontSize: 16,
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/pemasukan': (context) => PemasukanScreen(),
        '/pengeluaran': (context) => PengeluaranScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
