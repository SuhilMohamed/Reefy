// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';
import 'validator.dart';
import 'data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('ar', 'EG'), // Arabic
      ],
      locale: const Locale('ar', 'EG'), // Set the locale to Arabic
      home: const SplashScreen(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const GreetingPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/Reefy-banner.png'), // Ensure the logo image is added in the assets folder and mentioned in pubspec.yaml
      ),
    );
  }
}

class GreetingPage extends StatelessWidget {
  const GreetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شركة ريفى ترحب بكم'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'شكرا لاستخدامكم خدمات ريفي',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OnboardingForm()));
              },
              child: const Text('استمرار'),
            ),
          ],
        ),
      ),
    );
  }
}


class OnboardingForm extends StatefulWidget {
  const OnboardingForm({super.key});

  @override
  _OnboardingFormState createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
  final _formKey = GlobalKey<FormState>();
  final _customerIdFormKey = GlobalKey<FormState>();

  // Form fields (Part 1)
  String? _customerID;
  String? _addressFromID;
  String? _addressMark;
  String? _government;
  String? _city;
  String? _natureWork;
  String? _requiredMoney;

  // Position? _gpsLocation;
  XFile? _idPhotoBack;
  XFile? _idPhotoFront;

  // Form fields (Part 2)
  String? _mobileNo;
  String? _name;
  String? _phoneNo;
  XFile? _selfiePhoto;
  // String? _otpCode;

  final ImagePicker _picker = ImagePicker();
  List<String> _cities = [];
  bool _isLoading = false;


  // Future<void> _getCurrentLocation() async {
  //   Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   setState(() {
  //     _gpsLocation = position;
  //   });
  // }

