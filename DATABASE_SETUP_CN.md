# SafeJalan 双数据库设置

## 1. Local Database：SQLite

SQLite 已经内置，不需要另外注册或配置。

- 数据库文件：`safejalan.db`
- 数据表：`Reports`
- Service：`lib/services/database_service.dart`
- 用途：离线储存、读取、更新、删除报告，以及保存同步状态。

每条本地记录包含：

- `remoteId`：对应 Supabase UUID
- `syncStatus`：`pending` 或 `synced`
- `isDeleted`：离线删除用的 tombstone
- `updatedAt`：最后修改时间

## 2. Remote Database：Supabase

1. 在 Supabase 建立 Project。
2. 打开 **SQL Editor**。
3. 执行 `supabase/schema.sql` 的全部 SQL。
4. 在 Supabase 的 **Connect / API Keys** 取得：
   - Project URL
   - Publishable Key
5. 复制配置模板：

```powershell
Copy-Item supabase_config.example.json supabase_config.json
```

6. 把 URL 和 Publishable Key 填入 `supabase_config.json`。

不要使用 `service_role` 或 secret key；Flutter App 只能使用 Publishable Key。

## 3. 运行

```powershell
flutter pub get
flutter run --dart-define-from-file=supabase_config.json
```

Android Studio：打开 **Run > Edit Configurations**，在 **Additional run args** 填入：

```text
--dart-define-from-file=supabase_config.json
```

## 4. 同步规则

- 新增、修改、删除首先写进 SQLite。
- Supabase 已配置且网络正常时，App 自动同步。
- 网络失败时，资料保留为 `pending`，下次启动或按 Sync 再重试。
- Supabase 的远端资料会下载回 SQLite，地图和管理员页面都从本地缓存读取。
- 没有配置 Supabase 时，App 仍可以正常使用 SQLite。

当前远端同步范围是道路报告 `road_reports`。登录画面仍是课堂 prototype；正式发布前应改用 Supabase Auth，并收紧 `schema.sql` 的 RLS policies。
