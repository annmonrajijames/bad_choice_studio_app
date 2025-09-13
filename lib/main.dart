import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bad Choice Studio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dialCodeController = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Initialize dial code from device locale on app start.
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    _dialCodeController.text = _dialCodeForCountry(locale.countryCode);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _dialCodeController.dispose();
    super.dispose();
  }

  String _dialCodeForCountry(String? countryCode) {
    final cc = (countryCode ?? '').toUpperCase();
    const dialMap = {
      'IN': '+91',
      'US': '+1',
      'GB': '+44',
      'AE': '+971',
      'AU': '+61',
      'CA': '+1',
      'DE': '+49',
      'FR': '+33',
      'ES': '+34',
      'IT': '+39',
      'JP': '+81',
      'SG': '+65',
      'CN': '+86',
      'BR': '+55',
      'ZA': '+27',
      'NL': '+31',
      'RU': '+7',
      'SA': '+966',
      'KR': '+82',
      'SE': '+46',
      'CH': '+41',
      'NO': '+47',
      'DK': '+45',
      'NZ': '+64',
      'PK': '+92',
      'BD': '+880',
      'LK': '+94',
      'NP': '+977',
      'PH': '+63',
      'MY': '+60',
      'TH': '+66',
      'ID': '+62',
      'VN': '+84',
      'TR': '+90',
      'IR': '+98',
      'IQ': '+964',
      'IL': '+972',
      'EG': '+20',
      'NG': '+234',
      'KE': '+254',
      'TZ': '+255',
      'UG': '+256',
      'MX': '+52',
      'AR': '+54',
      'CL': '+56',
      'CO': '+57',
      'PE': '+51',
      'VE': '+58',
      'PL': '+48',
      'CZ': '+420',
      'HU': '+36',
      'RO': '+40',
      'UA': '+380',
      'GR': '+30',
      'PT': '+351',
      'BE': '+32',
      'AT': '+43',
      'IE': '+353',
    };
    return dialMap[cc] ?? '+1';
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _busy = true);
    try {
      final account = await _googleSignIn.signIn();
      if (account != null && mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _signInWithPhone() {
    final dial = _dialCodeController.text.trim();
    final phone = _phoneController.text.trim();
    if (dial.isEmpty || !dial.startsWith('+')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid country code (e.g., +91)'),
        ),
      );
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }
    // Backend not connected yet; show error instead of navigating.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Phone authentication not available: backend not connected.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    // Placeholder for company logo (.jpg). Replace with Image.asset when ready.
                    Container(
                      height: 140,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.image, size: 48, color: Colors.black38),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to BAD CHOICE STUDIO',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Manage your marketing in one place",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: TextField(
                            controller: _dialCodeController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Code',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _busy ? null : _signInWithPhone,
                      icon: const Icon(Icons.login),
                      label: const Text('Continue with phone'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.black12)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('or'),
                        ),
                        Expanded(child: Divider(color: Colors.black12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _signInWithGoogle,
                      icon: const Icon(Icons.account_circle),
                      label: const Text('Continue with Google'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Divider(),
              SizedBox(height: 8),
              Text(
                'Need help?\nCall: +91 9567955255\nEmail: badchoicestudio@gmail.com',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              SizedBox(height: 8),
              Text(
                'App Version 1.0.0 | © Bad Choice Studio',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
              SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final Uri _phoneUri = Uri(scheme: 'tel', path: '+919567955255');
  static final Uri _emailUri = Uri(
    scheme: 'mailto',
    path: 'badchoicestudio@gmail.com',
  );

  Future<void> _launch(Uri uri, BuildContext context) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bad Choice Studio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('+91 95679 55255'),
                subtitle: const Text('Tap to call'),
                onTap: () => _launch(_phoneUri, context),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text('annmonjameschiramel@gmail.com'),
                subtitle: const Text('Tap to email'),
                onTap: () => _launch(_emailUri, context),
              ),
            ),
            const Spacer(),
            const Text(
              'Bad Choice Studio',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
