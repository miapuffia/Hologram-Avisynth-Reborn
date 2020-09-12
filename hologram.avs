/*
	Created by Robert D. Rioja
	with inpiration from phuctk93 (https://github.com/phuctk93/)
	
	v2.0
*/

#User parameters
useMusic = true 					#Whether or not to look for a music file
outputSize = 600					#Size of square output, unit PIXEL
centerGap = 100						#Space in the center of the output video (this is included in the output size), unit PIXEL
fps = 0 							#Frames per second, 0 = Lowest of input videos, 1 = Highest of input videos, any other number is trated as target FPS
roundInvalidDimensions = 1			#0 = Don't round (will throw errors), 1 = Round down, 2 = Round up
videoFacesUp = true					#Whether the output video will face up or down
requireMatchingFramecounts = 0		#0 = Require matching video framecounts, 1 = Use lowest framecount, 2 = Use highest framecount
outputColorFormat = 0				#0 = YUY2, 1 = YV12, 2 = RGB24, 3 = RGB32

topVideoFile =		"f.avi"
bottomVideoFile =	"b.avi"
leftVideoFile =		"l.avi"
rightVideoFile =	"r.avi"
musicFile =			"music.mp3"		#Ignore if not using music

#Video sources
vTop = DirectShowSource(topVideoFile, audio = false)			#Front video
vBottom = DirectShowSource(bottomVideoFile, audio = false)		#Back video
vRight = DirectShowSource(leftVideoFile, audio = false)			#Right video
vLeft = DirectShowSource(rightVideoFile, audio = false)			#Left video

#Audio Source
audio = (useMusic ? DirectShowSource(musicFile) : BlankClip())

#Position variables
centerWithHalfGap = (outputSize + centerGap) / 2
videoCenterDim = centerWithHalfGap - centerGap
videoOtherDim = Round((Float(videoCenterDim) / vTop.height) * vTop.width)

#If we don't round, assert outputSize is a multiple of 2, otherwise round down or up
(roundInvalidDimensions == 0 ? Assert(outputSize % 2 == 0, String(outputSize) + " is not a multiple of 2 - Please adjust the output size") : NOP())
outputSize = (roundInvalidDimensions == 1 && outputSize % 2 != 0 ? outputSize - 1 : outputSize)
outputSize = (roundInvalidDimensions == 2 && outputSize % 2 != 0 ? outputSize + 1 : outputSize)

#If we don't round, assert videoCenterDim is a multiple of 2, otherwise round down or up
(roundInvalidDimensions == 0 ? Assert(videoCenterDim % 2 == 0, String(videoCenterDim) + " is not a multiple of 2 - Please adjust the output size and/or center space (issue is with center dim)") : NOP())
videoCenterDim = (roundInvalidDimensions == 1 && videoCenterDim % 2 != 0 ? videoCenterDim - 1 : videoCenterDim)
videoCenterDim = (roundInvalidDimensions == 2 && videoCenterDim % 2 != 0 ? videoCenterDim + 1 : videoCenterDim)

#If we don't round, assert videoOtherDim is a multiple of 2, otherwise round down or up
(roundInvalidDimensions == 0 ? Assert(videoOtherDim % 2 == 0, String(videoOtherDim) + " is not a multiple of 2 - Please adjust the output size and/or center space (issue is with other dim)") : NOP())
videoOtherDim = (roundInvalidDimensions == 1 && videoOtherDim % 2 != 0 ? videoOtherDim - 1 : videoOtherDim)
videoOtherDim = (roundInvalidDimensions == 2 && videoOtherDim % 2 != 0 ? videoOtherDim + 1 : videoOtherDim)

#Assert videos have identical dimensions
Assert((vTop.width == vBottom.width == vLeft.width == vRight.width) && (vTop.height == vBottom.height == vLeft.height == vRight.height), "Videos do not have identical dimensions")

