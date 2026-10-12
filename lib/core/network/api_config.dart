class ApiConfig {
  // Thay thế IP này bằng địa chỉ IPv4 LAN của máy chủ (PC) đang chạy ASP.NET
  // Lấy IP bằng lệnh 'ipconfig' trên máy tính của bạn.
  static const String baseUrl = 'http://127.0.0.1:5094/api'; // Ví dụ, hãy sửa lại IP của bạn!
  
  static const int connectTimeout = 10000; // 10 giây
}


