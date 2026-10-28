#ifndef __CURL_SHIM_H__
#define __CURL_SHIM_H__

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void CURL;
typedef int CURLcode;
typedef int64_t curl_off_t;

#define CURLE_OK 0
#define CURLE_ABORTED_BY_CALLBACK 42
#define CURL_GLOBAL_DEFAULT 0
#define CURLOPT_URL 10002
#define CURLOPT_WRITEFUNCTION 20011
#define CURLOPT_WRITEDATA 10001
#define CURLOPT_FAILONERROR 45
#define CURLOPT_FOLLOWLOCATION 52
#define CURLOPT_NOSIGNAL 99
#define CURLOPT_CONNECTTIMEOUT_MS 156
#define CURLOPT_LOW_SPEED_LIMIT 19
#define CURLOPT_LOW_SPEED_TIME 20
#define CURLOPT_NOPROGRESS 43
#define CURLOPT_XFERINFOFUNCTION 20219
#define CURLOPT_XFERINFODATA 10057
#define CURLOPT_FTP_USE_EPSV 85
#define CURLOPT_FTPPORT 17
#define CURLOPT_USERPWD 10005
#define CURLOPT_USERNAME 10173
#define CURLOPT_PASSWORD 10174

inline CURLcode curl_global_init(long flags) { return (CURLcode)0; }
inline void curl_global_cleanup(void) {}
inline CURL* curl_easy_init(void) { return (CURL*)1; }
inline CURLcode curl_easy_setopt(CURL* curl, int option, ...) { return (CURLcode)0; }
inline CURLcode curl_easy_perform(CURL* curl) { return (CURLcode)0; }
inline void curl_easy_cleanup(CURL* curl) {}
inline const char* curl_easy_strerror(CURLcode code) { return "OK"; }

#ifdef __cplusplus
}
#endif

#endif // __CURL_SHIM_H__
