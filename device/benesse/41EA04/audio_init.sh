#!/system/bin/sh
# wm8978 boot-time mixer defaults. The kernel leaves the right speaker path off
# and audio.primary.imx6 only enables the left one, so the speaker is silent.
# Control ids are those of the stock kernel's wm8978 driver (tinymix listing).
# Applied twice, a few seconds apart: the first pass can race the codec bring-up.
T=/system/bin/tinymix
apply() {
    $T 44 57   # Speaker Playback Volume
    $T 45 1    # Left Speaker Out Switch
    $T 46 1    # Right Speaker Out Switch
    $T 54 1    # DACR2RMIX Switch
    $T 55 1    # DACL2RMIX Switch
    $T 73 1    # Right Output Mixer PCM Playback Switch
    $T 76 1    # Left Output Mixer PCM Playback Switch
}
sleep 3
apply
sleep 10
apply
