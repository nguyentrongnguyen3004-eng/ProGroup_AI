IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260918140711_InitialCreate'
)
BEGIN
    CREATE TABLE [VaiTros] (
        [VaiTroId] int NOT NULL IDENTITY,
        [TenVaiTro] nvarchar(50) NOT NULL,
        [MoTa] nvarchar(255) NULL,
        CONSTRAINT [PK_VaiTros] PRIMARY KEY ([VaiTroId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260918140711_InitialCreate'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260918140711_InitialCreate', N'10.0.12');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260918144442_AddNguoiDung'
)
BEGIN
    CREATE TABLE [NguoiDungs] (
        [NguoiDungId] int NOT NULL IDENTITY,
        [TenDangNhap] nvarchar(50) NOT NULL,
        [MatKhauHash] nvarchar(255) NOT NULL,
        [HoTen] nvarchar(100) NOT NULL,
        [Email] nvarchar(100) NOT NULL,
        [SoDienThoai] nvarchar(20) NULL,
        [AnhDaiDienUrl] nvarchar(500) NULL,
        [TrangThai] bit NOT NULL,
        [YeuCauDoiMatKhau] bit NOT NULL,
        [NgayTao] datetime2 NOT NULL,
        [NgayCapNhat] datetime2 NULL,
        [VaiTroId] int NOT NULL,
        CONSTRAINT [PK_NguoiDungs] PRIMARY KEY ([NguoiDungId]),
        CONSTRAINT [FK_NguoiDungs_VaiTros_VaiTroId] FOREIGN KEY ([VaiTroId]) REFERENCES [VaiTros] ([VaiTroId]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260918144442_AddNguoiDung'
)
BEGIN
    CREATE UNIQUE INDEX [IX_VaiTros_TenVaiTro] ON [VaiTros] ([TenVaiTro]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260918144442_AddNguoiDung'
)
BEGIN
    CREATE UNIQUE INDEX [IX_NguoiDungs_Email] ON [NguoiDungs] ([Email]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260918144442_AddNguoiDung'
)
BEGIN
    CREATE UNIQUE INDEX [IX_NguoiDungs_TenDangNhap] ON [NguoiDungs] ([TenDangNhap]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260918144442_AddNguoiDung'
)
BEGIN
    CREATE INDEX [IX_NguoiDungs_VaiTroId] ON [NguoiDungs] ([VaiTroId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260918144442_AddNguoiDung'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260918144442_AddNguoiDung', N'10.0.12');
END;

COMMIT;
GO

