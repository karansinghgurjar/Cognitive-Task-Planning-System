# App Icon Source

Place the source image here as:

- `assets/branding/app_icon_source.png`

Notes:
- Use the user-provided artwork as the source file.
- Keep it square if possible for best results.
- If the original image is taller than it is wide, crop/zoom it before saving so the subject is centered and readable at small sizes.
- You can also pass a non-square original image directly to the helper script. It will crop around the bright subject and write `app_icon_source.png` automatically.

After adding or replacing the file, run:

```powershell
dart run flutter_launcher_icons
```

Or use:

```powershell
.\tool\dev_windows.ps1
```

That script regenerates icons when the source image changes, then starts the Windows app with normal Flutter hot reload for code changes.

To prepare directly from an external file path:

```powershell
.\tool\sync_app_icon.ps1 -SourceImagePath "C:\path\to\image.png"
```
