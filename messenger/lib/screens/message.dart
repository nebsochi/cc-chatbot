// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messenger/models/CeeCee.dart';
import 'package:messenger/models/chatMessage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


import 'package:shared_preferences/shared_preferences.dart';



class Message extends StatefulWidget {
  const Message({ Key? key }) : super(key: key);

  
  @override
  _MessageState createState() => _MessageState();

   void addMessage(message){
        _MessageState().addMessage(message);
    }
}

class _MessageState extends State<Message> {
  var messageInput = TextEditingController();
  int selectedRadioSent = 0;
  String radioText = "";
  // final prefs = await SharedPreferences.getInstance();
  //   //print(prefs.getString('whatsapp_number'));
  //   var whatsappNumber = prefs.getString('whatsapp_number');

  final channel = WebSocketChannel.connect(
    Uri.parse('wss://bnpl-chatbot-server.herokuapp.com/socket.io/?phone=2348136932989&EIO=4&transport=websocket&sid=9g9ua16kEWrypmhWAAAA'),
  );

  

 
  ScrollController scrollController =  ScrollController();
  //var scroll = scrollController;
  List<ChatMessage> messages = [];

  addMessage(message,{person="sender"})
  {
      messages.add(ChatMessage(messageContent: message,messageType: person));
      // if (scrollController.hasClients) {
          scrollController.animateTo(
            // 1000.0
            scrollController.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 30),
          );
      //}
       
  }

  _getCeeCee({required String messageText,required String type}) async {

    final prefs = await SharedPreferences.getInstance();
    print(prefs.getString('whatsapp_number'));
    var whatsappNumber = prefs.getString('whatsapp_number');
    final response = await http.post(
      Uri.parse('https://sellbackend.creditclan.com/merchantclan/public/index.php/api/creditclan/bot'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "payload": {
            "type": type,
            type: messageText,
            "user": {
                "id": whatsappNumber,
            },
        }
      }),
    );
    
    final responseJson = json.decode(response.body); 
    
    setState(() {
      addMessage(responseJson);
    });
  }

  openAttachments(){
        return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          int selectedRadio = -1;
          return AlertDialog(
            //insetPadding: EdgeInsets.all(10.0),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                
                                GestureDetector(
                                  onTap: (){
                                    Navigator.of(context, rootNavigator: true).pop('dialog');
                                    _imageDialogCall(context);
                                    //
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 30.0,vertical: 20),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.blue[200],
                                    ),
                                    child: Icon(Icons.image_outlined,color: Colors.blue,),
                                  ),
                                ),
                                Text('Image',style: TextStyle(fontWeight: FontWeight.w500),)
                              ],
                            ),
                            //SizedBox(width: 30.0,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 30.0,vertical: 20),
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.red[200],
                                  ),
                                  child: Icon(Icons.location_on_outlined,color: Colors.red,),
                                ),
                                
                                Text('Location',style: TextStyle(fontWeight: FontWeight.w500),)
                              ],
                            ),
                            
                            
                        ],
                      ),
                    ),
                    
                  ],
                );
              },
            ),
            
          );
        });
    }


  Future<void> _imageDialogCall(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ImageDialog(onaddImage: (message){ 

            addMessage(message,person: "receiver");
            addMessage("Please wait while we upload your picture 🚀🚀🚀");
            setState(() {

              
            });
            
            },ongetCeeCee: (message){ 
               _getCeeCee(messageText: message, type: 'image');
              setState(() {
               
              });
            }
          );
        });
  }




  @override
  Widget build(BuildContext context) {
    DateTime dateNow = DateTime.now();
    String addZero = (dateNow.minute).toString().length == 2 ? '': '0';
      return Scaffold(
        appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        flexibleSpace: SafeArea(
          child: MessageTopBar(),
        ),
      ),
        body: Column(
          children:  [
              StreamBuilder(
                stream: channel.stream,
                builder: (context, snapshot) {
                  var data = snapshot.hasData ? '${snapshot.data}' : '';
                  print(data);
                  return Text(snapshot.hasData ? '${snapshot.data}' : '');
                },
              ),
              Expanded(
              child: Container(
                decoration: BoxDecoration(color:Colors.grey[200]),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: messages.length + 1,
                  shrinkWrap: true,     
                  padding: EdgeInsets.only(top:10,bottom: 10),
                  itemBuilder: (context, index){
                    if(index == messages.length)
                    {
                        int lastIndex = messages.length >= 3 ? index - 1 : 0;
                        return Container(
                          height: (messages.length <= 3 ? 300 : (messages[index - 2].messageContent is File ? 500 : 300)),
                          
                        );
                        
                    }
                    print(messages[index].messageContent);
                    return Container(
                      padding: EdgeInsets.only(left: 16,right: 16,top: 5,bottom: 5),
                      child: Align(
                        alignment: messages[index].messageType == "sender" ? Alignment.topLeft : Alignment.topRight,
                        child: Container(
                          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.20, maxWidth: MediaQuery.of(context).size.width * 0.80),
                           decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: messages[index].messageContent is File ? Colors.transparent : (messages[index].messageType == "sender" ? Colors.white : Colors.green[200]),
                          ),
                          //messages[index].messageContent is File ?  EdgeInsets.symmetric(horizontal: 0.0,vertical:0.0) :
                          padding:  EdgeInsets.symmetric(horizontal: 10.0,vertical:10.0),
                          // decoration: BoxDecoration(color:Colors.red[200]),
                          
                          child: messageCard(messages[index])
                        )
                      ),
                    );
                  },
                ),
                
              ),
            ),
              Container(
                padding: const EdgeInsets.only(left:20.0,right:20.0,top:15.0,bottom: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:  [
                    IconButton(
                      onPressed: (){
                          openAttachments();
                      },
                      icon: Icon(Icons.attach_file,color: Colors.grey,),
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onSubmitted: (value){
                          sendMessage();  
                        },
                        controller: messageInput,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50.0),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50.0),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          
                            filled: true,
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            hintText: "Message..",
                            fillColor: Colors.grey[100]),
                      ),
                    ),
                    IconButton(
                      onPressed: ()  {
                      
                        sendMessage();    
                        setState(()  {  
                            
                        });
                      },
                      icon: Icon(Icons.send,color: Colors.green,),
                    ),
                    
                  ],
                ),
              )
          ],
        )
        
    );
  }
  sendMessage() async {
    var message = messageInput.text;
    if(message.isNotEmpty)
    {
      addMessage(messageInput.text,person: "receiver");
      messageInput.clear();  
      await _getCeeCee(messageText: message,type:'text');
    }
    
      
  }
  Container emptyWidget()
  {
    return Container(height: 0,width: 0);
  }
   messageCard(message) {

    if(message.messageType == "sender")
    {
        var response = (message.messageContent);
        //String responseMessage =  response;
        String responseMessage =  response is String ? response  : (response['message'] is String ? response['message'] : response['message']['payload']['interactive']['body']['text']);


        return Column(
            
          children: [
            Text(responseMessage,style: GoogleFonts.poppins(fontSize: 14.0,fontWeight: FontWeight.w500)),
          response is String ? emptyWidget() : (response['message'] is String ? emptyWidget() : messageButtonList(response['message']))
            
          ],
        );
    }
    else
    { 
        var messageContent = message.messageContent;
        if(messageContent is File)
        {
            return  Image.file(messageContent,fit: BoxFit.cover,width:250.0,height:300.0); //Image.network(messageContent);

        }
        return Text(messageContent,style: GoogleFonts.poppins(fontSize: 14.0,fontWeight: FontWeight.w500));
    }
    
  }

    messageButtonList(response) {
      if(response['payload']['interactive']['type'] == "list")
      {
        String listButton = response['payload']['interactive']['action']['button'];
        var list = response['payload']['interactive']['action']['sections'][0];
          return Column(
            children: [
              Divider(
                color: Colors.grey[300],
                height: 20,
                thickness: 1,
                // indent: 10,
                // endIndent: 10,
              ),
              GestureDetector(
                onTap: (){
                  //print('tapped');
                  openListItems(list);
                },
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list,color: Colors.blue,),
                  SizedBox(width: 5.0,),
                  Text(listButton,style: GoogleFonts.poppins(fontSize: 13.0,color:Colors.blue,fontWeight: FontWeight.w500)),
                ],
                        ),
              ),
            ],
          );
      }
      if(response['payload']['interactive']['type'] == "button")
      {
          List buttons = response['payload']['interactive']['action']['buttons'];
          List<Widget> buttonsToDisplay = [];
          for (var button in buttons) {
            buttonsToDisplay.add(
                Container(
                  width: double.infinity, 
                  child: ElevatedButton(
                    onPressed: (){
                      setState(() {
                           addMessage(button['reply']['title'],person: "receiver");
                        _getCeeCee(messageText: button['reply']['id'],type: 'postback');
                        // scrollController.jumpTo(
                        // 1.5 * scrollController.position.maxScrollExtent);
                      });
                       
                    }, 
                    child: Text(button['reply']['title'])
                  )
                )
            ); 
          }
          return Container(
            margin: EdgeInsets.only(top:20.0),
            child: Column(
              children: buttonsToDisplay,
            ),
          );
      }
      
    }

    openListItems(list){
        return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          int selectedRadio = -1;
          return AlertDialog(
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(list['rows'].length, (int index) {
                    return Row(
                      children: [
                        Radio<int>(
                          value: index,
                          groupValue: selectedRadio,
                          onChanged: (value) {
                            setState(() { 
                              selectedRadio = value!;
                              selectedRadioSent = selectedRadio + 1;
                              radioText = list['rows'][index]['title'];
                              
                            });
                          },
                        ),
                        Text(list['rows'][index]['title'])
                      ],
                    );
                  }),
                );
              },
            ),
            actions: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 15.0,bottom: 10.0),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.green,
                  ),
                  child: IconButton(
                    onPressed: (){
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      
                      setState(() {
                          addMessage(radioText,person: "receiver");
                          _getCeeCee(messageText: selectedRadioSent.toString(),type: 'postback');
                      });
                    },
                    icon: Icon(Icons.send,color: Colors.white),
                  ),
                )
            ],
          );
        });
    }

    

}

