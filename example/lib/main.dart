import 'dart:async';

import 'package:carrotquest_sdk/carrotquest_sdk.dart';
import 'package:carrotquest_sdk/user_property/carrot_user_property.dart';
import 'package:carrotquest_sdk/user_property/ecommerce_user_property.dart';
import 'package:carrotquest_sdk/user_property/user_property.dart';
import 'package:carrotquest_sdk_example/get_hash_use_case.dart';
import 'package:carrotquest_sdk_example/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  bool isCarrotPush = Carrot.isCarrotQuestPush(message.data);
  if (isCarrotPush) {
    Carrot.sendFirebasePushNotification(message.data);
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _carrot = Carrot();

  /// Для работы с Carrot quest для Flutter вам понадобится App ID, API Key и User Auth Key (либо ранее сгенерированный хэш для авторизации).
  /// Вы можете найти эти данные на вкладке Настройки > Разработчикам
  final String _appId = "";
  final String _apiKey = "";
  final String _userAuthKey = "";

  /// AppGroup - общее хранилище данных для разных приложений одного разработчика.
  /// Он позволяет обменитьвася данными между приложением и Notification Service Extension.
  /// Создать его можно в https://developer.apple.com/account/resources/identifiers/list/applicationGroup
  final String _appGroup = "group.cq.flutterSdkExample";

  int unreadConversationsCount = 0;

  @override
  void initState() {
    super.initState();

    _initCarrotSdk()
        .onError((error, stackTrace) => debugPrint("$error"))
        .then((value) async {
      Carrot.getUnreadConversationsCountStream().listen((count) {
        unreadConversationsCount = count;
        setState(() {});
      });
    });
  }

  Future<void> _initCarrotSdk() {
    return Carrot.setup(_appId, _apiKey, appGroup: _appGroup)
        .then((value) async {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      await FirebaseMessaging.instance.setAutoInitEnabled(true);

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        await Carrot.sendFcmToken(token);

        FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
          bool isCarrotPush = Carrot.isCarrotQuestPush(message.data);
          if (isCarrotPush) {
            Carrot.sendFirebasePushNotification(message.data);
          }
        });
      }
    });
  }

  /// Auth user
  void _auth(BuildContext con) {
    TextEditingController controller = TextEditingController();
    showModalBottomSheet(
      context: con,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              right: 32,
              top: 24,
              left: 32,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    hintText: "Input your id (phone, email, etc.)",
                    border: OutlineInputBorder()),
                controller: controller,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  String id = controller.text;

                  if (id.isEmpty) {
                    return;
                  }

                  Carrot.auth(id, userAuthKey: _userAuthKey).then((carrotId) {
                    String message = carrotId ?? "id - null";
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(message),
                    ));
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text("OK"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Auth user by hash
  void _authHash(BuildContext con) {
    TextEditingController controller = TextEditingController();
    showModalBottomSheet(
      context: con,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              right: 32,
              top: 24,
              left: 32,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    hintText: "Input your id (phone, email, etc...)",
                    border: OutlineInputBorder()),
                controller: controller,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  String id = controller.text;

                  if (id.isEmpty) {
                    return;
                  }

                  getHash(id).then((hash) {
                    Carrot.auth(id, userHash: hash).then((carrotId) {
                      String message = carrotId ?? "id - null";
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(message),
                      ));
                      Navigator.pop(context);
                    });
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text("OK"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeSystemProperty(BuildContext con) {
    TextEditingController controller = TextEditingController();
    UserProperty? selectedProp;

    showModalBottomSheet(
      context: con,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        final List<DropdownMenuEntry<UserProperty>> entries =
            <DropdownMenuEntry<UserProperty>>[];

        for (var element in CarrotProperty.values) {
          entries.add(DropdownMenuEntry(
              value: CarrotUserProperty(property: element, value: ""),
              label: element.name));
        }

        return Padding(
          padding: EdgeInsets.only(
              right: 32,
              top: 24,
              left: 32,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownMenu(
                label: const Text("System user property"),
                onSelected: (value) {
                  selectedProp = value;
                },
                dropdownMenuEntries: entries,
              ),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    hintText: "Value", border: OutlineInputBorder()),
                controller: controller,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  if (selectedProp == null) {
                    return;
                  }
                  String valueProperty = controller.text;
                  if (valueProperty.isEmpty) {
                    return;
                  }

                  if (selectedProp is CarrotUserProperty) {
                    _carrot
                        .setUserProperty((selectedProp as CarrotUserProperty)
                            .copyWith(newValue: valueProperty))
                        .then((value) => Navigator.pop(con));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text("OK"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _unsubscribePushNotifications(BuildContext con) {
    showModalBottomSheet(
      context: con,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
                right: 32,
                top: 24,
                left: 32,
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  onPressed: () {
                    Carrot.pushNotificationsUnsubscribe()
                        .then((value) => Navigator.pop(con))
                        .onError((error, stackTrace) => Navigator.pop(con));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Text("Unsubscribe all push notifications"),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Carrot.pushCampaignsUnsubscribe()
                        .then((value) => Navigator.pop(con))
                        .onError((error, stackTrace) => Navigator.pop(con));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child:
                        const Text("Unsubscribe campaigns push notifications"),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _changeEcommerceProperty(BuildContext con) {
    TextEditingController controller = TextEditingController();
    UserProperty? selectedProp;

    showModalBottomSheet(
      context: con,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        final List<DropdownMenuEntry<UserProperty>> entries =
            <DropdownMenuEntry<UserProperty>>[];

        for (var element in EcommerceProperty.values) {
          entries.add(DropdownMenuEntry(
              value: EcommerceUserProperty(property: element, value: ""),
              label: element.name));
        }

        return Padding(
          padding: EdgeInsets.only(
              right: 32,
              top: 24,
              left: 32,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownMenu(
                label: const Text("Ecommerce user property"),
                onSelected: (value) {
                  selectedProp = value;
                },
                dropdownMenuEntries: entries,
              ),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    hintText: "Value", border: OutlineInputBorder()),
                controller: controller,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  if (selectedProp == null) {
                    return;
                  }
                  String valueProperty = controller.text;
                  if (valueProperty.isEmpty) {
                    return;
                  }

                  if (selectedProp is EcommerceUserProperty) {
                    _carrot
                        .setUserProperty((selectedProp as EcommerceUserProperty)
                            .copyWith(newValue: valueProperty))
                        .then((value) => Navigator.pop(con));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text("OK"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _changeCustomProperty(BuildContext con) {
    TextEditingController nameController = TextEditingController();
    TextEditingController valueController = TextEditingController();
    showModalBottomSheet(
      context: con,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              right: 32,
              top: 24,
              left: 32,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    hintText: "Name", border: OutlineInputBorder()),
                controller: nameController,
              ),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    hintText: "Value", border: OutlineInputBorder()),
                controller: valueController,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  String nameProperty = nameController.text;
                  String valueProperty = valueController.text;
                  if (nameProperty.isEmpty || valueProperty.isEmpty) {
                    return;
                  }

                  _carrot
                      .setUserProperty(UserProperty(
                          name: nameProperty, value: valueProperty))
                      .then((value) => Navigator.pop(con));
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text("OK"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: const Text('Carrot quest SDK example app'),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Carrot.openChat();
              },
              label: Text(unreadConversationsCount.toString()),
              icon: const Icon(Icons.chat),
            ),
            body: Builder(builder: (mContext) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextButton(
                    onPressed: () {
                      Carrot.trackEvent("Tap button",
                          params: {"Button": "Auth user"});
                      _auth(mContext);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Auth user"),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Carrot.trackEvent("Tap button",
                          params: {"Button": "Auth user by hash"});
                      _authHash(mContext);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Auth user by hash"),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Carrot.trackEvent("Tap button",
                          params: {"Button": "Change system properties"});
                      _changeSystemProperty(mContext);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Change system properties"),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Carrot.trackEvent("Tap button",
                          params: {"Button": "Change ecommerce properties"});
                      _changeEcommerceProperty(mContext);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Change ecommerce properties"),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Carrot.trackEvent("Tap button",
                          params: {"Button": "Change custom properties"});
                      _changeCustomProperty(mContext);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Change custom properties"),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Carrot.trackEvent("Tap 'show push' button");
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Show push"),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Carrot.trackEvent("Tap button",
                          params: {"Button": "Unsubscribe push notifications"});
                      _unsubscribePushNotifications(mContext);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Unsubscribe push notifications"),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Carrot.trackEvent("Tap button",
                          params: {"Button": "Log out"}).then((value) {
                        Carrot.logOut();
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Log out"),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              );
            })));
  }
}
