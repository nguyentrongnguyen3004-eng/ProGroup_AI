class MockService {
  Future<bool> sendOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return true;
  }

  Future<bool> verifyOtp(String otp) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return otp == '123456';
  }

  Future<bool> resetPassword(String password) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return true;
  }
}
