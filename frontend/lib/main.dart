import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/transport/transport_request_screen.dart';
import 'screens/children/enroll_child_screen.dart';
import 'screens/children/children_list_screen.dart';
import 'screens/resources/bed_screen.dart';
import 'screens/staff/staff_list_screen.dart';
import 'screens/orphanages/orphanage_list_screen.dart';
import 'screens/profile/user_profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Orphan Enrollment System',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => MainNavigationScreen(),
          '/transport': (context) => TransportRequestScreen(),
          '/enroll': (context) => EnrollChildScreen(),
          '/children': (context) => ChildrenListScreen(),
          '/beds': (context) => BedScreen(),
          '/staff': (context) => StaffListScreen(),
          '/orphanages': (context) => OrphanageListScreen(),
          '/profile': (context) => UserProfileScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}