# WordSchool — Google Play Store assets

Generated marketing images for Play Console upload.

## Files

| File | Size | Use in Play Console |
|------|------|---------------------|
| `feature_graphic_1024x500.png` | 1024×500 | **Feature graphic** (required) |
| `screenshot_01_dashboard_1080x1920.png` | 1080×1920 | Phone screenshots |
| `screenshot_02_gameplay_1080x1920.png` | 1080×1920 | Phone screenshots |
| `screenshot_03_completed_win_1080x1920.png` | 1080×1920 | Phone screenshots |
| `screenshot_04_victory_screen_1080x1920.png` | 1080×1920 | Phone screenshots |
| `screenshot_05_archive_1080x1920.png` | 1080×1920 | Phone screenshots |

## Play Console requirements

- **Feature graphic**: 1024×500 px, JPG or 24-bit PNG (no alpha)
- **Phone screenshots**: min 2, max 8; 16:9 or 9:16 aspect ratio; min 320 px short side

## Regenerate

```bash
python3 tool/generate_playstore_assets.py
```
