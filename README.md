# 健身记录（fitness_log）

纯离线 Android 健身训练记录 App。**当天练、当天记**，不提前排计划；日历就是主界面。
无账号、无后端、无网络接口、无付费/激活/订阅逻辑。

> **数据安全提醒**
>
> 全部数据只保存在本机 Isar 数据库。**卸载 App 会清除全部数据**。
> 换手机、刷机、清理存储前，请先「导出备份」，并把 xlsx 转存到手机之外。

---

## 1. 依赖

```yaml
environment:
  sdk: ">=3.9.0 <4.0.0"
  flutter: ">=3.35.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  isar_community: 3.4.1
  isar_community_flutter_libs: 3.4.1

  provider: ^6.1.2
  excel: 4.0.6
  table_calendar: 3.2.1
  fl_chart: ^0.69.2

  path_provider: 2.1.5
  file_picker: 8.1.7
  share_plus: ^10.1.4
  permission_handler: ^11.3.1
  flutter_colorpicker: ^1.1.0

  path: ^1.9.1
  intl: 0.20.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

  isar_community_generator: 3.4.1
  build_runner: 2.11.0
```

说明：

- 数据库使用 **Isar 社区维护版**（Isar 3 API），以兼容较新的 Dart / Android 16 KB page size。
- 本地图片选择使用 `file_picker` 的图片扩展名过滤（系统图片/文件选择器），只读取手机本地图片，不申请相册全量权限。
- 保存到公共下载目录：Android 10+ 使用原生 MediaStore（无需存储权限）；Android 9 及以下使用 `permission_handler` 申请存储权限。原生通道在 `MainActivity.kt` 中实现。
- 没有引入任何网络依赖。

---

## 2. 目录结构

```text
fitness_log/
├─ android/                          # Android 工程、下载目录原生通道、应用图标
├─ assets/app_icon.png               # 1024 图标源文件（启动器已生成各密度）
├─ lib/
│  ├─ main.dart
│  ├─ app.dart                       # MaterialApp + 三主题
│  ├─ core/
│  │  ├─ app_exception.dart
│  │  ├─ date_x.dart                 # 日期解析/格式
│  │  ├─ exercise_group.dart         # 六个动作分组与旧数据自动归类
│  │  ├─ input_formatters.dart
│  │  ├─ theme.dart                  # 默认浅色/暗色/自定义主题、图片背景
│  │  └─ weight.dart                 # 重量单位与显示格式
│  ├─ data/
│  │  ├─ database.dart               # 6 个 Isar Schema
│  │  ├─ fitness_store.dart          # 健身房、预设、动作、组的事务操作
│  │  ├─ theme_store.dart            # 主题持久化、背景图复制
│  │  └─ models/
│  │     ├─ gym.dart
│  │     ├─ exercise_preset.dart
│  │     ├─ training_entry.dart
│  │     ├─ training_set.dart
│  │     ├─ theme_settings.dart
│  │     └─ backup_record.dart
│  ├─ services/
│  │  └─ excel_service.dart          # 9 列导入、4 sheet 导出、重量解析
│  ├─ features/
│  │  ├─ home/home_shell.dart        # 日历 / 记录 / 统计 / 我的
│  │  ├─ calendar/calendar_page.dart
│  │  ├─ training/
│  │  │  ├─ day_training_page.dart   # 当天动作、多行组、即时保存
│  │  │  ├─ exercise_form_dialog.dart
│  │  │  ├─ set_form_dialog.dart
│  │  │  ├─ workout_complete_dialog.dart  # 训练完成白卡总结
│  │  │  └─ widgets/
│  │  │     ├─ body_part_field.dart
│  │  │     └─ exercise_preset_picker.dart  # 按肌群折叠的多选动作选择器
│  │  ├─ history/
│  │  │  ├─ history_page.dart
│  │  │  └─ exercise_progress_page.dart
│  │  ├─ stats/stats_page.dart       # fl_chart 柱状图
│  │  ├─ gyms/
│  │  │  ├─ gym_list_page.dart
│  │  │  ├─ gym_detail_page.dart
│  │  │  └─ gym_dialogs.dart
│  │  ├─ backup/
│  │  │  ├─ import_page.dart
│  │  │  └─ export_page.dart
│  │  ├─ settings/theme_settings_page.dart
│  │  └─ more/more_page.dart
│  └─ widgets/app_widgets.dart
├─ test/
├─ tool/setup_android.ps1
├─ pubspec.yaml
└─ README.md
```

