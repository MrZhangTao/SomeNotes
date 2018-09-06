--[[
	file:ShopMainLayer.lua
	desc:商店入口
	author:ZhangTao
	time:2017-02-16
--]]

local ShopMainLayer = class("ShopMainLayer", function()
	return cc.LayerColor:create()
end)

--初始化函数
--[[
	params:
	return:
--]]
function ShopMainLayer:ctor(params)
	--防止触摸穿透
	ui.registerSwallowTouch({node = self, endedEvent = function(touch, event)
		if not ui.touchInNode(touch, self.mBgSpr) then
			LayerManager.removeLayer(self)
		end
	end})
	--设置透明度
	self:setOpacity(255 * 0.75)
	--创建标准父级层
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)
	
	--创建UI
	self:initUI()
end

--初始化UI
--[[
	params:nil
	return:nil
--]]
function ShopMainLayer:initUI()
	--创建商店入口背景
	self.mBgSize = cc.size(580, 701)
	self.mBgSpr = ui.newScale9Sprite("c_178.png", self.mBgSize)
	self.mBgSpr:setPosition(320, 568)
	self.mBgSpr:addTo(self.mParentLayer)
	--创建标题
	local shopTitle = ui.newSprite("home_89.png")
	shopTitle:setPosition(cc.p(self.mBgSize.width / 2, self.mBgSize.height))
	self.mBgSpr:addChild(shopTitle)
	--创建关闭按钮
	local closeBtn = ui.newButton({
		normalImage = "c_3.png",
		position = cc.p(self.mBgSize.width - 55, self.mBgSize.height - 9),
		clickAction = function(pSender)
			LayerManager.removeLayer(self)
		end,
	})
	self.mBgSpr:addChild(closeBtn)

	--创建商店入口
	self:createShopsEntrance()
end

