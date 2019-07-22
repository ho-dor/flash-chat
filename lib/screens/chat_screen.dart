import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const id = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var _auth = FirebaseAuth.instance;
  var _firestore = Firestore.instance;
  FirebaseUser loggedin;
  String message;

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async{
    loggedin = await _auth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.popAndPushNamed(context, LoginScreen.id);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').snapshots(),
              // ignore: missing_return
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                final messages = snapshot.data.documents.reversed;
                List<MessageBubble> messageWidgets = [];
                for (var message in messages) {
                  final messageText = message.data['text'];
                  final messageSender = message.data['sender'];
                  final messageWidget = MessageBubble(
                    sender: messageSender,
                    text: messageText,
                    color: messageSender == loggedin.email? Colors.white: Colors.lightBlueAccent,
                    alignment: messageSender == loggedin.email? CrossAxisAlignment.start: CrossAxisAlignment.end,
                    borderRadius: messageSender == loggedin.email?BorderRadius.only(topRight: Radius.circular(30.0),bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0) ):
                    BorderRadius.only(topLeft: Radius.circular(30.0),bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0) )
                  );
                  messageWidgets.add(messageWidget);
                }
                return Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    children: messageWidgets,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (value) {
                        //Do something with the user input.
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      //Implement send functionality.
                      _firestore.collection('messages').add({
                        'sender': loggedin.email,
                        'text': message
                      });
                      _controller.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {

  MessageBubble({@required this.sender, @required this.text, @required this.color, @required this.alignment, @required this.borderRadius});

  String text;
  String sender;
  Color color;
  CrossAxisAlignment alignment;
  BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: <Widget>[
          Text(sender,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.grey,
            ),
          ),
          Material(
              elevation: 5.0,
              color: color,
              borderRadius: borderRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal:15.0),
                child: Text('$text',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0
                  ),
                ),
              ),
          ),
        ],
      ),
    );
  }
}

