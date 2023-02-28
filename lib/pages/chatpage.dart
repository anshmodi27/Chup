import 'package:chup/pages/groupinfo.dart';
import 'package:chup/pages/searchpage.dart';
import 'package:chup/service/databaseservice.dart';
import 'package:chup/widgets/messagetile.dart';
import 'package:chup/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String admin = "";
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseService().getChat(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  nextScreen(
                      context,
                      GroupInfo(
                        groupName: widget.groupName,
                        groupId: widget.groupId,
                        adminName: admin,
                      ));
                },
                icon: const Icon(Icons.info))
          ],
          centerTitle: true,
          backgroundColor: Color.fromRGBO(241, 123, 147, 1),
          title: Text(
            widget.groupName,
            style: GoogleFonts.electrolize(
                textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ),
        body: Stack(
          children: <Widget>[
            chatMessage(),
            Container(
                alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Expanded(
                          child: Material(
                        elevation: 30,
                        borderRadius: BorderRadius.circular(20),
                        child: TextFormField(
                          controller: messageController,
                          style: GoogleFonts.electrolize(
                              textStyle: const TextStyle(
                                  fontSize: 20, color: Colors.black)),
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              border: InputBorder.none,
                              hintText: "Type...",
                              hintStyle: GoogleFonts.electrolize(
                                  textStyle: const TextStyle(
                                      fontSize: 20, color: Colors.black54))),
                        ),
                      )),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          sendMessage();
                        },
                        child: Material(
                          elevation: 20,
                          color: Color.fromRGBO(255, 255, 255, 1),
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                // color: Color.fromRGBO(48, 48, 48, 1),
                                borderRadius: BorderRadius.circular(50)),
                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ));
  }

  chatMessage() {
    return StreamBuilder(
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: ((context, index) {
                  return MessageTile(
                      message: snapshot.data.docs[index]["message"],
                      sender: snapshot.data.docs[index]["sender"],
                      sentByMe: widget.userName ==
                          snapshot.data.docs[index]["sender"]);
                }),
              )
            : Container();
      },
      stream: chats,
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().microsecondsSinceEpoch,
      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
