# Resource generator

## Tính năng

Generate một resource class từ thư mục assets, tương tự với class `R` trên Android.

## Thiết lập

Generator hỗ trợ generate thư mục assets thông thường và thư mục assets phân chia theo các flavor.<br>

### Không có flavor

Cấu trúc thư mục yêu cầu để có thể sử dụng được generator:<br>

```
<your-project>
├── <assets-folder>/
   ├── images/ (for images)
   ├── vectors/ (for vector images or svg)
   ├── translations/ (for localizations)
   ├── fonts/ (for fonts)
   ├── scripts/ (for shell scripts)
   ├── configs/ (for JSON configurations)
   ├── raws/ (for raw files)
├── lib/
├── pubspec.yaml
```

### Có flavor

Cấu trúc thư mục yêu cầu để có thể sử dụng được generator:<br>

```
<your-project>
├── <assets-folder>/
   ├── all/ <common for all flavors>
      ├── images/ (for images)
      ├── vectors/ (for vector images or svg)
      ├── translations/ (for localizations)
      ├── fonts/ (for fonts)
      ├── scripts/ (for shell scripts)
      ├── configs/ (for JSON configurations)
      ├── raws/ (for raw files)
   ├── <flavor-0>
      ├── ... (same as all/)
   ├── <flavor-1>
      ├── ... (same as all/)
   ├── <flavor-2>
      ├── ... (same as all/)
   ├── ...
├── lib/
├── pubspec.yaml
```

## Cách sử dụng

Kích hoạt executable:<br>
```
dart pub global activate --source path tools/assets_generator
```

`cd` vào thư mục project:
```
cd <your-project>
```

Chạy generator:
```
dart pub global run assets_generator:generate -i <assets-folder> -o <output-folder> -p <optional-package> -f
```
với:
- `-i` hay `--input`, tuỳ chọn, là thư mục assets đầu vào, mặc định là `assets`.
- `-o` hay `--output`, tuỳ chọn, là thư mục đầu ra, mặc định là `lib/resources`.
- `-p` hay `--package`, tuỳ chọn, là tên của package nếu các assets nằm ở các package/module riêng lẻ thay vì ở application.
- `-f` hay `--with-flavor`, tuỳ chọn, sẽ generate class thành các flavor.

## Lưu ý

- Đối với fonts, các font phải có tên theo format: `<family>-<attr-1>-<attr-2>.ttf`. Với các attr là font style và font weight<br>
Ví dụ: Roboto-Italic-w600.ttf

## Tác giả

Nguyễn Anh Quân (anhquan7826@gmail.com).