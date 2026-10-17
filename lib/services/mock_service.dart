<<<<<<< HEAD
import 'api_service.dart';

class MockService {
  /// Gửi mã OTP xác thực qua Email thật bằng Gmail SMTP
  Future<bool> sendOtp(String email) async {
    try {
      final res = await ApiService.instance.post(
        '/api/auth/forgot-password/send-otp',
        {'email': email.trim()},
      );
      if (res is Map && res['success'] == true) {
        return true;
      }
      return false;
    } on ApiException catch (e) {
      throw e.message;
    } catch (_) {
      throw 'Không thể kết nối máy chủ gửi thư. Vui lòng kiểm tra kết nối mạng.';
    }
  }

  /// Xác thực mã OTP người dùng nhập
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final res = await ApiService.instance.post(
        '/api/auth/forgot-password/verify-otp',
        {
          'email': email.trim(),
          'otp': otp.trim(),
        },
      );
      if (res is Map && res['success'] == true) {
        return true;
      }
      return false;
    } on ApiException catch (e) {
      throw e.message;
    } catch (_) {
      throw 'Lỗi xác thực mã OTP. Vui lòng thử lại.';
    }
  }

  /// Đặt lại mật khẩu mới với mã OTP đã xác thực
  Future<bool> resetPassword(String email, String otp, String password) async {
    try {
      final res = await ApiService.instance.post(
        '/api/auth/forgot-password/reset-password',
        {
          'email': email.trim(),
          'otp': otp.trim(),
          'newPassword': password,
        },
      );
      if (res is Map && res['success'] == true) {
        return true;
      }
      return false;
    } on ApiException catch (e) {
      throw e.message;
    } catch (_) {
      throw 'Không thể đặt lại mật khẩu lúc này. Vui lòng thử lại.';
    }
  }
}
=======
// All mock services have been fully replaced with live production API services.
>>>>>>> origin/Frontend