---

## 3. Isar 集合设计

### 3.1 `Gym` 健身房

`id / name / note / createdAt / updatedAt`

### 3.2 `ExercisePreset` 动作预设

`id / gymId / name / group / note / sortOrder / createdAt / updatedAt`

`group` 为固定六类之一：`胸 / 背 / 肩 / 手臂 / 臀腿 / 核心`。
预设保存动作名称、分组和备注，不包含组数、重量、次数；这些仍由训练当天填写。
旧版本没有 `group` 字段，升级后会根据历史动作所属部位和动作名自动补齐。

### 3.3 `TrainingEntry` 动作记录

`id / gymId / date / bodyPart / exerciseName / restText / note / completed / sortOrder / createdAt / updatedAt`

一个动作记录属于某天 + 某健身房，部位为自由文本。

### 3.4 `TrainingSet` 组记录

`id / entryId / gymId / date / groupIndex / groupCount / weightValue / weightUnitIndex / weightRaw / reps / note / createdAt / updatedAt`

- `groupIndex`：动作内从 1 开始的组别序号，用于 Excel 去重。
- `groupCount`：这一行代表几组。
- `weightValue`：数字，可为空。
- `weightUnitIndex`：0=片，1=kg，2=lb；null 表示单位无法识别。
- `weightRaw`：无法解析的原始重量文本，**不参与统计**。
- `reps`：每组次数。

### 3.5 `ThemeSettings` 主题设置（固定 id=1）

`themeModeIndex / cardColorValue / backgroundColorValue / useBackgroundImage / backgroundImagePath / backgroundImageOpacity / backgroundImageBlur / updatedAt`

### 3.6 `BackupRecord` 最近导出

`fileName / filePath / downloadPath / exportedAt / gymCount / presetCount / entryCount / setCount / fileSize`

关系：`Gym 1—N ExercisePreset`，`Gym 1—N TrainingEntry 1—N TrainingSet`。

---

## 4. 核心交互

### 4.1 日历与当天训练

1. 日历点某一天只**选中**该日期，不会自动跳转。
2. 右下角 `+` 记录当前选中日期；也可以点“记录”打开当天训练页。
3. 当天没有记录时，不再显示“点击日期开始记录”的大卡片，只保留一行轻提示。
4. 进入当天训练页后，**最先填写一次“本次训练部位”**；当天所有动作共用，不再每个动作填一遍。
5. 第一次进入先选健身房；也可以先新建健身房。
6. 添加动作：
   - 从该健身房动作预设选择，选择器按肌群折叠，可勾选多个动作；
   - 单个动作仍进入动作表单填写休息/备注，并立即编辑第一组；
   - 多个动作批量加入，**动作顺序与勾选先后一致**，每个动作默认生成 1 组 × 8 次，可随后逐张卡片修改；
   - 当天已经添加过的动作会置灰，避免重复；
   - 或临时新建动作，可勾选加入预设并选择分组。
7. 动作表单只填：动作名称、组间休息、备注/感受。
8. 动作卡片下添加多行组，每行填写：
   - 组数；
   - 重量数字（可空）；
   - 单位分段选择：**片 / kg / lb**；
   - 次数；
   - 备注/感受。
