#ifdef __EMSCRIPTEN__

#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_JPEG
#include "stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#include "turbojpeg.h"
#include <cstdlib>
#include <cstring>
#include <vector>

extern "C" {

tjhandle tjInitCompress(void)
{
    return reinterpret_cast<tjhandle>(1);
}

tjhandle tjInitDecompress(void)
{
    return reinterpret_cast<tjhandle>(1);
}

int tjDestroy(tjhandle handle)
{
    (void)handle;
    return 0;
}

char* tjGetErrorStr(void)
{
    static char errMsg[] = "TurboJPEG Emscripten shim error";
    return errMsg;
}

unsigned long tjBufSize(int width, int height, int jpegSubsamp)
{
    (void)jpegSubsamp;
    return static_cast<unsigned long>(width * height * 3 + 4096);
}

int tjDecompressHeader3(tjhandle handle,
                        const unsigned char* jpegBuf,
                        unsigned long jpegSize,
                        int* width,
                        int* height,
                        int* jpegSubsamp,
                        int* jpegColorspace)
{
    (void)handle;
    int channels = 0;
    if (!stbi_info_from_memory(jpegBuf, static_cast<int>(jpegSize), width, height, &channels))
    {
        return -1;
    }
    if (jpegSubsamp)
        *jpegSubsamp = TJSAMP_444;
    if (jpegColorspace)
        *jpegColorspace = TJCS_RGB;
    return 0;
}

int tjDecompress2(tjhandle handle,
                  const unsigned char* jpegBuf,
                  unsigned long jpegSize,
                  unsigned char* dstBuf,
                  int width,
                  int pitch,
                  int height,
                  int pixelFormat,
                  int flags)
{
    (void)handle;
    (void)pixelFormat;
    int imgW = 0, imgH = 0, channels = 0;
    unsigned char* data = stbi_load_from_memory(jpegBuf, static_cast<int>(jpegSize), &imgW, &imgH, &channels, 3);
    if (!data)
    {
        return -1;
    }

    if (pitch <= 0)
    {
        pitch = width * 3;
    }

    const bool bottomUp = (flags & TJFLAG_BOTTOMUP) != 0;
    const int copyW = (imgW < width) ? imgW : width;
    const int copyH = (imgH < height) ? imgH : height;

    for (int y = 0; y < copyH; ++y)
    {
        const int srcY = bottomUp ? (copyH - 1 - y) : y;
        unsigned char* dstRow = dstBuf + (y * pitch);
        const unsigned char* srcRow = data + (srcY * imgW * 3);
        std::memcpy(dstRow, srcRow, static_cast<size_t>(copyW) * 3);
    }

    stbi_image_free(data);
    return 0;
}

struct ShimJpegWriteContext
{
    std::vector<unsigned char> data;
};

static void ShimWriteFunc(void* context, void* data, int size)
{
    auto* ctx = static_cast<ShimJpegWriteContext*>(context);
    const auto* bytes = static_cast<const unsigned char*>(data);
    ctx->data.insert(ctx->data.end(), bytes, bytes + size);
}

int tjCompress2(tjhandle handle,
                const unsigned char* srcBuf,
                int width,
                int pitch,
                int height,
                int pixelFormat,
                unsigned char** jpegBuf,
                unsigned long* jpegSize,
                int jpegSubsamp,
                int jpegQual,
                int flags)
{
    (void)handle;
    (void)pixelFormat;
    (void)jpegSubsamp;

    if (!srcBuf || !jpegBuf || !jpegSize || width <= 0 || height <= 0)
    {
        return -1;
    }

    if (pitch <= 0)
    {
        pitch = width * 3;
    }

    const bool bottomUp = (flags & TJFLAG_BOTTOMUP) != 0;
    std::vector<unsigned char> tempRgb;
    const unsigned char* rgbToEncode = srcBuf;

    if (bottomUp)
    {
        tempRgb.resize(static_cast<size_t>(width) * height * 3);
        for (int y = 0; y < height; ++y)
        {
            const unsigned char* srcRow = srcBuf + (height - 1 - y) * pitch;
            unsigned char* dstRow = tempRgb.data() + (y * width * 3);
            std::memcpy(dstRow, srcRow, static_cast<size_t>(width) * 3);
        }
        rgbToEncode = tempRgb.data();
    }

    ShimJpegWriteContext writeCtx;
    int success = stbi_write_jpg_to_func(ShimWriteFunc, &writeCtx, width, height, 3, rgbToEncode, jpegQual);
    if (!success || writeCtx.data.empty())
    {
        return -1;
    }

    if (*jpegBuf != nullptr && (flags & TJFLAG_NOREALLOC))
    {
        if (*jpegSize >= writeCtx.data.size())
        {
            std::memcpy(*jpegBuf, writeCtx.data.data(), writeCtx.data.size());
            *jpegSize = static_cast<unsigned long>(writeCtx.data.size());
            return 0;
        }
    }

    *jpegBuf = static_cast<unsigned char*>(std::malloc(writeCtx.data.size()));
    if (!*jpegBuf)
    {
        return -1;
    }
    std::memcpy(*jpegBuf, writeCtx.data.data(), writeCtx.data.size());
    *jpegSize = static_cast<unsigned long>(writeCtx.data.size());
    return 0;
}

} // extern "C"

#endif // __EMSCRIPTEN__