--判断商店哪些入口可以进入,初始化商店列表信息
--[[
	params:nil
	return: btnInfos
--]]
function ShopMainLayer:initBtnInfos()
	--按钮信息表   moduleId不影响ui.newButton
	local btnInfos = {
		--道具商店
		{
			moduleId = ModuleSub.eStoreProps,
			normalImage = "home_95.png",
			clickAction = function(pSender)
        		LayerManager.addLayer({
        			name = "shop.ShopLayer",
        			data = {
        				moduleSub = ModuleSub.eStoreProps
        			}
        		})
			end,
		},
	}

	--坊市商店
	if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eMysteryShop) then
		if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eMysteryShop) then
			table.insert(btnInfos, {
				moduleId = ModuleSub.eMysteryShop,
				normalImage = "home_96.png",
				clickAction = function(pSender)
	                LayerManager.addLayer({
	                    name = "mysteryshop.MysteryShopLayer",
	                })
				end,
			})
		end
	end

	--家族商店
	if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eGuild) then
		local guildInfo = GuildObj:getGuildInfo()
		if Utility.isEntityId(guildInfo.Id) and ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eGuild) then
			table.insert(btnInfos, {
				moduleId = ModuleSub.eGuildShop,
				normalImage = "home_94.png",
				clickAction = function(pSender)
					LayerManager.addLayer({
		                name = "guild.GuildStoreLayer",
		            })
				end
			})
		end
	end

	--宫廷晋升商店
	if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eChallengeArena) then
		if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eChallengeArena) then
			--- 检测当前玩家是否可以兑换排名兑换中的物品
			--[[
			-- 参数
			    shopInfos：商城兑换信息
			    historyMaxRank: 玩家最高排名。
			-- 返回值
			    排名兑换中有可以兑换的返回 true，否则返回 false
			 ]]
			function allowRankShop(shopInfos, historyMaxRank, historyMaxStep)  --该函数暂时存放于此
			    if shopInfos and historyMaxRank then
			        local pvpCoin = PlayerAttrObj:getPlayerAttr(ResourcetypeSub.ePVPCoin)
			        for _, item in pairs(shopInfos) do
			            local configData = PvpShopModel.items[item.ShopId]
			            if configData and configData.needRank and configData.needRank > 0 then
			                local tempAllow = true
			                if historyMaxStep < configData.needStep or historyMaxStep == configData.needStep and historyMaxRank > configData.needRank then
			                    tempAllow = false
			                end

			                if tempAllow and configData.perMaxNum > 0 and item.BuyNum >= configData.perMaxNum then -- 判断每日兑换次数
			                    tempAllow = false
			                end
			                if tempAllow and configData.totalMaxNum > 0 and item.BuyTotalNum >= configData.totalMaxNum then -- 判断总兑换次数
			                    tempAllow = false
			                end
			                if tempAllow and pvpCoin < configData.needPVPCoin then  -- 判断玩家是否有足够的声望来兑换该物品
			                    tempAllow = false
			                end
			                if tempAllow then
			                    return true
			                end
			            end
			        end
			    end
			    return false
			end
			table.insert(btnInfos, {
				moduleId = ModuleSub.eChallengeArenaShop,
				normalImage = "home_93.png",
				clickAction = function(pSender)
					--请求服务器信息
					HttpClient:request({
				    	moduleName = "PVP",
				    	methodName = "GetPVPInfo",
				    	callback = function(response)
				    	    if response.Status ~= 0 then
				    	    	return
				    	    end
					        LayerManager.addLayer({
				    	        name = "practice.PvpCoinStoreLayer",
				    	        data = {
				    	        	tag = 2,
				    	        	pvpInfo = response.Value
				    	        },
			    	    	})
				    	end
					})
		    	end,
			})
		end
	end

	--嬷嬷会所商店
	if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.ePracticeBloodyDemonDomain) then
		if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.ePracticeBloodyDemonDomain) then
			table.insert(btnInfos, {
				normalImage = "home_91.png",
				clickAction = function(pSender)
					HttpClient:request({
				    	moduleName = "BddInfo",
				    	methodName = "Info",
				    	svrMethodData = {1, 1, 1, 1},
				    	callback = function(response)
				    	    if response.Status ~= 0 then
				    	    	return
				    	    end
							LayerManager.addLayer({
			                	name = "practice.Bdd.BddShopLayer",
			                	data = {data = response.Value},
	            			})
	            		end,
					})
				end
			})
		end
	end

	--会宾楼商店
	if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eChallengeWrestle) then
		if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eChallengeWrestle) then
			table.insert(btnInfos, {
				moduleId = ModuleSub.eChallengeWrestleShop,
				normalImage = "home_90.png",
				clickAction = function(pSender)
					--会宾楼历史最高排名
					local histortRank = nil
					HttpClient:request({
				        moduleName = "Gddh",
				        methodName = "GetWrestleRaceInfo",
				        callback = function(data)
				            if not data.Value or data.Status ~= 0 then
				                return
				            end
				            -- 保存会宾楼的历史最高排名
				            histortRank = data.Value.HistortRank
				        end
				    })
					--会宾楼赛季数据
					local signupInfo = {}
					HttpClient:request({
				        moduleName = "Gddh",
				        methodName = "SignupInfo",
				        callback = function(data)
				            -- 容错处理
				            if not data.Value or data.Status ~= 0 then
				                return
				            end
				            -- 保存数据，格斗大会赛季信息表
				            signupInfo = data.Value
			                LayerManager.addLayer({
			                    name = "challenge.GeDouDaHui.GGDHShopLayer",
			                    -- name = "practice.Bdd.BddLevelLayer",
			                    data = {
			                    	histortRank = histortRank,
		    						signupData = signupInfo
			                	}
	                		})
				        end
				    })
				end,
			})
		end
	end

	--格格衣橱
	if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eBagDress) then
		if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBagDress) then
			table.insert(btnInfos, {
				normalImage = "home_105.png",
				clickAction = function(pSender)
					LayerManager.addLayer({
						name = "practice.Dress.GeGeClosetLayer",
					})
				end,
			})
		end
	end

	-- dump(btnInfos, "HelloWorld")
    return btnInfos