#If we require matching framecounts, assert videos have identical framecounts, otherwise use smallest or largest 
framecount = (requireMatchingFramecounts == 0 ? Eval("""
	Assert(vTop.framecount == vBottom.framecount == vLeft.framecount == vRight.framecount, "Videos do not have identical framecounts")
	return vTop.framecount
""") : NOP())
framecount = (requireMatchingFramecounts == 1 ? Min(vTop.framecount, vBottom.framecount, vLeft.framecount, vRight.framecount) : framecount)
framecount = (requireMatchingFramecounts == 2 ? Max(vTop.framecount, vBottom.framecount, vLeft.framecount, vRight.framecount) : framecount)

#Output video framerate
framerate = fps
framerate = (fps == 0 ? Min(vTop.framerate, vBottom.framerate, vLeft.framerate, vRight.framerate) : framerate)
framerate = (fps == 1 ? Max(vTop.framerate, vBottom.framerate, vLeft.framerate, vRight.framerate) : framerate)

#Rotate videos to their correct orientations and resize
vTop = vTop.Turn180().Spline16Resize(videoOtherDim, videoCenterDim)
vBottom = vBottom.Spline16Resize(videoOtherDim, videoCenterDim)
vRight = (videoFacesUp ? vRight.TurnRight() : vRight.TurnLeft())		#Rotate depending on face up
vLeft = (videoFacesUp ? vLeft.TurnLeft() : vLeft.TurnRight())			#Rotate depending on face up
vRight = vRight.Spline16Resize(videoCenterDim, videoOtherDim)
vLeft = vLeft.Spline16Resize(videoCenterDim, videoOtherDim)

#pixel_type string for blank frame
pixelType = ""

outputColorFormat == 0 ? Eval("""
	vTop = vTop.ConvertToYUY2()
	vBottom = vBottom.ConvertToYUY2()
	vLeft = vLeft.ConvertToYUY2()
	vRight = vRight.ConvertToYUY2()
	
	pixelType = "YUY2"
""") : NOP()
outputColorFormat == 1 ? Eval("""
	vTop = vTop.ConvertToYV12()
	vBottom = vBottom.ConvertToYV12()
	vLeft = vLeft.ConvertToYV12()
	vRight = vRight.ConvertToYV12()
	
	pixelType = "YV12"
""") : NOP()
outputColorFormat == 2 ? Eval("""
	vTop = vTop.ConvertToRGB24()
	vBottom = vBottom.ConvertToRGB24()
	vLeft = vLeft.ConvertToRGB24()
	vRight = vRight.ConvertToRGB24()
	
	pixel_type = "RGB24"
""") : NOP()
outputColorFormat == 3 ? Eval("""
	vTop = vTop.ConvertToRGB32()
	vBottom = vBottom.ConvertToRGB32()
	vLeft = vLeft.ConvertToRGB32()
	vRight = vRight.ConvertToRGB32()
	
	pixelType = "RGB32"
""") : NOP()

#Black background
blankFrame = BlankClip(length = framecount, width = outputSize, height = outputSize, fps = framerate, color = $000000, pixel_type = pixelType)

#Layers
Layer1 = Layer(
	\ blankFrame, vBottom, op = "lighten", level = 256,
	\ x = (outputSize - vBottom.width) / 2,
	\ y=0)
Layer2 = Layer(
	\ Layer1, vTop, op = "lighten", level = 256,
	\ x = (outputSize - vTop.width) / 2,
	\ y = centerWithHalfGap)
Layer3 = Layer(
	\ Layer2, vRight, op = "lighten", level = 256,
	\ x = centerWithHalfGap,
	\ y = (outputSize - vRight.height) / 2)
Layer4 = Layer(
	\ Layer3, vLeft, op = "lighten", level = 256,
	\ x = 0,
	\ y = (outputSize - vLeft.height) / 2)

#Output
AudioDubEx(Layer4, audio)