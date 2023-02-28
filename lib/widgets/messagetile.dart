import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;
  const MessageTile(
      {super.key,
      required this.message,
      required this.sender,
      required this.sentByMe});

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 15,
          bottom: 4,
          left: widget.sentByMe ? 0 : 24,
          right: widget.sentByMe ? 24 : 0),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sentByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
            const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            color: widget.sentByMe
                ? const Color.fromRGBO(241, 123, 147, 0.6)
                : const Color.fromRGBO(241, 123, 147, 0.6),
            borderRadius: widget.sentByMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.sender.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.electrolize(
                  textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black))),
          const SizedBox(
            height: 8,
          ),
          Text(widget.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.electrolize(
                  textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black))),
        ]),
      ),
    );
  }
}
