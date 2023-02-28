import 'package:chup/pages/chatpage.dart';
import 'package:chup/widgets/widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;

  const GroupTile(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            ChatPage(
              groupId: widget.groupId,
              groupName: widget.groupName,
              userName: widget.userName,
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
        child: ListTile(
          leading: Material(
            elevation: 30,
            borderRadius: BorderRadius.circular(40),
            color: Color.fromARGB(0, 0, 0, 0),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Color.fromRGBO(24, 24, 24, 1),
              child: Text(
                widget.groupName.substring(0, 1).toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.wallpoet(
                  textStyle: const TextStyle(
                    fontSize: 35,
                    color: Colors.white60,
                  ),
                ),
              ),
            ),
          ),
          title: Text(widget.groupName,
              style: GoogleFonts.electrolize(
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      letterSpacing: 2))),
          subtitle: Text("Join the conversation as ${widget.userName}",
              style: GoogleFonts.electrolize(
                  textStyle: const TextStyle(
                      fontSize: 14, color: Color.fromARGB(151, 0, 0, 0)))),
        ),
      ),
    );
  }
}