9. 每行可编辑、删除；动作可标记完成、删除。
10. 所有修改即时写入 Isar，无需手动保存。
11. 新增动作会自动生成一行默认组并立即弹出组编辑框。
12. 修改当天训练部位时，会同步更新该日期、该健身房下已经录入的动作。
13. 日历顶部左右箭头：点击翻一个月；**长按可连续翻月，翻页间隔逐渐缩短**，松手停止。
14. 当天所有动作卡片都勾选完成后，右下角按钮变为「结束今日训练」。
15. 点击后先确认是否结束；可取消继续训练，确认后进入训练完成总结。
16. 训练完成弹窗：居中圆角白色卡片，以 `🎉` 为主视觉，展示「训练完成 / 本次容量 / 组数」和一句鼓励文案，底部只有两个文字按钮「留在本页 / 回到日历」，无多余装饰。

### 4.2 动作预设分组

- 预设页按 `胸 / 背 / 肩 / 手臂 / 臀腿 / 核心` 六个折叠面板展示，默认折叠。
- 点击组名展开或收起；组名旁显示该组动作数量，空组也会保留。
- 每个动作行显示**动作名称**和**所属分组**，点击可编辑。
- 新增/编辑预设时可以选择分组；从某个空分组里点“添加”会默认选中该组。
- 旧预设升级时自动分类，归类不合适的可在预设编辑里随时调整。

### 4.3 部位联想

从已录入动作中提取历史部位，在当天训练部位输入框下方以快捷标签展示；也可以输入任意新组合，如“胸，三头”。

### 4.4 记录 / 动作变化

- 记录页按日期、健身房、部位、动作筛选。
- 动作变化页上方为“当日最大重量”折线图，时间跨度可选 **周 / 月 / 年**。
- 不同重量单位不合并；可在有多个单位时切换单位查看。
- 组记录按日期倒序排列，**日期越新越靠上**。
- 同一天、同一个动作的多行组合并到一张卡片。
- 组信息不再显示“第一行 / 第二行”等文字，直接显示“组数 × 重量 × 次数”。

### 4.5 主题

- 默认浅色：背景 `#F7FAFF`，卡片 `#FFFFFF`，主色 `#4285F4`。
- 跟随系统：系统暗色时切换完整暗色主题。
- 自定义：卡片颜色、全局背景、本地图片背景、透明度、模糊度。
- **全局背景分为“纯色背景 / 本地图片”二选一**，互不干扰。
- **本地图片背景优先级最高**：完全不受纯色背景和卡片颜色影响；页面文字固定使用深色遮罩上的白色，卡片内文字仍按卡片底色自动适配。
- 图片模式使用中性深色遮罩保证页面文字可读，不额外叠加蓝色/玻璃滤镜。
- **卡片透明度动态变化**：卡片监听页面滚动位置，靠近 AppBar / 底部导航时背景逐渐变透明，远离边缘恢复不透明；文字保持可读。
- **页面级上下渐变蒙层**：顶部从边缘半透明渐变到透明，底部从导航上方半透明渐变到透明；滚动到边缘的内容柔和淡出。
- 两种效果相互独立：蒙层负责页面整体边缘衔接，卡片只按自身屏幕位置做背景透明度插值。
- 背景图片复制到 App 私有目录，防止原图被删除后失效。

### 4.6 底部导航

- 全宽导航栏，背景透明；
- 背景使用**从顶部透明到底部逐渐加深的线性渐变**；
- 使用 `BackdropFilter` 高斯模糊，导航栏后方页面内容隐约透出，形成毛玻璃效果；
- 页面使用 `extendBody: true`，滚动内容真正经过导航栏后方；
- 导航栏包含 4 个图标，无文字；
- 选中图标带蓝色发光/柔和阴影，未选中为当前页面文字色；
- 保留无障碍 `Semantics` 标签和 Tooltip。

### 4.7 可复用滚动淡出 Widget

