# Hologram-Avisynth-Reborn
This script uses Avisynth or Avisynth+ to take 4 video clips [+ audio] and combine them into a composite video that forms a hologram in combination with a hologram pyramid.
I based this script off of a no-longer maintained one by phuctk93 (https://github.com/phuctk93/Hologram_Avisynth)
Please use his readme for instructions (it's not much).

## Improvements over the old script:
* Music is optional
* Clips are not distorted (they keep their aspect ratio)
* Output video size can be any number
* A center gap can be specified
* An FPS can be provided (or one from the clips can be used)
* Face up and face down output video is supported (this was accomplished in 2 scripts previously)
* Framecount is calculated within the program (the old script required this to be entered manually)
* Handling of clips with different FPS's and framecounts is supported
* Output video can be in any of the 4 color formats Avisynth supports (YUY2, YV12, RGB24, RGB32)
* Clip and audio filepaths can be easily set