  Future<void> _pickImage(XFile? Function(XFile? pickedFile) setImage) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      setImage(image);
    });
  }

  Future<void> _takeImage(XFile? Function(XFile? pickedFile) setImage) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear, // Use the rear camera for id photos
    );
    setState(() {
      setImage(image);
    });
  }

  Future<void> _takeSelfie(XFile? Function(XFile? pickedFile) setImage) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front, // Use the front camera for selfies
    );
    setState(() {
      setImage(image);
    });
  }
  Future<void> _showImageSourceActionSheetForSelfie(
      XFile? Function(XFile? pickedFile) setImage) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Selfie'),
                onTap: () {
                  Navigator.pop(context);
                  _takeSelfie(setImage);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(setImage);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> _showImageSourceActionSheet(
      XFile? Function(XFile? pickedFile) setImage) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takeImage(setImage);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(setImage);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // String? _validateLocation() {
  //   if (_gpsLocation == null) {
  //     return 'Please get GPS Location';
  //   }
  //   return null;
  // }

  String? _validatePhotoBack() {
    if (_idPhotoBack == null) {
      return 'الرجاء اختيار صورة البطاقه من الخلف';
    }
    return null;
  }

  String? _validatePhotoFront() {
    if (_idPhotoFront == null) {
      return 'الرجاء اختيار صورة البطاقه من الامام';
    }
    return null;
  }

  String? _validateMobileNo(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم المحمول';
    }
    if (value.length != 11 || !RegExp(r'^(011|012|010|015)').hasMatch(value)) {
      return 'يجب أن يتكون رقم المحمول من 11 رقمًا ويبدأ بـ 011 أو 012 أو 010 أو 015';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال الاسم';
    }
    if (value.split(' ').length != 4) {
      return 'يجب أن يكون الاسم رباعي';
    }
    return null;
  }

  String? _validatePhoneNo(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    if (!RegExp(r'^0\d+$').hasMatch(value)) {
      return 'يجب أن يبدأ رقم الهاتف بالرقم 0 ويحتوي على أرقام فقط';
    }
    return null;
  }

  // String? _validateOTPCode(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'Please enter OTP Code';
  //   }
  //   return null;
  // }

  Future<void> _submitForm() async {
    if (_customerIdFormKey.currentState!.validate() &&
        _formKey.currentState!.validate() &&
        // _validateLocation() == null &&
        _validatePhotoBack() == null &&
        _validatePhotoFront() == null &&
        _selfiePhoto != null) {
        _customerIdFormKey.currentState!.save();
        _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      // Prepare the form data
      var request = http.MultipartRequest('POST',
          Uri.parse('http://92.112.193.71:8081/api/Upload'));
      request.fields['customer_id'] = _customerID!;
      request.fields['address_from_id'] = _addressFromID!;
      request.fields['address_mark'] = _addressMark!;
      request.fields['government'] = _government!;
      request.fields['city'] = _city!;
      // request.fields['gps_latitude'] = _gpsLocation!.latitude.toString();
      // request.fields['gps_longitude'] = _gpsLocation!.longitude.toString();
      request.fields['mobile_no'] = _mobileNo!;
      request.fields['name'] = _name!;
      request.fields['phone_no'] = _phoneNo!;
      request.fields['nature_of_work'] = _natureWork!;
      request.fields['required_amount_of_money'] = _requiredMoney!;
      // request.fields['otp_code'] = _otpCode!;
      request.files.add(await http.MultipartFile.fromPath(
          '_id_photo_back', _idPhotoBack!.path));
      request.files.add(await http.MultipartFile.fromPath(
          '_id_photo_front', _idPhotoFront!.path));
      request.files.add(await http.MultipartFile.fromPath(
          '_selfie_photo', _selfiePhoto!.path));


      try {
        var response = await request.send();
        var responseBody = await http.Response.fromStream(response);

        setState(() {
          _isLoading = false;
        });


        if (response.statusCode == 200) {
          var responseData = json.decode(responseBody.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),

          );
          setState(() {
            _customerID = ""; // Clear the field
            _addressFromID = ""; // Clear the field
            _addressMark = ""; // Clear the field
            _government = ""; // Clear the field
            _natureWork = ""; // Clear the field
            _requiredMoney = ""; // Clear the field
            _city = null;
            _idPhotoBack = null;
            _idPhotoFront = null;
            _selfiePhoto = null;
            _mobileNo = null;
            _name = null;
            _phoneNo = null;
          });

          if (responseData['status'] == 'success') {
            // Reset the form
            _formKey.currentState!.reset();
            _customerIdFormKey.currentState!.reset();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('حدث خطأ فى تسجيل الطلب')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ. يُرجى المحاولة مرة أخرى في وقت لاحق')),
        );
      }
    } else {
      setState(() {}); // Refresh the UI to show validation messages
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GreetingPage()),
      );
      return false;
    },
    child: Scaffold(
    appBar: AppBar(
    title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    const Text('عملاء ريفي', style: TextStyle(color: Colors.black)),
    Image.asset(
    'assets/Reefy-banner.png', // Ensure the logo image is added in the assets folder and mentioned in pubspec.yaml
    height: 40,
    ),
         ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Form(
                      key: _customerIdFormKey,
                      child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'الرقم القومي'),
                        keyboardType: TextInputType.number,
                        maxLength: 14,
                        validator: (value) {
                          var result = validateNationalID(value ?? "");
                          if (!result.status) {
                            return result.message;
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _customerID = value;
                        },
                      ),
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'العنوان من البطاقه'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال العنوان من رقم البطاقه';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _addressFromID = value;
                      },
                    ),

                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'علامه مميزه للعنوان'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال علامه مميزه';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _addressMark = value;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'المحافظة'),
                      items: governmentToCities.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(key),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _government = newValue;
                          _cities = governmentToCities[newValue!]!;
                          _city =
                              null; // Reset city value when government changes
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء تحديد المحافظة';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'المدينة'),
                      items: _cities.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _city = newValue;
                        });
                      },
                      value: _city,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء اختيار المدينة';
                        }
                        return null;
                      },
                    ),
                    // const SizedBox(height: 20.0),
                    // ElevatedButton(
                    //   onPressed: _getCurrentLocation,
                    //   child: Text(_gpsLocation == null
                    //       ? 'Get GPS Location'
                    //       : 'Location: ${_gpsLocation!.latitude}, ${_gpsLocation!.longitude}'),
                    // ),
                    // if (_gpsLocation == null)
                    //   const Padding(
                    //     padding: EdgeInsets.only(top: 8.0),
                    //     child: Text(
                    //       'Please get GPS Location',
                    //       style: TextStyle(color: Colors.red),
                    //     ),
                    //   ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () => _showImageSourceActionSheet(
                          (pickedFile) => _idPhotoBack = pickedFile),
                      child: Text(_idPhotoBack == null
                          ? 'اختر صورة الهوية من الخلف'
                          : 'تم تحديد واجهة الصورة'),
                    ),
                    if (_idPhotoBack == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'يرجى اختيار صورة الهوية الخلفية',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () => _showImageSourceActionSheet(
                          (pickedFile) => _idPhotoFront = pickedFile),
                      child: Text(_idPhotoFront == null
                          ? 'اختر صورة الهوية من الأمام'
                          : 'تم تحديد واجهة الصورة'),
                    ),
                    if (_idPhotoFront == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'يرجى اختيار صورة الهوية الأمامية',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 20.0),
                    // const Divider(),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'رقم المحمول'),
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                      validator: _validateMobileNo,
                      onSaved: (value) {
                        _mobileNo = value;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'الاسم'),
                      validator: _validateName,
                      onSaved: (value) {
                        _name = value;
                      },
                    ),
                    TextFormField(
                      decoration:
                      const InputDecoration(labelText: 'طبيعه النشاط'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال طبيعه النشاط';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _natureWork = value;
                      },
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'رقم الهاتف المنزلي'),
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                      validator: _validatePhoneNo,
                      onSaved: (value) {
                        _phoneNo = value;
                      },
                    ),
                    TextFormField(
                      decoration:
                      const InputDecoration(labelText: 'المبلغ المالي المطلوب'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال المبلغ المالي';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _requiredMoney = value;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () => _showImageSourceActionSheetForSelfie(
                              (pickedFile) => _selfiePhoto = pickedFile),
                      child: Text(_selfiePhoto == null
                          ? 'اختر صورة سيلفي'
                          : 'تم اختيار صورة سيلفي'),
                    ),
                    if (_selfiePhoto == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'يرجى اختيار صورة سيلفي',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    // TextFormField(
                    //   decoration: const InputDecoration(labelText: 'OTP Code'),
                    //   keyboardType: TextInputType.number,
                    //   maxLength: 4,
                    //   validator: _validateOTPCode,
                    //   onSaved: (value) {
                    //     _otpCode = value;
                    //   },
                    // ),
                    const SizedBox(height: 20.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('تقديم'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    ),
    );
  }
}