//typedef addImageCallback = void Function(ChatMessage message);

class ImageDialog extends StatefulWidget {
  //const ImageDialog({ Key? key }) : super(key: key);
  final  Function onaddImage;
  final  Function ongetCeeCee;
   ImageDialog({required this.onaddImage, required this.ongetCeeCee});
  @override
  _ImageDialogState createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
   //var _message;
  String imagePath = "";
  var imageFile;


  //  @override
  // void initState() {
  //   super.initState();
  //   _message = _MessageState();
  // }

  Future getImageFromCamera() async {
    // var x = await ImagePicker.pickImage(source: ImageSource.camera);
    // imagePath = x.path;
    // image = Image(image: FileImage(x));
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
   
    print(image!.toString());
    setState(() {
       imagePath = image.path;
       imageFile = File(image.path);
    });
    
  }
  uploadImage(imagePath) async {

    try {
        var postUri = Uri.parse("https://mobile.creditclan.com/api/v3/upload/image");
        Map<String, String> headers = { "x-api-key": "WE4mwadGYqf0jv1ZkdFv1LNPMpZHuuzoDDiJpQQqaes3PzB7xlYhe8oHbxm6J228"};
        http.MultipartRequest request =  http.MultipartRequest("POST", postUri);
        request.headers.addAll(headers);
        http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
            'file', imagePath); 

        request.files.add(multipartFile);

        http.StreamedResponse response = await request.send();
        final respStr = await response.stream.bytesToString();
        return respStr;
    } catch (error) {
        return error;
    }
  }
  addImage()  async{
    
      
    setState(() {
      
      Navigator.of(context, rootNavigator: true).pop('dialog');
      widget.onaddImage(imageFile);
      FocusManager.instance.primaryFocus!.unfocus();
      
    });

    String response =  await uploadImage(imagePath);
    String uploadedImage = json.decode(response)['data']['filename'];
    widget.ongetCeeCee(uploadedImage);
  }
  
  
  @override
  Widget build(BuildContext context) {
      return AlertDialog(
        //insetPadding: EdgeInsets.all(10.0),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return GestureDetector(
              onTap: ()  {
                
                 getImageFromCamera();
              },
              child: Container(
                width: 400,
                height: 310,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    imageFile != null ? Container(child: Image.file(imageFile,fit: BoxFit.cover,height: 250,width: 200)) :
                    Container(
                      // padding: EdgeInsets.symmetric(horizontal: 50.0,vertical: 50.0),
                      width: double.maxFinite,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.0,color: Colors.black),
                        color: Colors.blue[200],
                      ),
                      child: Icon(Icons.add_a_photo_outlined,color: Colors.blue,size: 50,),
                    ),
                    imageFile != null ? Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(onPressed: (){}, child: Text('Change Image')),
                          SizedBox(width: 20.0,),
                          ElevatedButton(onPressed: (){ addImage(); }, child: Text('Add Image')),
                        ],
                      ),
                    ) : Container()
                    
                  ],
                ),
              ),
            );
          },
        ),
        
      );
        
  }
}