end

--商店小红点
--[[
	params:
		btn商店按钮
		moduleId 模块Id
	return:
--]]
function ShopMainLayer:dealRedDot(btn, moduleId)
	if not btn or tolua.isnull(btn) or not moduleId then
		return
	end
	--[[
		道具商店:		2002 ModuleSub.eStoreProps
		坊市:		2100 ModuleSub.eMysteryShop
		家族商店:		3408 ModuleSub.eGuildShop
		宫廷晋升:		2513 ModuleSub.eChallengeArenaShop
		嬷嬷会所:		2514 ModuleSub.eBDDShop
		会宾楼:		2515 ModuleSub.eChallengeWrestleShop
	--]]
	--处理小红点的函数
	local function dealRedDotVisible(redDotSpr)
		if not redDotSpr or tolua.isnull(redDotSpr) then
			return
		end
		local needVisible = false
		if RedDotInfoObj:getRedDotInfoById(moduleId) then
			needVisible = true
		end
		redDotSpr:setVisible(needVisible)
	end

	--事件名称
	local eventName = EventsName.eRedDotPrefix .. moduleId

	--创建小红点
	local redDotSpr = ui.createBubble({
		position = cc.p(239 * 0.93, 135 * 0.86),
		needFlash = true,
	})
	btn:addChild(redDotSpr)
	Notification:registerAutoObserver(redDotSpr, dealRedDotVisible, eventName)
	dealRedDotVisible(redDotSpr)
end

--创建商店入口
--[[
	params:nil
	return:nil
--]]
function ShopMainLayer:createShopsEntrance()
	--使用列表控件来放置商店入口
	local listViewSize = cc.size(570, 592) -- 列表大小
	self.mShopListView = ccui.ListView:create()
	self.mShopListView:setDirection(ccui.ScrollViewDir.vertical)
	self.mShopListView:setBounceEnabled(true)
	self.mShopListView:setTouchEnabled(false) --禁止触摸滑动
	self.mShopListView:setContentSize(listViewSize)
	self.mShopListView:setGravity(ccui.ListViewGravity.centerHorizontal)
	self.mShopListView:setAnchorPoint(cc.p(0.5, 0))
	self.mShopListView:setPosition(cc.p(self.mBgSize.width / 2, 27))
	self.mBgSpr:addChild(self.mShopListView)

	--判断哪些入口可以进入
	local btnInfos = self:initBtnInfos()

	for index = 1, math.ceil(#btnInfos / 2) do
		local shopItem = ccui.Layout:create()
		local layoutSize = cc.size(564, 148)
		shopItem:setContentSize(layoutSize)
		--按钮放置在左侧
		if btnInfos[index * 2 - 1] then
			local btnL = ui.newButton(btnInfos[index * 2 - 1])
			btnL:setPosition(cc.p(layoutSize.width / 4 + 26, layoutSize.height / 2))
			shopItem:addChild(btnL)
			--处理小红点
			self:dealRedDot(btnL, btnInfos[index * 2 - 1].moduleId)
		end
		--按钮放置在右侧
		if btnInfos[index * 2] then
			local btnR = ui.newButton(btnInfos[index * 2])
			btnR:setPosition(cc.p(layoutSize.width * 3 / 4 - 12, layoutSize.height / 2))
			shopItem:addChild(btnR)
			--处理小红点
			self:dealRedDot(btnR, btnInfos[index * 2].moduleId)
		end
		shopItem:setPosition(listViewSize.width / 2, listViewSize.height - (index - 0.5) * layoutSize.height)
		self.mShopListView:pushBackCustomItem(shopItem)
	end
end

return ShopMainLayer