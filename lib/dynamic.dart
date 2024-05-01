import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share/share.dart';

class News {
  final String title;
  final String description;

  News({required this.title, required this.description});
}

class ThemeController extends GetxController {
  var isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}

class MyApp1 extends StatefulWidget {
  @override
  _MyApp1State createState() => _MyApp1State();
}

class _MyApp1State extends State<MyApp1> {
  @override
  void initState() {
    super.initState();
    handleDynamicLinks();
  }

  Future<void> handleDynamicLinks() async {
    final PendingDynamicLinkData? data =
    await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(data);

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) {
      _handleDeepLink(dynamicLink);
    });
  }

  void _handleDeepLink(PendingDynamicLinkData? data) {
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      String? newsTitle = deepLink.pathSegments.last;
      if (newsTitle != null) {
        Get.toNamed('/news_detail', arguments: {'title': newsTitle});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: NewsListScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/news_detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => NewsDetailScreen(
              title: args['title'],
              newsList: (args['newsList'] != null)
                  ? List<News>.from(args['newsList'])
                  : null, description: '',
            ),
          );
        }
        return null;
      },
    );
  }
}

class NewsListScreen extends StatelessWidget {
  final List<News> newsList = [
    News(
      title: "Geopolitical Tensions Rise in Eastern Europe",
      description: "Understanding the Ukraine-Russia Conflict Dynamics",
    ),
    News(
      title: "Climate Change Takes Center Stage at COP26",
      description: "Negotiating Solutions for a Sustainable Future",
    ),
    News(
      title: "Tech Giants Face Regulatory Scrutiny",
      description: "Antitrust Investigations and Big Tech's Influence",
    ),
    News(
        title: "Social Media's Role in Misinformation",
        description: "Combatting the Spread of False Narratives Online"),
    News(
        title: "Global Economy Recovers Amid Supply Chain Disruptions",
        description: "Navigating Supply Chain Challenges in Post-Pandemic Era"),
    News(
        title: "Renewable Energy Surges as Fossil Fuels Decline",
        description: "Transitioning Towards a Greener Energy Landscape"),
    News(
        title: "Humanitarian Crisis Unfolds in Yemen",
        description: "Addressing the Urgent Needs of Yemeni Civilians"),
    News(
        title: "Space Exploration Enters New Frontier",
        description: "Discoveries and Milestones in Space Exploration"),
    News(
        title: "Cultural Reckoning in Film and Entertainment Industry",
        description: "Accountability and Representation in Hollywood"),
    News(
        title: "Racial Justice Movement Gains Momentum",
        description: "Pursuing Equality and Justice in Societal Systems"),
    News(
        title: "Education Systems Adapt to Remote Learning",
        description: "Innovations and Challenges in Online Education"),
    News(
        title: "Healthcare Innovations Revolutionize Treatment",
        description: "Breakthroughs in Medical Research and Technology"),
    News(
        title: "Corporate Responsibility in Environmental Conservation",
        description: "Sustainability Initiatives and Corporate Accountability"),
    News(
        title: "Ongoing Conflict in the Middle East",
        description: "Analyzing Dynamics in the Israeli-Palestinian Conflict"),
  ];

  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News List'),
        actions: [
          IconButton(
            onPressed: () {
              themeController.toggleTheme();
            },
            icon: Icon(Icons.shield_moon_outlined),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          News news = newsList[index];
          return ListTile(
            title: Text(news.title),
            subtitle: Text(news.description),
            onTap: () {
              Get.toNamed('/news_detail', arguments: {
                'title': news.title,
                'newsList': newsList,
              });
            },
            leading: IconButton(
              onPressed: () {
                _shareNews(context, news);
              },
              icon: Icon(Icons.share),
            ),
            trailing: IconButton(
              onPressed: () {
                _speakNews(news.title, news.description);
              },
              icon: Icon(Icons.settings_voice_outlined),
            ),
          );
        },
      ),
    );
  }

  void _shareNews(BuildContext context, News news) async {
    final dynamicLinkParams = DynamicLinkParameters(
      uriPrefix: 'https://dynamiclick.page.link',
      link: Uri.parse('https://dynamiclick.page.link/JTT6/${news.title}'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.dynamic_lick',
      ),
      navigationInfoParameters: NavigationInfoParameters(
        forcedRedirectEnabled: true,
      ),
    );

    final ShortDynamicLink dynamicUrl =
    await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);

    if (dynamicUrl != null) {
      Share.share(dynamicUrl.shortUrl.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate dynamic link.'),
        ),
      );
    }
  }

  void _speakNews(String title, String description) async {
    final FlutterTts flutterTts = FlutterTts();
    await flutterTts.speak("$title. $description");
  }
}

class NewsDetailScreen extends StatelessWidget {
  final String title;
  final String description;

  const NewsDetailScreen({Key? key, required this.title, required this.description, List<News>? newsList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              description,
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}