- `lib/widgets/edge_fade_list_view.dart` 提供 `EdgeFadeListView`：
  - `topFadeHeight` / `bottomFadeHeight`：渐变高度；
  - `topFadeOpacity` / `bottomFadeOpacity`：边缘最大不透明度；
  - `scrimColor`：自定义蒙层基准色，不传则读取主题页面色；
  - 内部持有 `ScrollController`，通过 `EdgeFadeScope` 暴露给卡片。
- `AppSectionCard` 提供：
  - `edgeFadeRange`：距离边缘多少像素开始衰减；
  - `minCardOpacity`：卡片在边缘的最低背景不透明度。

---

## 5. Excel 导入

### 5.1 表头（固定 9 列）

```text
部位 | 动作 | 组数 | 重量 | 单位 | 次数 | 备注 | 组间歇 | 日期
```

- 表头顺序固定。
- 兼容“单位”被截断为“单”“重量单位”等写法。
- 前 20 行内自动寻找表头。

### 5.2 向下填充

部位、动作、日期可只在首行填写，后续空单元格自动沿用上一行非空值。空行直接跳过。

### 5.3 日期

支持 `yyyy-MM-dd`、`yyyy/M/d`、`yyyy.M.d`、`yyyy年M月d日`、`M/d/yyyy`、Excel 日期单元格/序列号。

### 5.4 重量解析（严格）

- 数值 + 单位可拆分为：`片`、`kg`、`lb`；兼容 `公斤/千克/磅` 别名。
- 单位只能落到这三个枚举。
- 解析失败时：
  - `weightValue = null`
  - `weightRaw = 原始文本`
  - 行仍会导入，并进入“未识别行号提示”
  - 不崩溃、不强行转换。
- 支持 `"35 kg"`、`"6片"`、`"35" + 单位列 "kg"` 等形式。
- 单位列与文本单位冲突时，按未识别处理，保留原文。

### 5.5 去重

去重键：

```text
日期 + 健身房 + 部位 + 动作 + 组别序号
```

默认跳过重复；可选覆盖。导入界面显示成功、跳过、失败、未识别行号、新建动作/组/预设数量。

普通 9 列文件导入到“当前选择的健身房”；App 导出的全量备份会自动恢复所有健身房。

---

## 6. Excel 导出

文件名：`健身记录_备份_yyyyMMdd_HHmmss.xlsx`

4 个工作表：

1. **健身房表**：健身房名称、备注
2. **动作预设表**：健身房名称、动作名称、分组、备注
3. **训练记录表**：固定 9 列表头，与导入完全一致
4. **说明页**：格式说明 + 记录行号→健身房归属映射

动作预设表新增“分组”列；旧版只有“健身房名称 / 动作名称 / 备注”的备份仍可导入，导入时会自动归类。

为什么说明页里要放映射：训练记录表必须保持 9 列，没有健身房列；为了让一个备份文件恢复多个健身房，说明页底部记录了每一行属于哪个健身房。导入时会自动读取，用户不需要手工处理。

备注列：

- `【动作】...` 表示动作备注；
- `【组】...` 表示组备注；
- 导入时自动拆开，保证动作感受和组感受都不丢。

保存位置：

- 下载目录（Android 10+ 通过 MediaStore，Android 9 及以下申请权限）；
- 同时在 App 私有目录保留一份用于系统分享。

最近导出列表支持系统分享、复制路径、删除记录。

---

## 7. 统计

- 时间跨度：**周 / 月 / 年**，可左右滑动翻页，也可点左右箭头翻页。
- 柱状图：蓝色系。
  - 周：当前周 7 天，每天是否训练（0/1）。
  - 月：当前自然月按天显示是否训练。
  - 年：当前自然年按月汇总训练天数。
