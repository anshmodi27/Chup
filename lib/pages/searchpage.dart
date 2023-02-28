import 'dart:developer';
import 'package:chup/helper/helper_function.dart';
import 'package:chup/pages/chatpage.dart';
import 'package:chup/service/databaseservice.dart';
import 'package:chup/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  bool isJoined = false;
  User? user;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName() async {
    await HelperFunction.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String r) {
    return r.substring(r.indexOf('_') + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(241, 123, 147, 1),
        title: Text(
          "Search",
          style: GoogleFonts.electrolize(
              textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
      ),
      body: Column(children: [
        const SizedBox(height: 5),
        Material(
          elevation: 30,
          color: Color.fromRGBO(0, 0, 0, 0),
          child: Center(
            child: Container(
                width: 360,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(18, 18, 18, 0.8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: searchController,
                      style: GoogleFonts.electrolize(
                          textStyle: const TextStyle(
                              fontSize: 18,
                              color: Color.fromRGBO(255, 255, 255, 0.7))),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search Groups ...",
                        hintStyle: GoogleFonts.electrolize(
                            textStyle: const TextStyle(
                                fontSize: 18,
                                color: Color.fromRGBO(255, 255, 255, 0.7))),
                      ),
                    )),
                    GestureDetector(
                      onTap: () {
                        initSearchMethod();
                      },
                      child: Material(
                        elevation: 40,
                        color: const Color.fromRGBO(0, 0, 0, 0),
                        child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                                color: const Color.fromRGBO(255, 255, 255, 0.2),
                                borderRadius: BorderRadius.circular(15)),
                            child: const Icon(Icons.search,
                                size: 30,
                                color: Color.fromRGBO(255, 255, 255, 0.7))),
                      ),
                    )
                  ],
                )),
          ),
        ),
        _isLoading
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: const Center(
                    child: CircularProgressIndicator(
                        color: Color.fromRGBO(239, 181, 82, 1))),
              )
            : groupList(),
      ]),
    );
  }

  initSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseService()
          .searchByName(searchController.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          _isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  groupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return GroupTile(
                userName,
                searchSnapshot!.docs[index]['groupId'],
                searchSnapshot!.docs[index]['groupName'],
                searchSnapshot!.docs[index]['admin'],
              );
            },
          )
        : Container();
  }

  joinOrNot(
      String userName, String groupId, String groupName, String admin) async {
    await DatabaseService(uid: user!.uid)
        .isUserJoined(groupName, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget GroupTile(
      String userName, String groupId, String groupName, String admin) {
    // function for check user already exits in group
    joinOrNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      leading: Material(
        elevation: 30,
        borderRadius: BorderRadius.circular(40),
        color: const Color.fromARGB(0, 0, 0, 0),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: const Color.fromRGBO(24, 24, 24, 1),
          child: Text(
            groupName.substring(0, 1).toUpperCase(),
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
      title: Text(groupName,
          style: GoogleFonts.electrolize(
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  letterSpacing: 2))),
      subtitle: Text("Admin: ${getName(admin)} ",
          style: GoogleFonts.electrolize(
              textStyle: const TextStyle(
                  fontSize: 14, color: Color.fromARGB(151, 0, 0, 0)))),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid)
              .toggleGroupJoin(groupId, groupName, userName);
          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
            });
            ShowSnackbar(context, Colors.green, "Successfully Joined");
            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      userName: userName));
            });
          } else {
            setState(() {
              isJoined = !isJoined;
            });
            ShowSnackbar(context, Colors.red, "Left the Group $groupName");
          }
        },
        child: isJoined
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromRGBO(24, 24, 24, 1),
                    border: Border.all(color: Colors.white, width: 1)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(
                  "Joined",
                  style: GoogleFonts.electrolize(
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.white60,
                          letterSpacing: 2)),
                ),
              )
            : Material(
                elevation: 30,
                borderRadius: BorderRadius.circular(40),
                color: const Color.fromRGBO(0, 0, 0, 0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Color.fromRGBO(24, 24, 24, 1),
                      border: Border.all(color: Colors.white, width: 1)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Icon(
                    Icons.diversity_2,
                    color: Colors.white70,
                  ),
                ),
              ),
      ),
    );
  }
}
