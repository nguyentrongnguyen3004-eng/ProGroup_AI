# 05. Kiểm toán Môi trường Android Emulator

**Thiết bị kiểm thử:** `emulator-5554` (`Pixel_7_Pro_API_34`, `sdk_gphone64_x86_64`, `Android 14`)  
**Cấu hình ứng dụng:** `com.example.progroup_ai_frontend` (`versionName=1.0.3`)

---

## 1. Thông số Phần cứng & Cấu hình Máy ảo

Qua kiểm tra file `config.ini` của AVD `Pixel_7_Pro_API_34` và lệnh `adb shell`:

| Thông số | Giá trị đo được | Đánh giá tác động hiệu năng |
| --- | --- | --- |
| Hệ điều hành máy ảo | Android 14 (`API 34`, x86_64) | Hỗ trợ tốt Flutter debug/profile |
| Số CPU cores | 4 cores | Đủ cho UI + Dart isolate nếu không bị spam 10+ HTTP parse JSON đồng thời |
| RAM máy ảo (`MemTotal` / `config.ini`) | `/proc/meminfo` `MemTotal: 4,016,096 kB` (`config.ini` ghi `hw.ramSize=2G`, `vm.heapSize=384M`) | Khi app nhận nhiều payload JSON lớn + decode Base64 avatar lặp lại, heap 384 MB dễ kích hoạt GC |
| Độ phân giải & Mật độ điểm ảnh | `1440 x 3120`, `560 dpi` (`hw.lcd.width=1440`, `hw.lcd.height=3120`, `hw.lcd.density=560`) | Mật độ 560 dpi rất cao; ảnh không đặt `cacheWidth`/`cacheHeight` tốn bộ nhớ texture GPU khi rasterize |
| Chế độ đồ họa (`hw.gpu.mode`) | `host` | Sử dụng GPU máy host, phù hợp |

---

## 2. Kiểm tra Kết nối Mạng từ Emulator về Backend Host

Một giả thuyết thường gặp khi emulator tải chậm là độ trễ mạng `10.0.2.2` (cầu NAT của Android Emulator tới `localhost` máy host) hoặc lỗi `adb reverse`. Kết quả đo thực tế bác bỏ giả thuyết này:

- **`adb reverse --list`:** `host-16 tcp:5094 tcp:5094` (đã ánh xạ `127.0.0.1:5094` trong emulator trực tiếp tới port `5094` trên Windows host).
- **Độ trễ loopback `10.0.2.2`:**
  - Lần audit ban đầu: `ping avg = 3.064 ms`.
  - Lần tái kiểm tra cuối phiên (`ping -c 3 10.0.2.2`): `min = 1.735 ms`, `avg = 5.541 ms`, `max = 12.680 ms`, `0% packet loss`.
- **Kiểm tra mở 5 kết nối TCP liên tiếp tới `127.0.0.1:5094` (`toybox nc`):** Tổng thời gian cả 5 kết nối là **`0.15s` (~30 ms/lần cả tiến trình shell)**.

**Kết luận về Emulator:**  
Độ trễ truyền qua `adb reverse` / `10.0.2.2` chỉ ở mức vài mili-giây. Emulator **không phải nguyên nhân gây treo 14–25 giây**, nhưng các giới hạn tài nguyên sau trên AVD `Pixel_7_Pro_API_34` ảnh hưởng trực tiếp tới khả năng chạy ổn định:

1. **Thiếu dung lượng bộ nhớ trong (`/data` đầy 89%):** Kiểm tra bằng `adb shell df -h /data` cho thấy phân vùng `/dev/block/dm-40` có tổng `5.8G`, đã dùng `5.0G`, chỉ còn **`638M` trống (`89%`)**. Khi thử cài bản `app-debug.apk` mới build bằng `adb install -r`, Android trả lỗi **`Failure [INSTALL_FAILED_INSUFFICIENT_STORAGE: Failed to override installation location]`**, và lệnh khởi chạy bản APK cũ (`14:51:11`) bằng `am start -S -W` bị `Status: timeout` (`WaitTime: 11279 ms`).
2. **RAM & mật độ điểm ảnh:** Thiết lập màn hình `1440x3120 @ 560dpi` cùng RAM host thấp (`775 MB` free trên `15,676 MB` khi chạy đồng thời emulator + IDE + SQL Server) làm tăng áp lực bộ nhớ chung và khuếch đại lỗi `RESOURCE_SEMAPHORE` ở SQL Server.

