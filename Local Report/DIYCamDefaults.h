// Assets
#define ASSET_LIBRARY true

// Orientation
#define ORIENTATION_FORCE true
#define ORIENTATION_DEFAULT AVCaptureVideoOrientationLandscapeRight
#define ORIENTATION_OVERRIDE UIDeviceOrientationLandscapeLeft

// Device
#define DEVICE_FLASH false
#define DEVICE_PRIMARY AVCaptureDevicePositionBack

// Photo quality
#define PHOTO_PRESET AVCaptureSessionPresetPhoto
#define PHOTO_RESCALE true
#define PHOTO_INTERPOLATION kCGInterpolationDefault
#define PHOTO_WIDTH 1280
#define PHOTO_HEIGHT 960
#define PHOTO_QUALITY 0.9

// Video quality
#define VIDEO_PRESET AVCaptureSessionPresetMedium
#define VIDEO_CODEC AVVideoCodecH264
#define VIDEO_FPS 30
#define VIDEO_DURATION 20
#define VIDEO_MIN_DISK 49999872
#define VIDEO_THUMB_WIDTH 640
#define VIDEO_THUMB_HEIGHT 480