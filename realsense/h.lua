local ffi=require'ffi'

ffi.cdef[[
void printf(const char *fmt,...);
typedef enum _rs2_timestamp_domain
{
    RS2_TIMESTAMP_DOMAIN_HARDWARE_CLOCK, /**< Frame timestamp was measured in relation to the camera clock */
    RS2_TIMESTAMP_DOMAIN_SYSTEM_TIME,    /**< Frame timestamp was measured in relation to the OS system clock */
    RS2_TIMESTAMP_DOMAIN_COUNT           /**< Number of enumeration values. Not a valid input: intended to be used in for-loops. */
} rs2_timestamp_domain;

typedef enum _rs2_camera_info {
    RS2_CAMERA_INFO_NAME                           , /**< Friendly name */
    RS2_CAMERA_INFO_SERIAL_NUMBER                  , /**< Device serial number */
    RS2_CAMERA_INFO_FIRMWARE_VERSION               , /**< Primary firmware version */
    RS2_CAMERA_INFO_RECOMMENDED_FIRMWARE_VERSION   , /**< Recommended firmware version */
    RS2_CAMERA_INFO_PHYSICAL_PORT                  , /**< Unique identifier of the port the device is connected to (platform specific) */
    RS2_CAMERA_INFO_DEBUG_OP_CODE                  , /**< If device supports firmware logging, this is the command to send to get logs from firmware */
    RS2_CAMERA_INFO_ADVANCED_MODE                  , /**< True iff the device is in advanced mode */
    RS2_CAMERA_INFO_PRODUCT_ID                     , /**< Product ID as reported in the USB descriptor */
    RS2_CAMERA_INFO_CAMERA_LOCKED                  , /**< True iff EEPROM is locked */
    RS2_CAMERA_INFO_USB_TYPE_DESCRIPTOR            , /**< Designated USB specification: USB2/USB3 */
    RS2_CAMERA_INFO_COUNT                            /**< Number of enumeration values. Not a valid input: intended to be used in for-loops. */
} rs2_camera_info;

typedef enum _rs2_frame_metadata_value
{
    RS2_FRAME_METADATA_FRAME_COUNTER                        , /**< A sequential index managed per-stream. Integer value*/
    RS2_FRAME_METADATA_FRAME_TIMESTAMP                      , /**< Timestamp set by device clock when data readout and transmit commence. usec*/
    RS2_FRAME_METADATA_SENSOR_TIMESTAMP                     , /**< Timestamp of the middle of sensor's exposure calculated by device. usec*/
    RS2_FRAME_METADATA_ACTUAL_EXPOSURE                      , /**< Sensor's exposure width. When Auto Exposure (AE) is on the value is controlled by firmware. usec*/
    RS2_FRAME_METADATA_GAIN_LEVEL                           , /**< A relative value increasing which will increase the Sensor's gain factor. \
                                                              When AE is set On, the value is controlled by firmware. Integer value*/
    RS2_FRAME_METADATA_AUTO_EXPOSURE                        , /**< Auto Exposure Mode indicator. Zero corresponds to AE switched off. */
    RS2_FRAME_METADATA_WHITE_BALANCE                        , /**< White Balance setting as a color temperature. Kelvin degrees*/
    RS2_FRAME_METADATA_TIME_OF_ARRIVAL                      , /**< Time of arrival in system clock */
    RS2_FRAME_METADATA_TEMPERATURE                          , /**< Temperature of the device, measured at the time of the frame capture. Celsius degrees */
    RS2_FRAME_METADATA_BACKEND_TIMESTAMP                    , /**< Timestamp get from uvc driver. usec*/
    RS2_FRAME_METADATA_ACTUAL_FPS                           , /**< Actual fps */
    RS2_FRAME_METADATA_FRAME_LASER_POWER                    , /**< Laser power value 0-360. */
    RS2_FRAME_METADATA_FRAME_LASER_POWER_MODE               , /**< Laser power mode. Zero corresponds to Laser power switched off and one for switched on. */
    RS2_FRAME_METADATA_EXPOSURE_PRIORITY                    , /**< Exposure priority. */
    RS2_FRAME_METADATA_EXPOSURE_ROI_LEFT                    , /**< Left region of interest for the auto exposure Algorithm. */
    RS2_FRAME_METADATA_EXPOSURE_ROI_RIGHT                   , /**< Right region of interest for the auto exposure Algorithm. */
    RS2_FRAME_METADATA_EXPOSURE_ROI_TOP                     , /**< Top region of interest for the auto exposure Algorithm. */
    RS2_FRAME_METADATA_EXPOSURE_ROI_BOTTOM                  , /**< Bottom region of interest for the auto exposure Algorithm. */
    RS2_FRAME_METADATA_BRIGHTNESS                           , /**< Color image brightness. */
    RS2_FRAME_METADATA_CONTRAST                             , /**< Color image contrast. */
    RS2_FRAME_METADATA_SATURATION                           , /**< Color image saturation. */
    RS2_FRAME_METADATA_SHARPNESS                            , /**< Color image sharpness. */
    RS2_FRAME_METADATA_AUTO_WHITE_BALANCE_TEMPERATURE       , /**< Auto white balance temperature Mode indicator. Zero corresponds to automatic mode switched off. */
    RS2_FRAME_METADATA_BACKLIGHT_COMPENSATION               , /**< Color backlight compensation. Zero corresponds to switched off. */
    RS2_FRAME_METADATA_HUE                                  , /**< Color image hue. */
    RS2_FRAME_METADATA_GAMMA                                , /**< Color image gamma. */
    RS2_FRAME_METADATA_MANUAL_WHITE_BALANCE                 , /**< Color image white balance. */
    RS2_FRAME_METADATA_POWER_LINE_FREQUENCY                 , /**< Power Line Frequency for anti-flickering Off/50Hz/60Hz/Auto. */
    RS2_FRAME_METADATA_LOW_LIGHT_COMPENSATION               , /**< Color lowlight compensation. Zero corresponds to switched off. */
    RS2_FRAME_METADATA_COUNT
} rs2_frame_metadata_value;
typedef enum _rs2_stream
{
    RS2_STREAM_ANY,
    RS2_STREAM_DEPTH                            , /**< Native stream of depth data produced by RealSense device */
    RS2_STREAM_COLOR                            , /**< Native stream of color data captured by RealSense device */
    RS2_STREAM_INFRARED                         , /**< Native stream of infrared data captured by RealSense device */
    RS2_STREAM_FISHEYE                          , /**< Native stream of fish-eye (wide) data captured from the dedicate motion camera */
    RS2_STREAM_GYRO                             , /**< Native stream of gyroscope motion data produced by RealSense device */
    RS2_STREAM_ACCEL                            , /**< Native stream of accelerometer motion data produced by RealSense device */
    RS2_STREAM_GPIO                             , /**< Signals from external device connected through GPIO */
    RS2_STREAM_POSE                             , /**< 6 Degrees of Freedom pose data, calculated by RealSense device */
    RS2_STREAM_CONFIDENCE                       , /**< 4 bit per-pixel depth confidence level */
    RS2_STREAM_COUNT
} rs2_stream;

typedef enum _rs2_format
{
    RS2_FORMAT_ANY             , /**< When passed to enable stream, librealsense will try to provide best suited format */
    RS2_FORMAT_Z16             , /**< 16-bit linear depth values. The depth is meters is equal to depth scale * pixel value. */
    RS2_FORMAT_DISPARITY16     , /**< 16-bit float-point disparity values. Depth->Disparity conversion : Disparity = Baseline*FocalLength/Depth. */
    RS2_FORMAT_XYZ32F          , /**< 32-bit floating point 3D coordinates. */
    RS2_FORMAT_YUYV            , /**< 32-bit y0, u, y1, v data for every two pixels. Similar to YUV422 but packed in a different order - https://en.wikipedia.org/wiki/YUV */
    RS2_FORMAT_RGB8            , /**< 8-bit red, green and blue channels */
    RS2_FORMAT_BGR8            , /**< 8-bit blue, green, and red channels -- suitable for OpenCV */
    RS2_FORMAT_RGBA8           , /**< 8-bit red, green and blue channels + constant alpha channel equal to FF */
    RS2_FORMAT_BGRA8           , /**< 8-bit blue, green, and red channels + constant alpha channel equal to FF */
    RS2_FORMAT_Y8              , /**< 8-bit per-pixel grayscale image */
    RS2_FORMAT_Y16             , /**< 16-bit per-pixel grayscale image */
    RS2_FORMAT_RAW10           , /**< Four 10 bits per pixel luminance values packed into a 5-byte macropixel */
    RS2_FORMAT_RAW16           , /**< 16-bit raw image */
    RS2_FORMAT_RAW8            , /**< 8-bit raw image */
    RS2_FORMAT_UYVY            , /**< Similar to the standard YUYV pixel format, but packed in a different order */
    RS2_FORMAT_MOTION_RAW      , /**< Raw data from the motion sensor */
    RS2_FORMAT_MOTION_XYZ32F   , /**< Motion data packed as 3 32-bit float values, for X, Y, and Z axis */
    RS2_FORMAT_GPIO_RAW        , /**< Raw data from the external sensors hooked to one of the GPIO's */
    RS2_FORMAT_6DOF            , /**< Pose data packed as floats array, containing translation vector, rotation quaternion and prediction velocities and accelerations vectors */
    RS2_FORMAT_DISPARITY32     , /**< 32-bit float-point disparity values. Depth->Disparity conversion : Disparity = Baseline*FocalLength/Depth */
    RS2_FORMAT_Y10BPACK        , /**< 16-bit per-pixel grayscale image unpacked from 10 bits per pixel packed ([8:8:8:8:2222]) grey-scale image. The data is unpacked to LSB and padded with 6 zero bits */
    RS2_FORMAT_COUNT             /**< Number of enumeration values. Not a valid input: intended to be used in for-loops. */
} rs2_format;
typedef enum 
    {
        RS2_OPTION_BACKLIGHT_COMPENSATION, /**< Enable / disable color backlight compensation*/
        RS2_OPTION_BRIGHTNESS, /**< Color image brightness*/
        RS2_OPTION_CONTRAST, /**< Color image contrast*/
        RS2_OPTION_EXPOSURE, /**< Controls exposure time of color camera. Setting any value will disable auto exposure*/
        RS2_OPTION_GAIN, /**< Color image gain*/
        RS2_OPTION_GAMMA, /**< Color image gamma setting*/
        RS2_OPTION_HUE, /**< Color image hue*/
        RS2_OPTION_SATURATION, /**< Color image saturation setting*/
        RS2_OPTION_SHARPNESS, /**< Color image sharpness setting*/
        RS2_OPTION_WHITE_BALANCE, /**< Controls white balance of color image. Setting any value will disable auto white balance*/
        RS2_OPTION_ENABLE_AUTO_EXPOSURE, /**< Enable / disable color image auto-exposure*/
        RS2_OPTION_ENABLE_AUTO_WHITE_BALANCE, /**< Enable / disable color image auto-white-balance*/
        RS2_OPTION_VISUAL_PRESET, /**< Provide access to several recommend sets of option presets for the depth camera */
        RS2_OPTION_LASER_POWER, /**< Power of the F200 / SR300 projector, with 0 meaning projector off*/
        RS2_OPTION_ACCURACY, /**< Set the number of patterns projected per frame. The higher the accuracy value the more patterns projected. Increasing the number of patterns help to achieve better accuracy. Note that this control is affecting the Depth FPS */
        RS2_OPTION_MOTION_RANGE, /**< Motion vs. Range trade-off, with lower values allowing for better motion sensitivity and higher values allowing for better depth range*/
        RS2_OPTION_FILTER_OPTION, /**< Set the filter to apply to each depth frame. Each one of the filter is optimized per the application requirements*/
        RS2_OPTION_CONFIDENCE_THRESHOLD, /**< The confidence level threshold used by the Depth algorithm pipe to set whether a pixel will get a valid range or will be marked with invalid range*/
        RS2_OPTION_EMITTER_ENABLED, /**< Laser Emitter enabled */
        RS2_OPTION_FRAMES_QUEUE_SIZE, /**< Number of frames the user is allowed to keep per stream. Trying to hold-on to more frames will cause frame-drops.*/
        RS2_OPTION_TOTAL_FRAME_DROPS, /**< Total number of detected frame drops from all streams */
        RS2_OPTION_AUTO_EXPOSURE_MODE, /**< Auto-Exposure modes: Static, Anti-Flicker and Hybrid */
        RS2_OPTION_POWER_LINE_FREQUENCY, /**< Power Line Frequency control for anti-flickering Off/50Hz/60Hz/Auto */
        RS2_OPTION_ASIC_TEMPERATURE, /**< Current Asic Temperature */
        RS2_OPTION_ERROR_POLLING_ENABLED, /**< disable error handling */
        RS2_OPTION_PROJECTOR_TEMPERATURE, /**< Current Projector Temperature */
        RS2_OPTION_OUTPUT_TRIGGER_ENABLED, /**< Enable / disable trigger to be outputed from the camera to any external device on every depth frame */
        RS2_OPTION_MOTION_MODULE_TEMPERATURE, /**< Current Motion-Module Temperature */
        RS2_OPTION_DEPTH_UNITS, /**< Number of meters represented by a single depth unit */
        RS2_OPTION_ENABLE_MOTION_CORRECTION, /**< Enable/Disable automatic correction of the motion data */
        RS2_OPTION_AUTO_EXPOSURE_PRIORITY, /**< Allows sensor to dynamically ajust the frame rate depending on lighting conditions */
        RS2_OPTION_COLOR_SCHEME, /**< Color scheme for data visualization */
        RS2_OPTION_HISTOGRAM_EQUALIZATION_ENABLED, /**< Perform histogram equalization post-processing on the depth data */
        RS2_OPTION_MIN_DISTANCE, /**< Minimal distance to the target */
        RS2_OPTION_MAX_DISTANCE, /**< Maximum distance to the target */
        RS2_OPTION_TEXTURE_SOURCE, /**< Texture mapping stream unique ID */
        RS2_OPTION_FILTER_MAGNITUDE, /**< The 2D-filter effect. The specific interpretation is given within the context of the filter */
        RS2_OPTION_FILTER_SMOOTH_ALPHA, /**< 2D-filter parameter controls the weight/radius for smoothing.*/
        RS2_OPTION_FILTER_SMOOTH_DELTA, /**< 2D-filter range/validity threshold*/
        RS2_OPTION_HOLES_FILL, /**< Enhance depth data post-processing with holes filling where appropriate*/
        RS2_OPTION_STEREO_BASELINE, /**< The distance in mm between the first and the second imagers in stereo-based depth cameras*/
        RS2_OPTION_AUTO_EXPOSURE_CONVERGE_STEP, /**< Allows dynamically ajust the converge step value of the target exposure in Auto-Exposure algorithm*/
        RS2_OPTION_INTER_CAM_SYNC_MODE, /**< Impose Inter-camera HW synchronization mode. Applicable for D400/Rolling Shutter SKUs */
        RS2_OPTION_STREAM_FILTER, /**< Select a stream to process */
        RS2_OPTION_STREAM_FORMAT_FILTER, /**< Select a stream format to process */
        RS2_OPTION_STREAM_INDEX_FILTER, /**< Select a stream index to process */
        RS2_OPTION_EMITTER_ON_OFF, /**< When supported, this option make the camera to switch the emitter state every frame. 0 for disabled, 1 for enabled */
        RS2_OPTION_ZERO_ORDER_POINT_X, /**< Zero order point x*/
        RS2_OPTION_ZERO_ORDER_POINT_Y, /**< Zero order point y*/
        RS2_OPTION_LLD_TEMPERATURE, /**< LLD temperature*/
        RS2_OPTION_MC_TEMPERATURE, /**< MC temperature*/
        RS2_OPTION_MA_TEMPERATURE, /**< MA temperature*/
        RS2_OPTION_HARDWARE_PRESET, /**< Hardware stream configuration */
        RS2_OPTION_COUNT /**< Number of enumeration values. Not a valid input: intended to be used in for-loops. */
    } rs2_option;
typedef enum 
{
    RS2_EXTENSION_UNKNOWN,
    RS2_EXTENSION_DEBUG,
    RS2_EXTENSION_INFO,
    RS2_EXTENSION_MOTION,
    RS2_EXTENSION_OPTIONS,
    RS2_EXTENSION_VIDEO,
    RS2_EXTENSION_ROI,
    RS2_EXTENSION_DEPTH_SENSOR,
    RS2_EXTENSION_VIDEO_FRAME,
    RS2_EXTENSION_MOTION_FRAME,
    RS2_EXTENSION_COMPOSITE_FRAME,
    RS2_EXTENSION_POINTS,
    RS2_EXTENSION_DEPTH_FRAME,
    RS2_EXTENSION_ADVANCED_MODE,
    RS2_EXTENSION_RECORD,
    RS2_EXTENSION_VIDEO_PROFILE,
    RS2_EXTENSION_PLAYBACK,
    RS2_EXTENSION_DEPTH_STEREO_SENSOR,
    RS2_EXTENSION_DISPARITY_FRAME,
    RS2_EXTENSION_MOTION_PROFILE,
    RS2_EXTENSION_POSE_FRAME,
    RS2_EXTENSION_POSE_PROFILE,
    RS2_EXTENSION_TM2,
    RS2_EXTENSION_SOFTWARE_DEVICE,
    RS2_EXTENSION_SOFTWARE_SENSOR,
    RS2_EXTENSION_DECIMATION_FILTER,
    RS2_EXTENSION_THRESHOLD_FILTER,
    RS2_EXTENSION_DISPARITY_FILTER,
    RS2_EXTENSION_SPATIAL_FILTER,
    RS2_EXTENSION_TEMPORAL_FILTER,
    RS2_EXTENSION_HOLE_FILLING_FILTER,
    RS2_EXTENSION_ZERO_ORDER_FILTER,
    RS2_EXTENSION_RECOMMENDED_FILTERS,
    RS2_EXTENSION_POSE,
    RS2_EXTENSION_POSE_SENSOR,
    RS2_EXTENSION_WHEEL_ODOMETER,
    RS2_EXTENSION_COUNT
} rs2_extension;
typedef struct _rs2_context {} rs2_context;
typedef struct _rs2_device_list {} rs2_device_list;
typedef struct {} rs2_device;
typedef struct {} rs2_options_list;
typedef struct {} rs2_option;
typedef struct {} rs2_sensor;
typedef struct {} rs2_sensor_list;
typedef struct {} rs2_stream_profile;
typedef struct {} rs2_stream_profile_list;
typedef struct {} rs2_error;

typedef struct {} rs2_pipeline;
typedef struct {} rs2_config;
typedef struct {} rs2_stream;
typedef struct {} rs2_pipeline_profile;
typedef struct _rs2_frame { } rs2_frame ;
typedef long long   rs2_metadata_type;
typedef double      rs2_time_t; 
rs2_context* rs2_create_context(int api_version, rs2_error** error);
rs2_device_list* rs2_query_devices(const rs2_context* context, rs2_error** error);
int rs2_get_sensors_count(const rs2_sensor_list* info_list, rs2_error** error);
void rs2_delete_sensor_list(rs2_sensor_list* info_list);
void rs2_delete_stream_profile(rs2_stream_profile* profile);
void rs2_delete_sensor(rs2_sensor* sensor);
void rs2_delete_stream_profiles_list(rs2_stream_profile_list*list);
int rs2_get_device_count(const rs2_device_list* info_list, rs2_error** error);
float rs2_get_option(const rs2_options_list* options, rs2_option option, rs2_error** error);
int rs2_get_options_list_size(const rs2_options_list* options, rs2_error** error);
const char* rs2_get_failed_function            (const rs2_error* error);
const char* rs2_get_failed_args                (const rs2_error* error);
const char* rs2_get_error_message              (const rs2_error* error);
const char* rs2_get_device_info(const rs2_device* device, rs2_camera_info info, rs2_error** error);
rs2_device* rs2_create_device(const rs2_device_list* info_list, int index, rs2_error** error);
rs2_sensor* rs2_create_sensor(const rs2_sensor_list* list, int index, rs2_error** error);
rs2_pipeline* rs2_create_pipeline(rs2_context* ctx, rs2_error ** error);
rs2_config* rs2_create_config(rs2_error** error);

rs2_stream_profile_list* rs2_pipeline_profile_get_streams(rs2_pipeline_profile* profile, rs2_error** error);
const rs2_stream_profile* rs2_get_stream_profile(const rs2_stream_profile_list* list, int index, rs2_error** error);
int rs2_get_stream_profiles_count(const rs2_stream_profile_list* list, rs2_error** error);
void rs2_get_stream_profile_data(const rs2_stream_profile* mode, rs2_stream* stream, rs2_format* format, int* index, int* unique_id, int* framerate, rs2_error** error);
void rs2_get_video_stream_resolution(const rs2_stream_profile* mode, int* width, int* height, rs2_error** error);
void rs2_config_enable_stream(
		rs2_config* config,
        rs2_stream stream,
        int index,
        int width,
        int height,
        rs2_format format,
        int framerate,
        rs2_error** error);
rs2_pipeline_profile* rs2_pipeline_start_with_config(rs2_pipeline* pipe, rs2_config* config, rs2_error ** error);
rs2_frame* rs2_pipeline_wait_for_frames(rs2_pipeline* pipe, unsigned int timeout_ms, rs2_error ** error);
int rs2_embedded_frames_count(rs2_frame* composite, rs2_error** error);
rs2_frame* rs2_extract_frame(rs2_frame* composite, int index, rs2_error** error);
uint8_t* rs2_get_frame_data(const rs2_frame* frame, rs2_error** error);
uint64_t rs2_get_frame_number(const rs2_frame* frame, rs2_error** error);
rs2_sensor_list* rs2_query_sensors(const rs2_device* device, rs2_error** error);
rs2_time_t rs2_get_frame_timestamp(const rs2_frame* frame, rs2_error** error);
rs2_timestamp_domain rs2_get_frame_timestamp_domain(const rs2_frame* frameset, rs2_error** error);
int rs2_is_frame_extendable_to(const rs2_frame* frame, rs2_extension extension_type, rs2_error ** error);
int rs2_is_sensor_extendable_to(const rs2_sensor* sensor, rs2_extension extension, rs2_error** error);
const char* rs2_timestamp_domain_to_string(rs2_timestamp_domain info);
rs2_metadata_type rs2_get_frame_metadata(const rs2_frame* frame, rs2_frame_metadata_value frame_metadata, rs2_error** error);
int rs2_get_frame_stride_in_bytes(const rs2_frame* frame, rs2_error** error);
int rs2_get_frame_height(const rs2_frame* frame, rs2_error** error);
int rs2_get_frame_width(const rs2_frame* frame, rs2_error** error);
int rs2_get_frame_bits_per_pixel(const rs2_frame* frame, rs2_error** error);
void rs2_frame_add_ref(rs2_frame* frame, rs2_error ** error);
void rs2_release_frame(rs2_frame* frame);
void rs2_pipeline_stop(rs2_pipeline* pipe, rs2_error ** error);
void rs2_delete_pipeline_profile(rs2_pipeline_profile* profile);
void rs2_delete_config(rs2_config* config);
void rs2_delete_pipeline(rs2_pipeline* pipe);
void rs2_delete_device_list(rs2_device_list* info_list);
void rs2_delete_device(rs2_device* device);
void rs2_delete_context(rs2_context* context);
]]

return ffi



