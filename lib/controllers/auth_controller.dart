import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString verificationIdStored = ''.obs;
  
  User? get user => _firebaseUser.value;
  bool get isLoggedIn => _firebaseUser.value != null;

  @override
  void onInit() {
    super.onInit();
    _firebaseUser.bindStream(_auth.authStateChanges());
    ever(_firebaseUser, _handleAuthChanged);
  }

  void _handleAuthChanged(User? user) {
    if (user != null) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login');
    }
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    try {
      isLoading.value = true;
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          Get.snackbar(
            'Success',
            'Auto-verified successfully!',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          String message = 'Verification failed';
          
          if (e.code == 'invalid-phone-number') {
            message = 'Invalid phone number format';
          } else if (e.code == 'too-many-requests') {
            message = 'Too many requests. Try again later';
          }
          
          Get.snackbar(
            'Error',
            message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          isLoading.value = false;
          verificationIdStored.value = verificationId;
          Get.snackbar(
            'Success',
            'OTP sent to $phoneNumber',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationIdStored.value = verificationId;
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to send OTP: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> verifyOTP(String otp) async {
    try {
      isLoading.value = true;
      
      if (verificationIdStored.value.isEmpty) {
        throw Exception('Verification ID not found. Please request OTP again.');
      }
      
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationIdStored.value,
        smsCode: otp,
      );
      
      await _auth.signInWithCredential(credential);
      
      Get.snackbar(
        'Success',
        'Login successful!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String message = 'Invalid OTP';
      
      if (e.code == 'invalid-verification-code') {
        message = 'Invalid OTP code';
      } else if (e.code == 'session-expired') {
        message = 'OTP expired. Please request a new one';
      }
      
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to verify OTP: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}