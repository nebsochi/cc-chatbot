import 'package:flutter/material.dart';
import 'package:messenger/screens/message.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Register extends StatelessWidget {
  final whatsappNumber = TextEditingController();
  final fullName = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Register({ Key? key }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(pattern);
    // var whatsappNumberText = whatsappNumber.text;
    // var fullNameText = fullName.text;
    // bool keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    continueToChat() async{
    
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('whatsapp_number', whatsappNumber.text);
      prefs.setString('full_name', fullName.text);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Message()),
      );

    }
    validateFullName(value){
      
      if (value!.isEmpty) {
        return 'Please enter a valid full name';
      }
      return null;
    }
    validateMobileNumber(whatsappNumberText){
      
      if (whatsappNumberText.isEmpty) {
        return 'Please enter a mobile number';
      }
      else if (!regExp.hasMatch(whatsappNumberText) && whatsappNumberText.length != 12) {
            return 'Please enter valid mobile number';
      }
      return null;
          
    }
    return Scaffold(
      resizeToAvoidBottomInset : false,
      backgroundColor: Colors.green,
      body: Column(
        
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.30,
            width: MediaQuery.of(context).size.width,
            color: Colors.green,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.70,
            width: MediaQuery.of(context).size.width,
            decoration:  const BoxDecoration(
              borderRadius:   BorderRadius.only(topLeft: Radius.circular(50),topRight: Radius.circular(50)),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
               const Padding(
                  padding: EdgeInsets.only(left: 40.0,top: 50,bottom: 40),
                  child: Text('Chat With CeeCee',style: TextStyle(fontWeight: FontWeight.w900,fontSize: 25),),
                ),
                Form(
                   key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.only(left:30.0,right: 30.0,top: 15.0,bottom: 15.0),
                    width: 400,
                    //height: 500.0,
                    child: Column(
                      children: [
                        
                        RegisterForm(keyboardType: TextInputType.text, label: 'Full name',placeholder: 'Nebechi Chukwudum',icon: Icons.account_circle_outlined,controller: fullName,validateText: validateFullName),
                        SizedBox(height:30.0),
                        RegisterForm(keyboardType: TextInputType.number,label: 'Whatsapp Number',placeholder: '08136932957',icon: Icons.phone,controller: whatsappNumber,validateText: validateMobileNumber),
                        SizedBox(height:40.0),
                        Container(
                          width: double.maxFinite,
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child:  Center(
                            child: TextButton(
                              onPressed: (){ 
                                 if (_formKey.currentState!.validate()){
                                   continueToChat(); 
                                 }
                                
                              }, 
                              child: const Text('Continue to Chat',style: TextStyle(color: Colors.white,fontSize: 15.0,fontWeight: FontWeight.w700),)))
                        )
                        
                      ],
                    ),
                  )
                )
              ],
            ),
              
          ),
          SizedBox(
      height: MediaQuery.of(context).viewInsets.bottom,
    ),
        ],
      ),
    );
  }
}

class RegisterForm extends StatelessWidget {

  String placeholder;
  String label;
  dynamic icon;
  dynamic controller;
  Function validateText;
  TextInputType keyboardType;

   RegisterForm({
    Key? key,
    required this.keyboardType,
    required this.placeholder,
    required this.label,
    required this.icon,
    required this.controller,
    required this.validateText
  }) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    
    ///padding: const EdgeInsets.only(left:30.0,right: 30.0,top: 15.0,bottom: 15.0),
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      //padding: const EdgeInsets.all(30.0),
      children: [
        Text(label,style: TextStyle(fontWeight:FontWeight.w700,)),
        SizedBox(height: 10.0,),
        TextFormField(
          keyboardType: keyboardType,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: controller,
          decoration:  InputDecoration(
            prefixIcon:  Icon(icon),
            hintText: placeholder,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(
                color: Colors.green,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(
                color: Colors.green,
                
              ),
            ),
            //labelText: 'Email',
          ),
          onSaved: (String? value) {
            // This optional block of code can be used to run
            // code when the user saves the form.
          },
          validator: (value) =>  validateText(value)
    
        ),
      ]
    );
  }
}