using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace ProGroup_AI.API.Services;

public interface IEmailService
{
    Task<bool> SendOtpEmailAsync(string toEmail, string otpCode, string recipientName = "Người dùng");
}

public class EmailService : IEmailService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<EmailService> _logger;

    public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<bool> SendOtpEmailAsync(string toEmail, string otpCode, string recipientName = "Người dùng")
    {
        try
        {
            var smtpServer = _configuration["EmailSettings:SmtpServer"] ?? "smtp.gmail.com";
            var port = int.TryParse(_configuration["EmailSettings:Port"], out var p) ? p : 587;
            var senderEmail = _configuration["EmailSettings:SenderEmail"] ?? "nguyentrongnguyen30042005@gmail.com";
            var senderPassword = _configuration["EmailSettings:SenderPassword"] ?? "fdwv lpjz pakd cifz";
            var displayName = _configuration["EmailSettings:SenderDisplayName"] ?? "ProGroup AI";

            var fromAddress = new MailAddress(senderEmail, displayName);
            var toAddress = new MailAddress(toEmail);
            var subject = $"[{otpCode}] Mã xác thực OTP đặt lại mật khẩu - ProGroup AI";

            var htmlContent = $@"
            <div style='font-family: -apple-system, BlinkMacSystemFont, ""Segoe UI"", Roboto, Helvetica, Arial, sans-serif; max-width: 560px; margin: 0 auto; padding: 32px 24px; background-color: #0F172A; border-radius: 20px; color: #F8FAFC;'>
                <div style='text-align: center; padding-bottom: 24px; border-bottom: 1px solid #334155;'>
                    <div style='display: inline-block; padding: 10px 18px; background: linear-gradient(135deg, #1E3A5F 0%, #2563EB 100%); border-radius: 12px; margin-bottom: 12px;'>
                        <span style='font-size: 20px; font-weight: 800; color: #FFFFFF; letter-spacing: 0.5px;'>ProGroup AI</span>
                    </div>
                    <h2 style='margin: 0; font-size: 20px; font-weight: 700; color: #FFFFFF;'>Xác thực đặt lại mật khẩu</h2>
                </div>

                <div style='padding: 28px 0;'>
                    <p style='font-size: 15px; color: #E2E8F0; margin: 0 0 12px 0;'>Xin chào <strong>{recipientName}</strong>,</p>
                    <p style='font-size: 14px; line-height: 1.6; color: #94A3B8; margin: 0 0 24px 0;'>
                        Hệ thống ProGroup AI vừa nhận được yêu cầu đặt lại mật khẩu cho tài khoản liên kết với địa chỉ email này. Vui lòng sử dụng mã xác thực OTP bên dưới để tiếp tục:
                    </p>

                    <div style='text-align: center; margin: 28px 0;'>
                        <div style='display: inline-block; background: linear-gradient(135deg, #2563EB 0%, #7C3AED 100%); padding: 2px; border-radius: 16px;'>
                            <div style='background-color: #1E293B; border-radius: 14px; padding: 18px 36px;'>
                                <span style='font-size: 36px; font-weight: 800; color: #38BDF8; letter-spacing: 10px; font-family: monospace;'>{otpCode}</span>
                            </div>
                        </div>
                        <p style='font-size: 13px; color: #94A3B8; margin-top: 16px; margin-bottom: 4px;'>
                            Mã OTP này có hiệu lực trong vòng <strong>5 phút</strong>.
                        </p>
                        <p style='font-size: 12px; color: #38BDF8; margin: 0;'>
                            <em>📋 Nhấp và giữ vào mã để sao chép nhanh vào ứng dụng.</em>
                        </p>
                    </div>

                    <div style='background-color: #1E293B; border-radius: 12px; padding: 14px 16px; border-left: 4px solid #F59E0B;'>
                        <p style='font-size: 12.5px; color: #CBD5E1; margin: 0; line-height: 1.5;'>
                            <strong>Lưu ý bảo mật:</strong> Nếu bạn không yêu cầu hành động này, vui lòng bỏ qua email và kiểm tra lại bảo mật tài khoản. Tuyệt đối không chia sẻ mã này cho bất kỳ ai.
                        </p>
                    </div>
                </div>

                <div style='text-align: center; padding-top: 20px; border-top: 1px solid #334155;'>
                    <p style='font-size: 12px; color: #64748B; margin: 0;'>
                        © {DateTime.Now.Year} ProGroup AI. Hệ thống đăng ký nhóm & đồ án môn học.
                    </p>
                </div>
            </div>";

            using var smtp = new SmtpClient
            {
                Host = smtpServer,
                Port = port,
                EnableSsl = true,
                DeliveryMethod = SmtpDeliveryMethod.Network,
                UseDefaultCredentials = false,
                Credentials = new NetworkCredential(senderEmail, senderPassword)
            };

            using var message = new MailMessage(fromAddress, toAddress)
            {
                Subject = subject,
                Body = htmlContent,
                IsBodyHtml = true
            };

            await smtp.SendMailAsync(message);
            _logger.LogInformation("Đã gửi OTP thành công đến {Email}", toEmail);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi gửi OTP qua Gmail đến {Email}: {Message}", toEmail, ex.Message);
            return false;
        }
    }
}
