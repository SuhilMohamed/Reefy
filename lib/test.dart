// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

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
    return const MaterialApp(
      home: SplashScreen(),
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
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OnboardingForm()));
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
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      setImage(image);
    });
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
      return 'Please pick ID Photo Back';
    }
    return null;
  }

  String? _validatePhotoFront() {
    if (_idPhotoFront == null) {
      return 'Please pick ID Photo Front';
    }
    return null;
  }

  String? _validateMobileNo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Mobile No';
    }
    if (value.length != 11 || !RegExp(r'^(011|012|010|015)').hasMatch(value)) {
      return 'Mobile No must be 11 digits and start with 011, 012, 010, or 015';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Name';
    }
    if (value.split(' ').length != 4) {
      return 'Name must be 4 words';
    }
    return null;
  }

  String? _validatePhoneNo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Phone Number';
    }
    if (!RegExp(r'^0\d+$').hasMatch(value)) {
      return 'Phone Number must start with 0 and contain only digits';
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
          Uri.parse('http://172.16.16.65:8080/api/upload/'));
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
      // request.fields['otp_code'] = _otpCode!;
      request.files.add(await http.MultipartFile.fromPath(
          '_id_photo_back', _idPhotoBack!.path));
      request.files.add(await http.MultipartFile.fromPath(
          '_id_photo_front', _idPhotoFront!.path));
      request.files.add(await http.MultipartFile.fromPath(
          '_selfie_photo', _selfiePhoto!.path));

      try {
        var response = await request.send().timeout(const Duration(seconds: 30));
        var responseBody = await http.Response.fromStream(response);

        /*
        if (response.statusCode == 200) {
          print(responseBody.body);
          print(response.statusCode);

        }
        */



        if (response.statusCode == 200) {
          print(response.statusCode);
          var responseData = json.decode(responseBody.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),

          );
          print(responseData['status']);
          setState(() {

            // _gpsLocation = null;
            _customerID = " "; //1
            _addressFromID = "" ; //1
            _addressMark = " "; //1
            _government = " "; //1
            _city = null;
            _idPhotoBack = null;
            _idPhotoFront = null;
            _selfiePhoto = null;
            _addressMark = null;
            _mobileNo = null;
            _isLoading = false;

          });
          if (responseData['status'] == 'message') {
            print(responseData['status']);

            // Reset the form
            _formKey.currentState!.reset();
            _customerIdFormKey.currentState!.reset();

            /*
            setState(() {
              // _gpsLocation = null;
              _idPhotoBack = null;
              _idPhotoFront = null;
              _selfiePhoto = null;
              _addressFromID = null;
              _customerID = null;
              _government = null;
              _city = null;
              _addressMark = null;
              _mobileNo = null;
            });
            */
          }
        } else {
          print(response.statusCode);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('حدث خطأ فى تسجيل الطلب')),
          );
        }
      } catch (e) {
        print(e);
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ. يُرجى المحاولة مرة أخرى في وقت لاحق')),
        );
      }
    } else {
      // Refresh the UI to show validation messages
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Customer Onboarding',
                style: TextStyle(color: Colors.white)),
            Image.asset(
              'assets/Reefy-banner.png', // Ensure the logo image is added in the assets folder and mentioned in pubspec.yaml
              height: 40,
              // width: 40,
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
                        const InputDecoration(labelText: 'Customer ID'),
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
                      const InputDecoration(labelText: 'Address from ID'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Address from ID';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _addressFromID = value;
                      },
                    ),
                    TextFormField(
                      decoration:
                      const InputDecoration(labelText: 'Address Mark'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Address Mark';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _addressMark = value;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration:
                      const InputDecoration(labelText: 'Government'),
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
                          return 'Please select a Government';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'City'),
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
                          return 'Please select a City';
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
                    const Divider(),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Mobile No'),
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                      validator: _validateMobileNo,
                      onSaved: (value) {
                        _mobileNo = value;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: _validateName,
                      onSaved: (value) {
                        _name = value;
                      },
                    ),
                    TextFormField(
                      decoration:
                      const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                      validator: _validatePhoneNo,
                      onSaved: (value) {
                        _phoneNo = value;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () => _showImageSourceActionSheet(
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
                        child: const Text('Submit'),
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
    );
  }
}
