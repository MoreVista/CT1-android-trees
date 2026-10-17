/*
 * 40S404: the stock (Android 4.2) blobs reference the reserved virtual slots that KitKat's
 * libutils removed. Export just the symbols (as plain no-op functions) so those blobs can
 * load, WITHOUT re-declaring the virtuals: re-adding them to VectorImpl.h shifts the vtable
 * slot of SortedVectorImpl::do_compare and breaks every module not rebuilt with the macro.
 */
#define SHIM(name, sym) extern "C" void name() __asm__(sym); extern "C" void name() { }
SHIM(vecimpl_shim0, "_ZN7android10VectorImpl19reservedVectorImpl1Ev")
SHIM(vecimpl_shim1, "_ZN7android10VectorImpl19reservedVectorImpl2Ev")
SHIM(vecimpl_shim2, "_ZN7android10VectorImpl19reservedVectorImpl3Ev")
SHIM(vecimpl_shim3, "_ZN7android10VectorImpl19reservedVectorImpl4Ev")
SHIM(vecimpl_shim4, "_ZN7android10VectorImpl19reservedVectorImpl5Ev")
SHIM(vecimpl_shim5, "_ZN7android10VectorImpl19reservedVectorImpl6Ev")
SHIM(vecimpl_shim6, "_ZN7android10VectorImpl19reservedVectorImpl7Ev")
SHIM(vecimpl_shim7, "_ZN7android10VectorImpl19reservedVectorImpl8Ev")
SHIM(vecimpl_shim8, "_ZN7android16SortedVectorImpl25reservedSortedVectorImpl1Ev")
SHIM(vecimpl_shim9, "_ZN7android16SortedVectorImpl25reservedSortedVectorImpl2Ev")
SHIM(vecimpl_shim10, "_ZN7android16SortedVectorImpl25reservedSortedVectorImpl3Ev")
SHIM(vecimpl_shim11, "_ZN7android16SortedVectorImpl25reservedSortedVectorImpl4Ev")
SHIM(vecimpl_shim12, "_ZN7android16SortedVectorImpl25reservedSortedVectorImpl5Ev")
SHIM(vecimpl_shim13, "_ZN7android16SortedVectorImpl25reservedSortedVectorImpl6Ev")
SHIM(vecimpl_shim14, "_ZN7android16SortedVectorImpl25reservedSortedVectorImpl7Ev")
SHIM(vecimpl_shim15, "_ZN7android16SortedVectorImpl25reservedSortedVectorImpl8Ev")

/*
 * The 4.2 blobs (lib_id3_parser, pulled in when the FSL OMX core loads lib_omx_vpu_dec) call
 * String8::setTo(unsigned short const*, unsigned int); since the char16_t change the symbol is
 * ...setToEPKDsj, so dlopen() of the whole VPU decoder chain failed ("cannot locate symbol").
 */
#include <utils/String8.h>
extern "C" int string8_setto_ushort_shim(android::String8* self, const unsigned short* other,
        unsigned int numChars) __asm__("_ZN7android7String85setToEPKtj");
extern "C" int string8_setto_ushort_shim(android::String8* self, const unsigned short* other,
        unsigned int numChars) {
    return self->setTo(reinterpret_cast<const char16_t*>(other), numChars);
}
