using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using ProGroup_AI.API.Models;

namespace ProGroup_AI.API.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<VaiTro> VaiTros { get; set; }
    public DbSet<Khoa> Khoas { get; set; }
    public DbSet<NguoiDung> NguoiDungs { get; set; }
    public DbSet<HocKy> HocKys { get; set; }
    public DbSet<SinhVien> SinhViens { get; set; }
    public DbSet<GiangVien> GiangViens { get; set; }
    public DbSet<HocPhan> HocPhans { get; set; }
    public DbSet<LopHocPhan> LopHocPhans { get; set; }
    public DbSet<PhanCongGiangVien> PhanCongGiangViens { get; set; }
    public DbSet<SinhVienLopHocPhan> SinhVienLopHocPhans { get; set; }
    public DbSet<DotDangKyDoAn> DotDangKyDoAns { get; set; }
    public DbSet<NhomDoAn> NhomDoAns { get; set; }
    public DbSet<ThanhVienNhom> ThanhVienNhoms { get; set; }
    public DbSet<DeTaiDoAn> DeTaiDoAns { get; set; }
    public DbSet<DangKyDeTai> DangKyDeTais { get; set; }
    public DbSet<PasswordResetOtp> PasswordResetOtps { get; set; }
    public DbSet<AIRequest> AIRequests { get; set; }
    public DbSet<DotImport> DotImports { get; set; }
    public DbSet<LoiImport> LoiImports { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        ConfigureSqlSchema(modelBuilder);

        // =========================
        // VaiTro
        // =========================

        modelBuilder.Entity<VaiTro>()
            .HasIndex(x => x.MaVaiTro)
            .IsUnique();

        // =========================
        // Khoa
        // =========================

        modelBuilder.Entity<Khoa>()
            .HasIndex(x => x.MaKhoa)
            .IsUnique();

        // =========================
        // NguoiDung
        // =========================

        modelBuilder.Entity<NguoiDung>()
            .HasIndex(x => x.TenDangNhap)
            .IsUnique();

        modelBuilder.Entity<NguoiDung>()
            .HasIndex(x => x.Email)
            .IsUnique();

        modelBuilder.Entity<NguoiDung>()
            .HasOne(x => x.VaiTro)
            .WithMany()
            .HasForeignKey(x => x.VaiTroId)
            .OnDelete(DeleteBehavior.Restrict);

        // =========================
        // SinhVien
        // =========================

        modelBuilder.Entity<SinhVien>()
            .HasIndex(x => x.NguoiDungId)
            .IsUnique();

        modelBuilder.Entity<SinhVien>()
            .HasIndex(x => x.MSSV)
            .IsUnique();

        modelBuilder.Entity<SinhVien>()
            .HasOne(x => x.NguoiDung)
            .WithOne(x => x.SinhVien)
            .HasForeignKey<SinhVien>(x => x.NguoiDungId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<SinhVien>()
            .HasOne(x => x.Khoa)
            .WithMany(x => x.SinhViens)
            .HasForeignKey(x => x.KhoaId)
            .OnDelete(DeleteBehavior.Restrict);

        // =========================
        // GiangVien
        // =========================

        modelBuilder.Entity<GiangVien>()
            .HasIndex(x => x.NguoiDungId)
            .IsUnique();

        modelBuilder.Entity<GiangVien>()
            .HasIndex(x => x.MaGiangVien)
            .IsUnique();

        modelBuilder.Entity<GiangVien>()
            .HasOne(x => x.NguoiDung)
            .WithOne(x => x.GiangVien)
            .HasForeignKey<GiangVien>(x => x.NguoiDungId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<GiangVien>()
            .HasOne(x => x.Khoa)
            .WithMany(x => x.GiangViens)
            .HasForeignKey(x => x.KhoaId)
            .OnDelete(DeleteBehavior.Restrict);

        // =========================
        // HocKy
        // =========================

        modelBuilder.Entity<HocKy>()
            .HasIndex(x => new
            {
                x.TenHocKy,
                x.NamHoc
            })
            .IsUnique();

        // =========================
        // HocPhan
        // =========================

        modelBuilder.Entity<HocPhan>()
            .HasIndex(x => x.MaHocPhan)
            .IsUnique();

        modelBuilder.Entity<HocPhan>()
            .HasOne(x => x.Khoa)
            .WithMany(x => x.HocPhans)
            .HasForeignKey(x => x.KhoaId)
            .OnDelete(DeleteBehavior.Restrict);

        // =========================
        // LopHocPhan
        // =========================

        modelBuilder.Entity<LopHocPhan>()
            .HasIndex(x => new
            {
                x.MaLopHocPhan,
                x.HocKyId
            })
            .IsUnique();

        modelBuilder.Entity<LopHocPhan>()
            .HasOne(x => x.HocPhan)
            .WithMany(x => x.LopHocPhans)
            .HasForeignKey(x => x.HocPhanId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<LopHocPhan>()
            .HasOne(x => x.HocKy)
            .WithMany(x => x.LopHocPhans)
            .HasForeignKey(x => x.HocKyId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<LopHocPhan>()
            .HasOne(x => x.Khoa)
            .WithMany(x => x.LopHocPhans)
            .HasForeignKey(x => x.KhoaId)
            .OnDelete(DeleteBehavior.Restrict);

        // =========================
        // PhanCongGiangVien
        // =========================

        modelBuilder.Entity<PhanCongGiangVien>()
            .HasIndex(x => new
            {
                x.LopHocPhanId,
                x.GiangVienId
            })
            .IsUnique();

        modelBuilder.Entity<PhanCongGiangVien>()
            .HasOne(x => x.LopHocPhan)
            .WithMany(x => x.PhanCongGiangViens)
            .HasForeignKey(x => x.LopHocPhanId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<PhanCongGiangVien>()
            .HasOne(x => x.GiangVien)
            .WithMany(x => x.PhanCongGiangViens)
            .HasForeignKey(x => x.GiangVienId)
            .OnDelete(DeleteBehavior.Restrict);

        // =========================
        // SinhVienLopHocPhan
        // =========================

        modelBuilder.Entity<SinhVienLopHocPhan>()
            .HasIndex(x => new
            {
                x.SinhVienId,
                x.LopHocPhanId
            })
            .IsUnique();

        modelBuilder.Entity<SinhVienLopHocPhan>()
            .HasOne(x => x.SinhVien)
            .WithMany(x => x.SinhVienLopHocPhans)
            .HasForeignKey(x => x.SinhVienId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<SinhVienLopHocPhan>()
            .HasOne(x => x.LopHocPhan)
            .WithMany(x => x.SinhVienLopHocPhans)
            .HasForeignKey(x => x.LopHocPhanId)
            .OnDelete(DeleteBehavior.Cascade);

        // =========================
        // DotDangKyDoAn
        // =========================

        modelBuilder.Entity<DotDangKyDoAn>()
            .HasOne(x => x.LopHocPhan)
            .WithMany(x => x.DotDangKyDoAns)
            .HasForeignKey(x => x.LopHocPhanId)
            .OnDelete(DeleteBehavior.Cascade);

        // =========================
        // NhomDoAn
        // =========================

        modelBuilder.Entity<NhomDoAn>()
            .HasIndex(x => new
            {
                x.DotDangKyId,
                x.TenNhom
            })
            .IsUnique();

        modelBuilder.Entity<NhomDoAn>()
            .HasOne(x => x.DotDangKy)
            .WithMany(x => x.NhomDoAns)
            .HasForeignKey(x => x.DotDangKyId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<NhomDoAn>()
            .HasOne(x => x.TruongNhom)
            .WithMany(x => x.NhomDoAns)
            .HasForeignKey(x => x.TruongNhomId)
            .OnDelete(DeleteBehavior.Restrict);

        // =========================
        // ThanhVienNhom
        // =========================

        modelBuilder.Entity<ThanhVienNhom>()
            .HasIndex(x => new
            {
                x.NhomId,
                x.SinhVienId
            })
            .IsUnique();

        modelBuilder.Entity<ThanhVienNhom>()
            .HasOne(x => x.Nhom)
            .WithMany(x => x.ThanhVienNhoms)
            .HasForeignKey(x => x.NhomId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ThanhVienNhom>()
            .HasOne(x => x.SinhVien)
            .WithMany(x => x.ThanhVienNhoms)
            .HasForeignKey(x => x.SinhVienId)
            .OnDelete(DeleteBehavior.Restrict);

        // =========================
        // DeTaiDoAn
        // =========================

        modelBuilder.Entity<DeTaiDoAn>()
            .HasOne(x => x.DotDangKy)
            .WithMany(x => x.DeTaiDoAns)
            .HasForeignKey(x => x.DotDangKyId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<DeTaiDoAn>()
            .HasOne(x => x.GiangVien)
            .WithMany(x => x.DeTaiDoAns)
            .HasForeignKey(x => x.GiangVienId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<DeTaiDoAn>()
            .HasOne(x => x.SinhVienDeXuat)
            .WithMany(x => x.DeTaiDeXuat)
            .HasForeignKey(x => x.SinhVienDeXuatId)
            .OnDelete(DeleteBehavior.Restrict);

        // =========================
        // DangKyDeTai
        // =========================

        modelBuilder.Entity<DangKyDeTai>()
            .HasIndex(x => new
            {
                x.NhomId,
                x.DeTaiId
            })
            .IsUnique();

        modelBuilder.Entity<DangKyDeTai>()
            .HasOne(x => x.Nhom)
            .WithMany(x => x.DangKyDeTais)
            .HasForeignKey(x => x.NhomId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<DangKyDeTai>()
            .HasOne(x => x.DeTai)
            .WithMany(x => x.DangKyDeTais)
            .HasForeignKey(x => x.DeTaiId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<DangKyDeTai>()
            .HasOne(x => x.GiangVienDuyet)
            .WithMany(x => x.DangKyDeTaisDuyet)
            .HasForeignKey(x => x.GiangVienDuyetId)
            .OnDelete(DeleteBehavior.Restrict);

        // =========================
        // PasswordResetOtp
        // =========================

        modelBuilder.Entity<PasswordResetOtp>()
            .HasOne(x => x.NguoiDung)
            .WithMany(x => x.PasswordResetOtps)
            .HasForeignKey(x => x.NguoiDungId)
            .OnDelete(DeleteBehavior.Cascade);

        // =========================
        // AIRequest
        // =========================

        modelBuilder.Entity<AIRequest>()
            .HasOne(x => x.NguoiDung)
            .WithMany(x => x.AIRequests)
            .HasForeignKey(x => x.NguoiDungId)
            .OnDelete(DeleteBehavior.Cascade);

        // =========================
        // DotImport
        // =========================

        modelBuilder.Entity<DotImport>()
            .HasOne(x => x.NguoiImport)
            .WithMany(x => x.DotImports)
            .HasForeignKey(x => x.NguoiImportId)
            .OnDelete(DeleteBehavior.Restrict);

        // =========================
        // LoiImport
        // =========================

        modelBuilder.Entity<LoiImport>()
            .HasOne(x => x.DotImport)
            .WithMany(x => x.LoiImports)
            .HasForeignKey(x => x.DotImportId)
            .OnDelete(DeleteBehavior.Cascade);
    }

    private static void ConfigureSqlSchema(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<VaiTro>(entity =>
        {
            entity.ToTable("VaiTros");
            ConfigureVarchar(entity.Property(x => x.MaVaiTro), 50).IsRequired();
            ConfigureNvarchar(entity.Property(x => x.TenVaiTro), 100).IsRequired();
            ConfigureNvarchar(entity.Property(x => x.MoTa), 255);
        });

        modelBuilder.Entity<Khoa>(entity =>
        {
            entity.ToTable("Khoas");
            ConfigureVarchar(entity.Property(x => x.MaKhoa), 20).IsRequired();
            ConfigureNvarchar(entity.Property(x => x.TenKhoa), 200).IsRequired();
            entity.Property(x => x.TrangThai).HasDefaultValue(true);
            entity.Property(x => x.CreatedAt).HasDefaultValueSql("SYSDATETIME()");
        });

        modelBuilder.Entity<NguoiDung>(entity =>
        {
            entity.ToTable("NguoiDungs");
            ConfigureVarchar(entity.Property(x => x.TenDangNhap), 100).IsRequired();
            ConfigureNvarchar(entity.Property(x => x.MatKhauHash), 500).IsRequired();
            ConfigureVarchar(entity.Property(x => x.Email), 150).IsRequired();
            ConfigureNvarchar(entity.Property(x => x.HoTen), 200).IsRequired();
            ConfigureVarchar(entity.Property(x => x.SoDienThoai), 20);
            ConfigureNvarchar(entity.Property(x => x.AvatarUrl), 500);
            entity.Property(x => x.TrangThai).HasDefaultValue(true);
            entity.Property(x => x.YeuCauDoiMatKhau).HasDefaultValue(false);
            entity.Property(x => x.CreatedAt).HasDefaultValueSql("SYSDATETIME()");
        });

        modelBuilder.Entity<HocKy>(entity =>
        {
            entity.ToTable("HocKys", table =>
                table.HasCheckConstraint("CK_HocKys_Ngay", "NgayKetThuc > NgayBatDau"));
            ConfigureNvarchar(entity.Property(x => x.TenHocKy), 100).IsRequired();
            ConfigureVarchar(entity.Property(x => x.NamHoc), 20).IsRequired();
            entity.Property(x => x.NgayBatDau).HasColumnType("date");
            entity.Property(x => x.NgayKetThuc).HasColumnType("date");
            entity.Property(x => x.TrangThai).HasDefaultValue(true);
            entity.Property(x => x.CreatedAt).HasDefaultValueSql("SYSDATETIME()");
        });

        modelBuilder.Entity<SinhVien>(entity =>
        {
            entity.ToTable("SinhViens");
            ConfigureVarchar(entity.Property(x => x.MSSV), 30).IsRequired();
            entity.Property(x => x.NgaySinh).HasColumnType("date");
            ConfigureNvarchar(entity.Property(x => x.GioiTinh), 10);
            entity.Property(x => x.CreatedAt).HasDefaultValueSql("SYSDATETIME()");
        });

        modelBuilder.Entity<GiangVien>(entity =>
        {
            entity.ToTable("GiangViens");
            ConfigureVarchar(entity.Property(x => x.MaGiangVien), 30).IsRequired();
            ConfigureNvarchar(entity.Property(x => x.HocVi), 100);
            ConfigureNvarchar(entity.Property(x => x.ChuyenMon), 200);
            entity.Property(x => x.CreatedAt).HasDefaultValueSql("SYSDATETIME()");
        });

        modelBuilder.Entity<HocPhan>(entity =>
        {
            entity.ToTable("HocPhans", table =>
                table.HasCheckConstraint("CK_HocPhans_SoTinChi", "SoTinChi > 0"));
            ConfigureVarchar(entity.Property(x => x.MaHocPhan), 30).IsRequired();
            ConfigureNvarchar(entity.Property(x => x.TenHocPhan), 300).IsRequired();
            ConfigureNvarchar(entity.Property(x => x.MoTa), 1000);
            entity.Property(x => x.TrangThai).HasDefaultValue(true);
            entity.Property(x => x.CreatedAt).HasDefaultValueSql("SYSDATETIME()");
        });

        modelBuilder.Entity<LopHocPhan>(entity =>
        {
            entity.ToTable("LopHocPhans", table =>
                table.HasCheckConstraint(
                    "CK_LopHocPhans_SoLuong",
                    "SoLuongToiDa IS NULL OR SoLuongToiDa > 0"));
            ConfigureVarchar(entity.Property(x => x.MaLopHocPhan), 50).IsRequired();
            ConfigureNvarchar(entity.Property(x => x.TenLopHocPhan), 300);
            entity.Property(x => x.TrangThai).HasDefaultValue(true);
            entity.Property(x => x.CreatedAt).HasDefaultValueSql("SYSDATETIME()");
        });

        modelBuilder.Entity<PhanCongGiangVien>(entity =>
        {
            entity.ToTable("PhanCongGiangViens");
            ConfigureNvarchar(entity.Property(x => x.VaiTro), 100)
                .HasDefaultValue("Giảng viên phụ trách");
            entity.Property(x => x.NgayPhanCong).HasDefaultValueSql("SYSDATETIME()");
            entity.Property(x => x.TrangThai).HasDefaultValue(true);
        });

        modelBuilder.Entity<SinhVienLopHocPhan>(entity =>
        {
            entity.ToTable("SinhVienLopHocPhans");
            entity.Property(x => x.NgayThamGia).HasDefaultValueSql("SYSDATETIME()");
            entity.Property(x => x.TrangThai).HasDefaultValue(true);
        });

        modelBuilder.Entity<DotDangKyDoAn>(entity =>
        {
            entity.ToTable("DotDangKyDoAns", table =>
            {
                table.HasCheckConstraint(
                    "CK_DotDangKyDoAns_Ngay",
                    "NgayKetThuc > NgayBatDau");
                table.HasCheckConstraint(
                    "CK_DotDangKyDoAns_ThanhVien",
                    "MinMembers > 0 AND MaxMembers >= MinMembers");
                table.HasCheckConstraint(
                    "CK_DotDangKyDoAns_TrangThai",
                    "TrangThai IN (N'Chưa mở', N'Đang mở', N'Đã đóng')");
            });
            ConfigureNvarchar(entity.Property(x => x.TenDot), 200).IsRequired();
            ConfigureNvarchar(entity.Property(x => x.TrangThai), 50)
                .HasDefaultValue("Chưa mở");
            entity.Property(x => x.CreatedAt).HasDefaultValueSql("SYSDATETIME()");
        });

        modelBuilder.Entity<NhomDoAn>(entity =>
        {
            entity.ToTable("NhomDoAns", table =>
                table.HasCheckConstraint(
                    "CK_NhomDoAns_TrangThai",
                    "TrangThai IN (N'Đang hoạt động', N'Đã khóa', N'Đã hủy')"));
            ConfigureNvarchar(entity.Property(x => x.TenNhom), 200).IsRequired();
            ConfigureNvarchar(entity.Property(x => x.TrangThai), 50)
                .HasDefaultValue("Đang hoạt động");
            entity.Property(x => x.CreatedAt).HasDefaultValueSql("SYSDATETIME()");
        });

        modelBuilder.Entity<ThanhVienNhom>(entity =>
        {
            entity.ToTable("ThanhVienNhoms", table =>
            {
                table.HasCheckConstraint(
                    "CK_ThanhVienNhoms_VaiTro",
                    "VaiTro IN (N'Trưởng nhóm', N'Thành viên')");
                table.HasCheckConstraint(
                    "CK_ThanhVienNhoms_TrangThai",
                    "TrangThai IN (N'Chờ tham gia', N'Đã tham gia', N'Đã rời nhóm')");
            });
            ConfigureNvarchar(entity.Property(x => x.VaiTro), 50)
                .HasDefaultValue("Thành viên");
            entity.Property(x => x.NgayThamGia).HasDefaultValueSql("SYSDATETIME()");
            ConfigureNvarchar(entity.Property(x => x.TrangThai), 50)
                .HasDefaultValue("Đã tham gia");
        });

        modelBuilder.Entity<DeTaiDoAn>(entity =>
        {
            entity.ToTable("DeTaiDoAns", table =>
            {
                table.HasCheckConstraint(
                    "CK_DeTaiDoAns_Nguon",
                    "NguonDeTai IN (N'Giảng viên', N'Sinh viên đề xuất')");
                table.HasCheckConstraint(
                    "CK_DeTaiDoAns_TrangThai",
                    "TrangThai IN (N'Chưa sử dụng', N'Đã đăng ký', N'Đã khóa', N'Đã hủy')");
                table.HasCheckConstraint(
                    "CK_DeTaiDoAns_TrangThaiDuyet",
                    "TrangThaiDuyet IN (N'Chờ duyệt', N'Đã duyệt', N'Từ chối')");
            });
            ConfigureNvarchar(entity.Property(x => x.TenDeTai), 500).IsRequired();
            ConfigureNvarcharMax(entity.Property(x => x.MoTa));
            ConfigureNvarcharMax(entity.Property(x => x.MucTieu));
            ConfigureNvarcharMax(entity.Property(x => x.PhamVi));
            ConfigureNvarchar(entity.Property(x => x.CongNgheDuKien), 1000);
            ConfigureNvarchar(entity.Property(x => x.NguonDeTai), 50).IsRequired();
            ConfigureNvarchar(entity.Property(x => x.TrangThai), 50)
                .HasDefaultValue("Chưa sử dụng");
            ConfigureNvarchar(entity.Property(x => x.TrangThaiDuyet), 50)
                .HasDefaultValue("Chờ duyệt");
            ConfigureNvarchar(entity.Property(x => x.LyDoTuChoi), 1000);
            entity.Property(x => x.CreatedAt).HasDefaultValueSql("SYSDATETIME()");
        });

        modelBuilder.Entity<DangKyDeTai>(entity =>
        {
            entity.ToTable("DangKyDeTais", table =>
            {
                table.HasCheckConstraint(
                    "CK_DangKyDeTais_TrangThai",
                    "TrangThai IN (N'Chờ duyệt', N'Đã duyệt', N'Từ chối', N'Đã hủy')");
                table.HasCheckConstraint(
                    "CK_DangKyDeTais_NgayDuyet",
                    "(TrangThai = N'Chờ duyệt' AND NgayDuyet IS NULL) OR " +
                    "(TrangThai IN (N'Đã duyệt', N'Từ chối') AND NgayDuyet IS NOT NULL) OR " +
                    "(TrangThai = N'Đã hủy')");
            });
            ConfigureNvarchar(entity.Property(x => x.TrangThai), 50)
                .HasDefaultValue("Chờ duyệt");
            ConfigureNvarchar(entity.Property(x => x.GhiChu), 1000);
            entity.Property(x => x.NgayDangKy).HasDefaultValueSql("SYSDATETIME()");
        });

        modelBuilder.Entity<PasswordResetOtp>(entity =>
        {
            entity.ToTable("PasswordResetOtps", table =>
            {
                table.HasCheckConstraint("CK_PasswordResetOtps_SoLanThu", "SoLanThu >= 0");
                table.HasCheckConstraint(
                    "CK_PasswordResetOtps_ExpiredAt",
                    "ExpiredAt > CreatedAt");
            });
            ConfigureNvarchar(entity.Property(x => x.OtpCodeHash), 500).IsRequired();
            entity.Property(x => x.SoLanThu).HasDefaultValue(0);
            entity.Property(x => x.IsUsed).HasDefaultValue(false);
            entity.Property(x => x.CreatedAt).HasDefaultValueSql("SYSDATETIME()");
        });

        modelBuilder.Entity<AIRequest>(entity =>
        {
            entity.ToTable("AIRequests", table =>
                table.HasCheckConstraint(
                    "CK_AIRequests_TrangThai",
                    "TrangThai IN (N'Đang xử lý', N'Thành công', N'Thất bại')"));
            ConfigureNvarchar(entity.Property(x => x.ChucNangAI), 100).IsRequired();
            ConfigureNvarcharMax(entity.Property(x => x.Prompt)).IsRequired();
            ConfigureNvarcharMax(entity.Property(x => x.Response));
            ConfigureNvarchar(entity.Property(x => x.TrangThai), 50)
                .HasDefaultValue("Thành công");
            entity.Property(x => x.CreatedAt).HasDefaultValueSql("SYSDATETIME()");
        });

        modelBuilder.Entity<DotImport>(entity =>
        {
            entity.ToTable("DotImports", table =>
            {
                table.HasCheckConstraint(
                    "CK_DotImports_SoDong",
                    "TongSoDong >= 0 AND SoDongThanhCong >= 0 AND SoDongLoi >= 0 AND " +
                    "SoDongThanhCong + SoDongLoi <= TongSoDong");
                table.HasCheckConstraint(
                    "CK_DotImports_TrangThai",
                    "TrangThai IN (N'Đang xử lý', N'Hoàn thành', N'Hoàn thành có lỗi', N'Thất bại')");
            });
            ConfigureNvarchar(entity.Property(x => x.LoaiDuLieu), 100).IsRequired();
            ConfigureNvarchar(entity.Property(x => x.TenFile), 500).IsRequired();
            entity.Property(x => x.TongSoDong).HasDefaultValue(0);
            entity.Property(x => x.SoDongThanhCong).HasDefaultValue(0);
            entity.Property(x => x.SoDongLoi).HasDefaultValue(0);
            ConfigureNvarchar(entity.Property(x => x.TrangThai), 50)
                .HasDefaultValue("Đang xử lý");
            entity.Property(x => x.CreatedAt).HasDefaultValueSql("SYSDATETIME()");
        });

        modelBuilder.Entity<LoiImport>(entity =>
        {
            entity.ToTable("LoiImports", table =>
                table.HasCheckConstraint("CK_LoiImports_SoDong", "SoDong > 0"));
            ConfigureNvarchar(entity.Property(x => x.TenCot), 200);
            ConfigureNvarchar(entity.Property(x => x.NoiDungLoi), 1000).IsRequired();
            entity.Property(x => x.CreatedAt).HasDefaultValueSql("SYSDATETIME()");
        });

        modelBuilder.Entity<DeTaiDoAn>()
            .HasIndex(x => x.TrangThaiDuyet);
    }

    private static PropertyBuilder<TProperty> ConfigureVarchar<TProperty>(
        PropertyBuilder<TProperty> property,
        int maxLength)
    {
        return property
            .HasMaxLength(maxLength)
            .IsUnicode(false)
            .HasColumnType($"varchar({maxLength})");
    }

    private static PropertyBuilder<TProperty> ConfigureNvarchar<TProperty>(
        PropertyBuilder<TProperty> property,
        int maxLength)
    {
        return property
            .HasMaxLength(maxLength)
            .IsUnicode()
            .HasColumnType($"nvarchar({maxLength})");
    }

    private static PropertyBuilder<TProperty> ConfigureNvarcharMax<TProperty>(
        PropertyBuilder<TProperty> property)
    {
        return property
            .IsUnicode()
            .HasColumnType("nvarchar(max)");
    }
}
