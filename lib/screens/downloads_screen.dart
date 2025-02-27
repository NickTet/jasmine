import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/methods.dart';
import 'package:jasmine/screens/components/content_builder.dart';

import 'components/comic_download_card.dart';
import 'download_album_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  late Future<List<DownloadAlbum>> _downloadsFuture;

  @override
  void initState() {
    _downloadsFuture = methods.allDownloads();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("下载列表"),
      ),
      body: ContentBuilder(
        future: _downloadsFuture,
        onRefresh: () async {
          setState(() {
            _downloadsFuture = methods.allDownloads();
          });
        },
        successBuilder: (
          BuildContext context,
          AsyncSnapshot<List<DownloadAlbum>> snapshot,
        ) {
          return ListView(
            children: snapshot.requireData
                .map((e) => GestureDetector(
                      onTap: () {
                        if (e.dlStatus == 3) {
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                            return DownloadAlbumScreen(e);
                          }),
                        );
                      },
                      onLongPress: () async {
                        String? action = await chooseListDialog(context,
                            values: ["删除"], title: "请选择");
                        if (action != null && action == "删除") {
                          await methods.deleteDownload(e.id);
                          setState(() {
                            _downloadsFuture = methods.allDownloads();
                          });
                        }
                      },
                      child: ComicDownloadCard(e),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
