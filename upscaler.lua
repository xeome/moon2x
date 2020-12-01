os.remove("temp")
os.execute("mkdir temp")
local handle = assert(io.popen("ffprobe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate,duration -of default=noprint_wrappers=1 "..arg[1],"r"),"opening file failed")
local rawinfo = handle:read("*all")
handle:close()
local xx,yy = string.find(rawinfo,"n=%d+.%d+") --fuck pattern matching
local xs,ys = string.find(rawinfo,"%d+/%d")
local videoinfo = {
	height = tonumber(string.sub(rawinfo,string.find(rawinfo,"%d+",1))),
	width = tonumber(string.sub(rawinfo,string.find(rawinfo,"%d+",2))),
	fps = tonumber(string.sub(rawinfo,xs,ys-2)),
	duration = tonumber(string.sub(rawinfo,xx+2,yy))

}
os.execute("ffmpeg -i "..arg[1].." temp/img%04d.jpg -hide_banner")

for i=0,videoinfo.duration*videoinfo.fps do
	os.execute("waifu2x-ncnn-vulkan -i temp/img"..string.format("%04d",i)..".jpg -o temp/output"..string.format("%04d",i)..".png -n 2 -s 2")
end

os.execute("ffmpeg -r "..videoinfo.fps.." -f image2 -s "..videoinfo.height.."x"..videoinfo.width.." -i temp/output%04d.jpg -vcodec libx264 -crf 18  -pix_fmt yuv420p "..arg[2])
os.remove("temp")
