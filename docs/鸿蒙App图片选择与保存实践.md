# 鸿蒙 App 中选择图片与保存图片

本文说明常见做法：**系统相册选择**使用 `PhotoViewPicker`，**写入系统图库**使用 `PhotoAccessHelper.createAsset` 配合 `ImagePacker.packToFile`；若需对像素做滤镜、裁剪等处理，需先把 URI 解码为 `PixelMap`。

---

## 1. 涉及能力与子系统

| 能力 | 导入 |
|------|------|
| 相册选择 | `@kit.MediaLibraryKit` → `photoAccessHelper` |
| 像素图 / 编码 | `@kit.ImageKit` → `image` |
| 打开 URI 对应的文件句柄 | `@kit.CoreFileKit` → `fileIo`（示例中常用别名 `fs`） |
| 上下文（创建媒体资源时需要） | `@kit.AbilityKit` → `common.UIAbilityContext` |

合规场景下保存到相册时，可配合 **`SaveButton`**（`SaveDescription.SAVE_IMAGE`），在用户授权成功回调里再执行实际保存逻辑。

---

## 2. 选择图片：核心逻辑

1. 配置 `PhotoSelectOptions`：限制为图片、张数（如单张）。
2. `PhotoViewPicker.select()` 调起系统图库，读取 `result.photoUris`。
3. 若仅用于 **`Image(uri)` 展示**，可直接把 URI 绑到 `Image` 组件。
4. 若需 **`PixelMap` 做算法处理**（滤镜等），需 **`fs.openSync(uri, READ_ONLY)`**，再用 **`image.createImageSource(fd)` → `createPixelMap(...)`**，用完 **`release()` ImageSource**、视情况 **`release()` PixelMap**，并 **`closeSync` 文件**。

### 示例：调起图库并取首张 URI

```typescript
import { photoAccessHelper } from '@kit.MediaLibraryKit';

private async pickFromAlbum(): Promise<void> {
  try {
    const options = new photoAccessHelper.PhotoSelectOptions();
    options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    options.maxSelectNumber = 1;
    const picker = new photoAccessHelper.PhotoViewPicker();
    const result = await picker.select(options);
    if (result.photoUris !== undefined && result.photoUris.length > 0) {
      const uri = result.photoUris[0];
      // 展示：Image(uri)；或再解码为 PixelMap 做处理
    }
  } catch (_) {
    // 用户取消或异常
  }
}
```

### 示例：相册 URI → PixelMap（与系统返回格式一致）

```typescript
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';

private async uriToPixelMap(uri: string): Promise<image.PixelMap | null> {
  let resFile: fs.File | undefined = undefined;
  try {
    resFile = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    const src = image.createImageSource(resFile.fd);
    try {
      return await src.createPixelMap({ editable: true });
    } finally {
      src.release();
    }
  } catch (_) {
    return null;
  } finally {
    if (resFile !== undefined) {
      try {
        fs.closeSync(resFile);
      } catch (_) {
      }
    }
  }
}
```

---

## 3. 保存图片到系统相册：核心逻辑

1. 取 **`UIAbilityContext`**（例如 `getContext(this) as common.UIAbilityContext`）。
2. **`photoAccessHelper.getPhotoAccessHelper(ctx)`** 得到 helper。
3. **`createAsset(PhotoType.IMAGE, 'jpg')`** 在相册中创建新资源，得到可写 **`photoUri`**。
4. **`fs.openSync(photoUri, WRITE_ONLY)`** 拿到文件描述符。
5. **`image.createImagePacker()`**，用 **`packToFile(pixelMap, fd, { format: 'image/jpeg', quality: 92 })`** 写入。
6. **`packer.release()`**，**关闭文件**；若 PixelMap 为本次生成且不再使用，调用 **`pixelMap.release()`**。

### 示例：保存已有 PixelMap 到相册

```typescript
import { common } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';

private async savePixelMapToAlbum(ctx: common.UIAbilityContext, pm: image.PixelMap): Promise<void> {
  let assetFile: fs.File | undefined = undefined;
  try {
    const ph = photoAccessHelper.getPhotoAccessHelper(ctx);
    const photoUri: string = await ph.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
    assetFile = fs.openSync(photoUri, fs.OpenMode.WRITE_ONLY);
    const packer = image.createImagePacker();
    const packOpts: image.PackingOption = { format: 'image/jpeg', quality: 92 };
    try {
      await packer.packToFile(pm, assetFile.fd, packOpts);
    } finally {
      packer.release();
    }
  } finally {
    if (assetFile !== undefined) {
      try {
        fs.closeSync(assetFile);
      } catch (_) {
      }
    }
  }
}
```

---

## 4. 合成界面再保存：组件截图 → PixelMap

当最终画面是 **多层 `Stack` 叠图**（例如底图、用户图、前景 PNG）时，保存不一定需要自己离屏绘制：可对**带 `.id('xxx')` 的根容器**调用 **`getUIContext().getComponentSnapshot().get('xxx')`** 得到 **`PixelMap`**，再按上一节 **`packToFile`** 写入 `createAsset` 创建的文件。

要点：

- 被截图的节点需设置 **稳定 id**（例如 `compositeRoot`）。
- 截图得到的 **`PixelMap` 使用完后应 `release()`**，避免泄漏。

---

## 5. 交互与资源管理建议

- **防重复点击**：保存耗时期间用状态位锁住或展示 Loading。
- **PixelMap 生命周期**：切换图片或退出页面前 **`release()`** 不再使用的 `PixelMap`（同时持有原图与处理结果时分别管理）。
- **保存入口**：使用 **`SaveButton`** 时，仅在 **`SaveButtonOnClickResult.SUCCESS`** 时执行写入，符合系统对「保存到相册」的管控要求。

---

## 6. 权限与文档

- 相册访问策略、所需权限随 **API 版本** 与使用方式（系统图库返回 URI、`createAsset` 安全控件等）而异。实现前请查阅 **HarmonyOS 官方文档** 中 **MediaLibraryKit**、**SaveButton / 安全控件** 及当前 Target SDK 下的 **授权说明**，按需配置 `module.json5` 等声明。
- 以上实现不需要申请这些权限： `ohos.permission.WRITE_IMAGEVIDEO`、`ohos.permission.READ_IMAGEVIDEO`
