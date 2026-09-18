using Microsoft.EntityFrameworkCore;
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
}