- 指标卡：当前页训练天数、总组数、总次数。
- **累计容量在点选图中的日期后才显示**，按日计算。
- 年视图先点月份，再点该月训练日，查看当天容量。
- 容量口径：每行组的 `重量 × 组数 × 次数` 求和；**不同动作分开显示**，`片 / kg / lb` 不换算、不合并。
- 未识别/未填写重量不计入。
- 无饼图/扇形图。

---

## 8. 运行步骤

环境：Flutter **3.35.7** / Dart 3.9.2 或兼容更高版本。

```bash
cd fitness_log
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

打包：

```bash
flutter build apk --release
```

产物：`build/app/outputs/flutter-apk/app-release.apk`。

`android/` 已包含。如源码包缺少 Android 工程：

```bash
flutter create --platforms=android --org com.example --project-name fitness_log .
```

或运行 `tool/setup_android.ps1`。

国内构建镜像：

- Gradle wrapper 默认使用腾讯镜像；
- `settings.gradle.kts` / `build.gradle.kts` 优先阿里云 Maven，官方仓库兜底。

---

## 9. 导出 → 换机 → 导入

1. 旧手机：我的 → 导出备份。
2. 点击“系统分享”，把 xlsx 发到聊天工具/网盘/电脑；不要只留在 App 目录。
3. 新手机安装 App。
4. 新手机：我的 → 导入 Excel → 选择任意一个健身房（仅普通 9 列文件使用该选择）。
5. 选择备份文件，处理方式选“覆盖重复”或“跳过重复”。
6. 全量备份会自动恢复所有健身房、预设、动作、组和主题无关数据；查看结果统计。
7. 到日历/记录/统计检查数据。

注意：

- 卸载 App 会删除全部数据；
- 覆盖模式无法撤销，不确定时先导出当前数据作第二份备份；
- 图片背景不会进入 Excel 备份（属于主题设置），换机后需重新选择本地图片；
- 主题颜色也不进入 Excel 备份。

---

## 10. 已构建产物

```text
dist/
├─ 健身记录_v1.6.2.apk       # release 包，可直接侧载
└─ fitness_log_source.zip    # 完整源码（含 Android 工程、生成文件、图标）
```

APK 信息：

- 版本：1.6.2（versionCode 9）
- 包名：`com.example.fitness_log`
- 应用名：健身记录
- 签名：debug 签名（个人自用；发布前请换签名）
- 57.1 MB（59,925,993 bytes）

> 本地图片选择使用 `file_picker` 的图片扩展名过滤，不额外引入 image_picker，避免不同 Android 版本相册权限与插件构建差异；只读取用户选择的本地图片，效果一致。

---

## 11. 已验证

- `flutter analyze`：0 issues
- `flutter test`：28 个测试全部通过
- `flutter build apk --release`：通过
- APK 包含 arm64-v8a / armeabi-v7a / x86_64 的 libisar.so
- 模拟器安装启动、创建健身房、Isar 即时写入、系统暗色主题、导出到公共下载目录均已验证
- 已验证 v1.5 旧数据库升级到带 `group` 字段后，健身房、69 个预设和训练记录均保留
- 已验证预设页折叠面板、添加动作选择器按肌群折叠、多选批量添加、Excel 旧/新预设表导入导出
- 已验证多选动作按点击先后加入、全部完成后结束今日任务、训练完成白卡弹窗与容量/组数统计（widget test + 模拟器）
- 已验证：点日期只选中、右下角 `+` 记录所选日期、先填部位再添加动作、动作变化折线图、统计按日容量、周/月/年视图
- 已验证页面边缘蒙层、卡片靠近顶部时降低背景不透明度、远离边缘恢复不透明（widget test）
- 应用名：健身记录；启动器图标：用户提供的图 5

---

## 12. 边界

- 不做提前计划/未来计划。
- 不支持 iOS。
- 重量单位只能片/kg/lb。
- 不预设部位枚举。
- 卸载 App 数据不可恢复，必须 Excel 备份。
- 全量备份的多健身房归属依赖说明页的映射表，请勿删除说明页。
