import 'package:chup/pages/homepage.dart';
import 'package:chup/service/databaseservice.dart';
import 'package:chup/widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;
  const GroupInfo(
      {super.key,
      required this.groupName,
      required this.groupId,
      required this.adminName});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  @override
  void initState() {
    getMembers();
    super.initState();
  }

  getMembers() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((val) {
      setState(() {
        members = val;
      });
    });
  }

  String getName(String r) {
    return r.substring(r.indexOf('_') + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Exit"),
                        content:
                            const Text("Are you sure you want the group?!"),
                        actions: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                              )),
                          IconButton(
                              onPressed: () async {
                                DatabaseService(
                                        uid: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .toggleGroupJoin(
                                        widget.groupId,
                                        widget.groupName,
                                        getName(widget.adminName))
                                    .whenComplete(() {
                                  nextScreenReplacement(
                                      context, const HomePage());
                                });
                              },
                              icon: const Icon(
                                Icons.done,
                                color: Colors.green,
                              )),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.exit_to_app))
        ],
        centerTitle: true,
        backgroundColor: Color.fromRGBO(241, 123, 147, 1),
        title: Text(
          "Group Info",
          style: GoogleFonts.electrolize(
              textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Material(
              elevation: 30,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Color.fromRGBO(241, 123, 147, 0.2)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  leading: Material(
                    elevation: 30,
                    borderRadius: BorderRadius.circular(40),
                    color: const Color.fromARGB(0, 0, 0, 0),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color.fromRGBO(24, 24, 24, 1),
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
                  title: Text("Group: ${widget.groupName}",
                      style: GoogleFonts.electrolize(
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              letterSpacing: 1))),
                  subtitle: Text("Admin: ${getName(widget.adminName)} ",
                      style: GoogleFonts.electrolize(
                          textStyle: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(151, 0, 0, 0)))),
                ),
              ),
            ),
            memberList()
          ],
        ),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
        stream: members,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['members'] != null) {
              if (snapshot.data['members'].length != 0) {
                return ListView.builder(
                  itemCount: snapshot.data['members'].length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 20),
                      child: ListTile(
                        leading: Material(
                          elevation: 30,
                          borderRadius: BorderRadius.circular(30),
                          color: Color.fromARGB(234, 0, 0, 0),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Color.fromRGBO(24, 24, 24, 1),
                            child: Text(
                              getName(snapshot.data['members'][index])
                                  .substring(0, 1)
                                  .toUpperCase(),
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
                        title: Text(getName(snapshot.data['members'][index]),
                            style: GoogleFonts.electrolize(
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    letterSpacing: 1))),
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text("No members"),
                );
              }
            } else {
              return const Center(
                child: Text("No members"),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(
                  color: Color.fromRGBO(239, 181, 82, 1)),
            );
          }
        });
  }
}
