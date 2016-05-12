local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Module.Constants;

-- This array keeps all frames
-- Deallocated frames stay in cache, and they're allocated back from cache later
-- Debugging: /dump CatRotationHelper.FrameCache
-- Debugging: /run print("NumFrames=" .. #CatRotationHelper.FrameCache)
g_Module.FrameCache = {};

-- Allocates new frame. It's taken from cache if there's a deallocated frame there.
function g_Module.FrameAlloc()
	for _, frame in pairs(g_Module.FrameCache) do
		if (frame.IsDeallocated) then
			frame.IsDeallocated = false;
			g_Module.FrameReset(frame);
			frame:Show();
			return frame;
		end
	end
	
	local newFrame = g_Module.FrameCreateNew(THIS_ADDON_NAME .. #g_Module.FrameCache);
	table.insert(g_Module.FrameCache, newFrame);
	newFrame:Show();
	return newFrame;
end

-- Deallocates a frame.
-- In WoW, a frame can't be deleted. This is why it stays in cache.
function g_Module.FrameDealloc(a_Frame)
	a_Frame.IsDeallocated = true;
	a_Frame:Hide();
end

function g_Module.FrameDeallocAll()
	for _, frameList in pairs(g_Module.FrameLists) do
		for frameIdx, frame in pairs(frameList) do
			g_Module.FrameDealloc(frame);
			frameList[frameIdx] = nil;
		end
	end
end