class CustomerMessageTopBar extends StatelessWidget {
  const CustomerMessageTopBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:60.0,left:30.0,bottom: 15.0),
      child: Row(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(50.0),
          child: Image.network("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhj5tCiNWAnuMdWnZN5LKuMG8wJmZtbMRGJQ&usqp=CAU", width: 50, height:50),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
                Text('CeeCee',style: TextStyle(color: Colors.white,fontSize: 18.0,fontWeight: FontWeight.bold)),
                // Text('Online',style: TextStyle(color: Colors.white,fontSize: 13.0,fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
      ),
    );
  }
}

class MessageTopBar extends StatelessWidget {
  const MessageTopBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 16),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,color: Colors.black,),
          ),
          SizedBox(width: 2,),
          CircleAvatar(
            backgroundImage: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhj5tCiNWAnuMdWnZN5LKuMG8wJmZtbMRGJQ&usqp=CAU"),
            maxRadius: 20,
          ),
          SizedBox(width: 12,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text("CeeCee",style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.w800, color: Colors.white),),
                SizedBox(height: 6,),
                // Text("Online",style: TextStyle(color: Colors.white, fontSize: 13,fontWeight: FontWeight.w700),),
              ],
            ),
          ),
          Icon(Icons.settings,color: Colors.black54,),
        ],
      ),
    );
  }
}



 
