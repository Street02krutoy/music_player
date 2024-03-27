import 'package:adwaita/adwaita.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libadwaita_window_manager/libadwaita_window_manager.dart';

void main() {
  runApp(MyApp());
  doWhenWindowReady(() {
    final win = appWindow!;
    const initialSize = Size(1000, 600);
    const size = Size(1000, 600);

    win
      ..title = 'Suoer app'
      ..size = size
      ..alignment = Alignment.center
      ..minSize = initialSize
      ..show();
  });
}

class MyApp extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode themeMode, __) => ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: MaterialApp(
            title: 'Super app',
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AdwaitaThemeData.light(),
            darkTheme: AdwaitaThemeData.dark(),
            debugShowCheckedModeBanner: false,
            home: MyHomePage(themeNotifier: themeNotifier),
            themeMode: themeMode,
          )),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.themeNotifier});

  final ValueNotifier<ThemeMode> themeNotifier;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyHomePageState? state =
        context.findAncestorStateOfType<_MyHomePageState>();

    var prefs = await SharedPreferences.getInstance();
    prefs.setString('languageCode', newLocale.languageCode);
    prefs.setString('countryCode', "");

    state?.setState(() {});
  }
}

class _MyHomePageState extends State<MyHomePage> {
  NotificationsClient client = NotificationsClient();

  @override
  void initState() {
    super.initState();
    MyHomePage.setLocale(context, Locale.fromSubtags(languageCode: "ru"));
  }

  int page = 0;

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    // client.notify(loc.title,
    //     body: loc.notification_downloaded("A virus without games"),
    //     appName: loc.title,
    //     expireTimeoutMs: 0);
    return AdwScaffold(
      start: [
        AdwHeaderButton(
          onPressed: () => widget.themeNotifier.value == ThemeMode.light
              ? widget.themeNotifier.value = ThemeMode.dark
              : widget.themeNotifier.value = ThemeMode.light,
          icon: Icon(
              widget.themeNotifier.value == ThemeMode.light
                  ? LucideIcons.sun
                  : LucideIcons.moon,
              size: 15),
        ),
      ],
      title: Text(loc.localeName),
      flap: (isDrawer) => AdwSidebar(
        currentIndex: page,
        isDrawer: isDrawer,
        children: const [
          AdwSidebarItem(
            label: 'Welcome',
          ),
          AdwSidebarItem(
            label: 'Counter',
          ),
          AdwSidebarItem(
            label: 'Lists',
          ),
          AdwSidebarItem(
            label: 'Avatar',
          ),
          AdwSidebarItem(
            label: 'Flap',
          ),
          AdwSidebarItem(
            label: 'View Switcher',
          ),
          AdwSidebarItem(
            label: 'Settings',
          ),
          AdwSidebarItem(
            label: 'Style Classes',
          )
        ],
        onSelected: (index) => setState(() => page = index),
      ),
      body: AdwViewStack(
        animationDuration: const Duration(milliseconds: 100),
        index: page,
        children: [
          Text("0"),
          Text("1"),
          Text("2"),
          Text("3"),
          Text("4"),
          Text("5"),
          Text("6"),
          Text("7"),
          Text("8"),
        ],
      ),
      actions: AdwActions().windowManager,
    );
  }
}
