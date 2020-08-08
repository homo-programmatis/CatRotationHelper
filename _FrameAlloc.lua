local THIS_ADDON_NAME=...;
local g_Addon = getfenv(0)[THIS_ADDON_NAME];
local g_Consts = g_Addon.Constants;

-- This array keeps all frames
-- Deallocated frames stay in cache, and they're allocated back from cache later
-- Debugging: /dump CatRotationHelper.FrameCache
-- Debugging: /run print("NumFrames=" .. #CatRotationHelper.FrameCache)
g_Addon.FrameCache = {};

-- Allocates new frame. It's taken from cache if there's a deallocated frame there.
function g_Addon.FrameAlloc()
	for _, frame in pairs(g_Addon.FrameCache) do
		if (frame.IsDeallocated) then
			frame.IsDeallocated = false;
			g_Addon.FrameReset(frame);
			frame:Show();
			return frame;
		end
	end

	local newFrame = g_Addon.FrameCreateNew(THIS_ADDON_NAME .. #g_Addon.FrameCache);
	table.insert(g_Addon.FrameCache, newFrame);
	newFrame:Show();
	return newFrame;
end

-- Deallocates a frame.
-- In WoW, a frame can't be deleted. This is why it stays in cache.
function g_Addon.FrameDealloc(a_Frame)
	a_Frame.IsDeallocated = true;
	a_Frame:Hide();
end

function g_Addon.FrameDeallocAll()
	for _, frameList in pairs(g_Addon.FrameLists) do
		for frameIdx, frame in pairs(frameList) do
			g_Addon.FrameDealloc(frame);
			frameList[frameIdx] = nil;
		end
	end
end
