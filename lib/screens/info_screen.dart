// the goal of this file is to create a screen that displays information about the selected book/comic

import 'package:flutter/material.dart';
import 'package:drop_cap_text/drop_cap_text.dart';
import 'package:flutter_star/flutter_star.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:like_button/like_button.dart';
// import 'package:jellybook/providers/downloader.dart';
import 'package:jellybook/screens/downloader_screen.dart';
import 'package:jellybook/screens/reading_screen.dart';

class InfoScreen extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String url;
  final String description;
  final List<dynamic> tags;
  final String year;
  final double stars;
  final String comicId;

  InfoScreen(
      {required this.title,
      required this.imageUrl,
      required this.description,
      required this.tags,
      required this.url,
      required this.comicId,
      required this.stars,
      required this.year});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // create the part that contains the image and the title, year, star, and action buttons
            Row(
              children: [
                const SizedBox(
                  width: 5,
                ),
                // create the image
                Expanded(
                  flex: 2,
                  child: Padding(
                    // padding: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(2, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          imageUrl,
                          width: MediaQuery.of(context).size.width / 4 * 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
                // create the title, year, star, and action buttons
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // create the title
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // create the year, star, and action buttons
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (stars >= 0)
                            Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: CustomRating(
                                    max: 5,
                                    score: stars / 2,
                                    star: Star(
                                      fillColor: Color.lerp(Colors.red,
                                          Colors.yellow, stars / 10)!,
                                      emptyColor: Colors.grey.withOpacity(0.5),
                                    ),
                                    onRating: (double score) {},
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                  child: Text(
                                    "${(stars / 2).toStringAsFixed(2)} / 5.00",
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReadingScreen(
                                    title: title,
                                    comicId: comicId,
                                  ),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("This feature is not available yet",
                                          style: TextStyle(
                                            color: Colors.white,
                                          )),
                                  backgroundColor: Colors.black,
                                ),
                              );
                            },
                            child: const Icon(Icons.play_arrow),
                          ),
                          // icon button for download (dont use ElevatedButton)
                          IconButton(
                            onPressed: () {
                              // use slide animation to go to the download screen
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration:
                                      const Duration(milliseconds: 500),
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      DownloadScreen(
                                    title: title,
                                    comicId: comicId,
                                  ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    var begin = const Offset(1.0, 0.0);
                                    var end = Offset.zero;
                                    var curve = Curves.ease;

                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));

                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.download),
                          ),
                          LikeButton(
                            circleColor: const CircleColor(
                                start: Colors.red, end: Colors.red),
                            bubblesColor: const BubblesColor(
                              dotPrimaryColor: Colors.green,
                              dotSecondaryColor: Colors.red,
                            ),
                            likeBuilder: (bool isLiked) {
                              return Icon(
                                Icons.favorite,
                                color: isLiked ? Colors.red : Colors.white,
                              );
                            },
                            onTap: (bool isLiked) async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("This feature is not available yet",
                                          style: TextStyle(
                                            color: Colors.white,
                                          )),
                                  backgroundColor: Colors.black,
                                ),
                              );
                              return !isLiked;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: RichText(
                text: TextSpan(
                  text: "\t\t\t" + fixRichText(description),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(5),
                    child: Chip(
                      label: Text(tags[index]),
                    ),
                  );
                },
              ),
            ),
            if (year != "null")
              Container(
                padding: const EdgeInsets.all(5),
                child: Text(
                  year,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String fixRichText(String text) {
    return text
        .replaceAll("<br>", "\n\t\t\t")
        .replaceAll("<i>", "")
        .replaceAll("</i>", "")
        .replaceAll("<b>", "")
        .replaceAll("</b>", "")
        .replaceAll("<p>", "")
        .replaceAll("</p>", "")
        .replaceAll("<u>", "")
        .replaceAll("</u>", "")
        .replaceAll("<strong>", "")
        .replaceAll("</strong>", "")
        .replaceAll("<em>", "")
        .replaceAll("</em>", "")
        .replaceAll("<a>", "")
        .replaceAll("</a>", "")
        .replaceAll("<ul>", "")
        .replaceAll("</ul>", "")
        .replaceAll("<li>", "")
        .replaceAll("</li>", "")
        .replaceAll("<ol>", "")
        .replaceAll("</ol>", "")
        .replaceAll("<div>", "")
        .replaceAll("</div>", "")
        .replaceAll("<span>", "")
        .replaceAll("</span>", "")
        .replaceAll("<h1>", "")
        .replaceAll("</h1>", "")
        .replaceAll("<h2>", "")
        .replaceAll("</h2>", "")
        .replaceAll("<h3>", "")
        .replaceAll("</h3>", "")
        .replaceAll("<h4>", "")
        .replaceAll("</h4>", "")
        .replaceAll("<h5>", "")
        .replaceAll("</h5>", "")
        .replaceAll("<h6>", "")
        .replaceAll("</h6>", "")
        .replaceAll("<hr>", "")
        .replaceAll("</hr>", "")
        .replaceAll("<blockquote>", "")
        .replaceAll("</blockquote>", "")
        .replaceAll("<pre>", "")
        .replaceAll("</pre>", "")
        .replaceAll("<code>", "")
        .replaceAll("</code>", "")
        .replaceAll("<sup>", "")
        .replaceAll("</sup>", "")
        .replaceAll("<sub>", "")
        .replaceAll("</sub>", "");
  }
}
