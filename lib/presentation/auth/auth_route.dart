import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopit/data/provider/auth_provider.dart';

enum AuthMode {
  Signup,
  Login,
}

class AuthRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildBody(context, deviceSize),
        ],
      ),
    );
  }

  Widget _buildBackground() => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(215, 117, 255, .5),
              Color.fromRGBO(255, 188, 117, .9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, 1],
          ),
        ),
      );

  Widget _buildBody(BuildContext context, Size deviceSize) =>
      SingleChildScrollView(
        child: Container(
          height: deviceSize.height,
          width: deviceSize.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTitle(context),
              Flexible(
                flex: deviceSize.width > 600 ? 2 : 1,
                child: AuthWidget(),
              )
            ],
          ),
        ),
      );

  Widget _buildTitle(BuildContext context) => Flexible(
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 94,
          ),
          transform: Matrix4.rotationZ(-8 * pi / 180)..translate(-10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.deepPurpleAccent.shade700,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 8,
              )
            ],
          ),
          child: Text(
            'ShopIt',
            style: TextStyle(
              color: Theme.of(context).accentTextTheme.headline6!.color,
              fontSize: 50,
              fontWeight: FontWeight.w100,
            ),
          ),
        ),
      );
}

class AuthWidget extends StatefulWidget {
  @override
  _AuthWidgetState createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _showError(String message) {
    showDialog(
        context: context,
        builder: (builderContext) => AlertDialog(
              title: Text('An error occurred!'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(builderContext).pop(),
                  child: Text('Close'),
                ),
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();
    setState(() => _loading = true);
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    try {
      if (_authMode == AuthMode.Login)
        await authProvider.login(_authData['email']!, _authData['password']!);
      else
        await authProvider.signup(_authData['email']!, _authData['password']!);
    } catch (error) {
      _showError(error.toString());
    }

    setState(() => _loading = false);
  }

  void _switchAuthMode() {
    _authMode == AuthMode.Login
        ? _animationController.forward()
        : _animationController.reverse();

    setState(
      () => _authMode =
          _authMode == AuthMode.Login ? AuthMode.Signup : AuthMode.Login,
    );
  }

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8,
      child: AnimatedContainer(
        padding: const EdgeInsets.all(16),
        height: _authMode == AuthMode.Login ? 310 : 366,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
        width: deviceSize.width * .75,
        child: Center(child: _buildFormWidget(context)),
      ),
    );
  }

  Widget _buildFormWidget(BuildContext context) => Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@'))
                    return 'Invalid email';
                },
                onSaved: (value) {
                  _authData['email'] = value!;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty || value.length < 5)
                    return 'Invalid password';
                },
                onSaved: (value) {
                  _authData['password'] = value!;
                },
              ),
              AnimatedContainer(
                constraints: BoxConstraints(
                  minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                  maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                ),
                curve: Curves.easeIn,
                duration: Duration(milliseconds: 350),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: TextFormField(
                      enabled: _authMode == AuthMode.Signup,
                      decoration:
                          InputDecoration(labelText: 'Confirm password'),
                      obscureText: true,
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value != _passwordController.text)
                                return 'Passwords do not match';
                            }
                          : null,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        _authMode == AuthMode.Login ? 'Login' : 'Signup',
                      ),
                    ),
              TextButton(
                child: Text(_authMode == AuthMode.Login ? 'Signup' : 'Login'),
                onPressed: _switchAuthMode,
              ),
            ],
          ),
        ),
      );
}
