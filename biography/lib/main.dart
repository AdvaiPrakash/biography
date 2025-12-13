import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'saved_posters_screen.dart';
import 'services/update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Check for updates after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
       // We need a context, but MyApp's context isn't useful for showing dialogs 
       // on top of the Navigator. 
       // Ideally, check in the home screen. Moving check to SignInScreen.
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biography',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00BF6D)),
        useMaterial3: true,
      ),
      home: SignInScreen(),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final UpdateService _updateService = UpdateService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateService.checkForUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SizedBox(height: constraints.maxHeight * 0.1),
                  Image.asset('assets/icon-black.png', height: 70),
                  SizedBox(height: constraints.maxHeight * 0.1),
                  Text(
                    "Sign In",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.05),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Username',
                            filled: true,
                            fillColor: Color(0xFFF5FCF9),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0 * 1.5,
                              vertical: 16.0,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                          ),
                          onSaved: (email) {
                            // Save it
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter username';
                            }
                            if (value != 'biouser') {
                              return 'Invalid username';
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Password',
                              filled: true,
                              fillColor: Color(0xFFF5FCF9),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0 * 1.5,
                                vertical: 16.0,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(50),
                                ),
                              ),
                            ),
                            onSaved: (password) {
                              // Save it
                            },
                             validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            if (value != 'bio123') {
                              return 'Invalid password';
                            }
                            return null;
                          },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SavedPostersScreen(),
                                ),
                              );
                            } else {
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Invalid credentials')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF00BF6D),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text("Sign in"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
