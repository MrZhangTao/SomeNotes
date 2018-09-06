--[[
    filename:OfficerHomeLayer.lua
    desc:官阶系统--挑战主页面
    author:ZhangTao
    date:2017-09-11 14:24:49
--]]

--层级枚举
local zorder = {
    ui = 3, --ui的层级
    tips = 2, --连胜标记
}

--标签枚举
local tag = {
    enemy = 1,-- 匹配对手
    enemyRoleInfo = 2,--对手信息栏
}

--宝箱类型枚举
boxType = {
    daily = 1, --每日
    season = 2, -- 赛季
}

--宝箱状态事件
local boxEvent = {
    daily = "dailyBox",
    season = "seasonBox",
}

local officerRankRes = { --官阶品级资源
    "gj_11.png",
    "gj_43.png",
    "gj_44.png",
    "gj_45.png",
    "gj_46.png",
    "gj_47.png",
    "gj_48.png",
    "gj_49.png",
    "gj_50.png",
    "gj_51.png",
}

local officerNameRes = { --官衔资源
    {
        "gj_13.png",
        "gj_15.png",
        "gj_17.png",
        "gj_19.png",
        "gj_21.png",
        "gj_23.png",
        "gj_25.png",
        "gj_27.png",
        "gj_29.png",
        "gj_31.png",
    },
    {
        "gj_14.png",
        "gj_16.png",
        "gj_18.png",
        "gj_20.png",
        "gj_22.png",
        "gj_24.png",
        "gj_26.png",
        "gj_28.png",
        "gj_30.png",
        "gj_32.png",
    },
}

local stepRes = {--正从资源
    "gj_41.png",
    "gj_42.png",
}

local OfficerHomeLayer = class("OfficerHomeLayer", function()
    return display.newLayer()
end)

--构造函数
function OfficerHomeLayer:ctor(params)
    self.mInMatching = false --是否点击了匹配按钮处于匹配对手状态中

    local parentLayer = ui.newStdLayer()
    self:addChild(parentLayer)
     -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eWage, ResourcetypeSub.eSTA, ResourcetypeSub.eDiamond},
    })
    self:addChild(tempLayer)
    --创建背景
    self.mBgSpr = ui.newSprite("zdcj_06.jpg")
    self.mBgSpr:setPosition(cc.p(320, 568))
    parentLayer:addChild(self.mBgSpr)
    self:getOfficerSystemInfo()
    -- self:initUI()
end

--初始化UI
function OfficerHomeLayer:initUI()
    --创建 顶部资源 规则、返回按钮 标题 中间三个按钮  3连胜标记等
    -- 规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_68.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(42, 1015),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer("规则",
            {
                [1] = TR("1、赛季开始，每胜利一场获得一星，若连胜3次，则可额外获得一星，直到战败连胜消失。"),
                [2] = TR("2、失败掉星，当降到从品【0星】后将不会掉星，即官位不会下降。"),
                [3] = TR("3、每赛季周期为15天，赛季结束时根据当前官位排名发放奖励。"),
                [4] = TR("4、赛季期间每日可领取俸禄一次，根据官位不同俸禄不同。"),
            })
        end,
    })
    self.mBgSpr:addChild(ruleBtn, zorder.ui)
    -- 返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_3.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(598, 1015),
        clickAction = function()
            LayerManager.removeLayer(self)
        end,
    })
    self.mCloseBtn = closeBtn
    self.mBgSpr:addChild(closeBtn, zorder.ui)

    -- local tempParentNodeSize = cc.size(230, 38)
    -- local tempParentNode = ui.newScale9Sprite("c_177.png", tempParentNodeSize)
    -- tempParentNode:setPosition(cc.p(320, 1015))
    -- self.mBgSpr:addChild(tempParentNode, zorder.ui)
    -- local titleLabel = ui.newLabel({
    --     text = TR("官阶挑战赛"),
    --     color = Enums.Color.eGold_D,
    --     size = 26,
    --     x = tempParentNodeSize.width / 2,
    --     y = tempParentNodeSize.height / 2
    -- })
    -- titleLabel:addTo(tempParentNode)

    --创建匹配按钮
    self.mMatchBtn = ui.newButton({
        normalImage = "gj_1.png",
        position = cc.p(320, 606),
        clickAction = function(pSender)
            local function callFunc()
                HttpClient:request({
                    moduleName = "PVPinter",
                    methodName = "FightForMatch",
                    callback = function(response)
                        if not response or response.Status ~= 0 then
                            self:refreshEnemyRole("spr")
                            self.mInMatching = false
                            pSender:setEnabled(true)
                            return
                        end
                        --三部分：
                        --[[
                            PVPinterInfo玩家跨服战信息
                            PVPinterFightLog:战报
                            TargetInfo:匹配对手信息
                            IsWin:是否胜利
                            FightInfo:战斗信息
                            BaseGetGameResourceList:基础掉落
                        --]]
                        local resData = response.Value 
                        --获取匹配对手信息 隐藏匹配按钮 显示对手
                        local enemyRoleInfo = resData.TargetInfo
                        self.mMatchBtn:setVisible(false)
                        self:refreshEnemyRole({
                            heroModelID = enemyRoleInfo.HeadImageId,
                            fashionModelID = enemyRoleInfo.FashionModelId,
                            parent = self.mFigureNode,
                            position = cc.p(490, 0),
                            scale = 0.55,
                            showInfo = true,
                            Name = enemyRoleInfo.Name,
                            Lv = enemyRoleInfo.Lv,
                            FAP = enemyRoleInfo.FAP,
                        })

                        local pkSpr = ui.newSprite("zdjs_06.png")
                        pkSpr:setScale(2.2)
                        pkSpr:setPosition(cc.p(320, 700))
                        self.mBgSpr:addChild(pkSpr, zorder.ui)
                        pkSpr:runAction(cc.Sequence:create( --pk动画
                            cc.ScaleTo:create(0.3, 1.2),
                            cc.DelayTime:create(1),
                            cc.CallFunc:create(function()
                                -- 进入战斗页面
                                -- 战斗页面控制信息
                                local controlParams = Utility.getBattleControl(ModuleSub.ePVPInter)
                                -- 调用战斗页面
                                -- dump(resData.FightInfo, "resData.FightInforesData.FightInfo")
                                LayerManager.addLayer({
                                    name = "ComBattle.BattleLayer",
                                    data = {
                                        data = resData.FightInfo,
                                        skip = controlParams.skip,
                                        trustee = controlParams.trustee,
                                        skill = controlParams.skill,
                                        camera = {enable = false},
                                        map = Utility.getBattleBgFile(ModuleSub.eChallengeArena),
                                        callback = function(retData)
                                            PvpResult.showPvpResultLayer(
                                                ModuleSub.ePVPInter,
                                                resData,
                                                {
                                                    PlayerName = PlayerAttrObj:getPlayerAttrByName("PlayerName"),
                                                    FAP = PlayerAttrObj:getPlayerAttrByName("FAP"),
                                                },
                                                {
                                                    PlayerName = enemyRoleInfo.Name,
                                                    FAP = enemyRoleInfo.FAP,
                                                    PlayerId = enemyRoleInfo.PlayerId,
                                                },
                                                retData.damageRecord,
                                                retData.isskip
                                            )
                                        end
                                    },
                                })
                            end))
                        )
                    end,
                })
            end
            if self.mIsInTruce then
                ui.showFlashView(TR("赛季已结束!"))
                return
            end
            print("开始寻找匹配...")
            if self.mInMatching then --匹配时再次点击无效
                return
            end
            self.mInMatching = true
            pSender:setEnabled(false)
            self:createMatchProcessAnimation(callFunc)

        end,
    })
    self.mMatchBtn:setEnabled(not self.mIsInTruce) --休战状态无法点击
    self.mBgSpr:addChild(self.mMatchBtn, zorder.ui)

    tempParentNodeSize = cc.size(210, 38)
    tempParentNode = ui.newScale9Sprite("c_177.png", tempParentNodeSize)
    tempParentNode:setPosition(cc.p(ui.getImageSize("gj_1.png").width / 2 + 9, -20))
    tempParentNode:setScale(0.7)
    self.mMatchBtn:addChild(tempParentNode, zorder.ui)
    local tipsLabel = ui.newLabel({
        text = TR("消耗5点耐力"),
        color = Enums.Color.eWhite,
        size = 24,
        x = tempParentNodeSize.width / 2,
        y = tempParentNodeSize.height / 2,
    })
    tipsLabel:addTo(tempParentNode)

    --中间三个按钮信息
    local middleBtnPosX, middleBtnPosY, tempSize = 60, 400, ui.getImageSize("tb_1041.png")

    local middleBtnInfos ={
        {
            normalImage = "tb_1041.png",
            position = cc.p(middleBtnPosX, middleBtnPosY),
            clickAction = function(pSender)
                --兑换页面
                local gender = PlayerAttrObj:getPlayerAttrByName("Gender")
                LayerManager.addLayer({
                    name = "officerSystem.OfficerExchangeLayer",
                    data = {officerState = self.mOfficerInfo.State},
                })
            end,
        },
        {
            normalImage = "tb_1027.png",
            position = cc.p(middleBtnPosX + tempSize.width, middleBtnPosY),
            clickAction = function(pSender)
                --排名界面
                LayerManager.addLayer({
                    name = "officerSystem.OfficerRankLayer",
                    cleanUp = false,
                })
            end,
        },
        {
            normalImage = "tb_1040.png",
            position = cc.p(middleBtnPosX + 2 * tempSize.width, middleBtnPosY),
            clickAction = function(pSender)
                --战报页面
                LayerManager.addLayer({
                    name = "officerSystem.OfficerBattleInfoLayer",
                    cleanUp = false,  
                })
            end,
        },
    }
    for idx, info in ipairs(middleBtnInfos) do
        local button = ui.newButton(info)
        self.mBgSpr:addChild(button, zorder.ui)
        --小红点
    end

    --连胜五阿哥提示：
    if self.mOfficerInfo.WinCount > 1 then
        local wagTipsNode = self:createWagTipsNode(self.mBgSpr, cc.p(600, middleBtnPosY + 14), self.mOfficerInfo.WinCount)
    end

    --创建上半部分视图：
    self:createFigureUI()
    --创建下半部分：可刷新
    self:createBottomUI()
end

--创建人物UI
function OfficerHomeLayer:createFigureUI()
    local figureNode = cc.Node:create()
    figureNode:setAnchorPoint(cc.p(0.5, 0.5))
    local figureNodeSize = cc.size(640, 400)
    figureNode:setContentSize(figureNodeSize)
    figureNode:setPosition(cc.p(320, 690))
    self.mBgSpr:addChild(figureNode)
    self.mFigureNode = figureNode

    --创建我方角色人物
    local myRole = Figure.newHero({
        heroModelID = PlayerAttrObj:getPlayerAttrByName("HeadImageId"),
        fashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"),
        parent = figureNode,
        position = cc.p(150, 0),
        scale = 0.55,
    })
    myRole:setLocalZOrder(2)

    --创建匹配人物
    local enemyRole = ui.newSprite("rwzj_18.png")
    enemyRole:setAnchorPoint(cc.p(0.5, 0))
    enemyRole:setPosition(cc.p(490, -10))
    enemyRole:setTag(tag.enemy)
    figureNode:addChild(enemyRole)

    -- local addSpr = ui.newSprite("c_71.png")
    -- addSpr:setPosition(cc.p(ui.getImageSize("rwzj_18.png").width / 2 - 10, ui.getImageSize("rwzj_18.png").height / 2 + 40))
    -- addSpr:addTo(enemyRole)
end

--刷新匹配人物
--[[
    table params:
    {
        heroModelID:模型id
        fashionModelID:时装id
        parent:父节点,
        position:位置
        scale:缩放
    }
    or
    params:
        figureType:spr 剪影人物
--]]
function OfficerHomeLayer:refreshEnemyRole(params)
    self.mFigureNode:removeChildByTag(tag.enemy)
    if type(params) == "string" then
        local enemyRole = ui.newSprite("rwzj_18.png")
        enemyRole:setAnchorPoint(cc.p(0.5, 0))
        enemyRole:setPosition(cc.p(490, -10))
        enemyRole:setTag(tag.enemy)
        self.mFigureNode:addChild(enemyRole)

        -- local addSpr = ui.newSprite("c_71.png")
        -- addSpr:setPosition(cc.p(ui.getImageSize("rwzj_18.png").width / 2 - 10, ui.getImageSize("rwzj_18.png").height / 2 + 40))
        -- addSpr:addTo(enemyRole)
        return
    end
    --创建敌方角色人物
    local enemyRole = Figure.newHero(params)
    enemyRole:setTag(tag.enemy)
    if params.showInfo then
        -- 创建name lv fap
        local tempSize = cc.size(211, 55)
        local tempSpr = ui.newSprite("lts_06.png")
        tempSpr:setPosition(cc.p(480, 500))
        self.mBgSpr:addChild(tempSpr, zorder.ui, tag.enemyRoleInfo)
        local nameLvLabel = ui.newLabel({
            text = TR("%s级 %s", params.Lv, params.Name),--Utility.getColorValue(Utility.getColorLvByModelId(params.heroModelID), 4)
            color = Enums.Color.eGreen_D,
            size = 24,
            anchorPoint = cc.p(0.5, 1),
            align = TEXT_ALIGNMENT_CENTER,
            x = tempSize.width / 2,
            y = tempSize.height - 1,
        })
        tempSpr:addChild(nameLvLabel)
        local fapLabel = ui.newLabel({
            text = TR("战力: %s", Utility.numberWithUnit(params.FAP)),
            color = Enums.Color.eWhite,
            size = 24,
            anchorPoint = cc.p(0.5, 0),
            align = TEXT_ALIGNMENT_CENTER,
            x = tempSize.width / 2,
            y = 0,
        })
        tempSpr:addChild(fapLabel)
    else
        self.mBgSpr:removeChildByTag(tag.enemyRoleInfo)
    end
end

--创建底部UI
function OfficerHomeLayer:createBottomUI()
    local roleInfoViewSize = cc.size(623, 347)
    local roleInfoViewNode = cc.Scale9Sprite:create("szdb_33.png")
    roleInfoViewNode:setContentSize(roleInfoViewSize)
    roleInfoViewNode:setAnchorPoint(cc.p(0.5, 1))
    roleInfoViewNode:setPosition(cc.p(320, 350))
    self.mBgSpr:addChild(roleInfoViewNode, zorder.ui)
    --创建官阶
    local officerNode = self:createOfficerNode(self.mOfficerInfo.Step, self.mOfficerInfo.State)
    officerNode:setScale(1.2)
    officerNode:setPosition(cc.p(roleInfoViewSize.width / 2, 300))
    roleInfoViewNode:addChild(officerNode)

    --创建赛季信息
    local tempBgSpr = ui.newScale9Sprite("c_43.png", cc.size(591, 78))
    tempBgSpr:setAnchorPoint(cc.p(0.5, 1))
    tempBgSpr:setPosition(cc.p(roleInfoViewSize.width / 2, 260))
    tempBgSpr:addTo(roleInfoViewNode)
    --创建星星
    local perStepStars = PvpinterStateRelation.items[self.mOfficerInfo.State][0].perStepStars
    if perStepStars > 0 then --最高阶没有星星
        local starNode = self:createStarsPlugin(PvpinterStateRelation.items[self.mOfficerInfo.State][0].perStepStars, self.mOfficerInfo.Star)
        starNode:setAnchorPoint(cc.p(0.5, 0.5))
        starNode:setPosition(cc.p(295.5, 55))
        starNode:addTo(tempBgSpr)
    else
        local rateLabel = ui.newLabel({
            text = TR("当前积分:%s", self.mOfficerInfo.Rate),
            size = 28,
            color = Enums.Color.eLabelText,
            x = 295.5,
            y = 55
        })
        tempBgSpr:addChild(rateLabel)
    end
    --赛季结束时间
    local seasonIntroLabel = ui.newLabel({
        text = TR("赛季结束时间:"),
        color = Enums.Color.eLabelText,
        size = 28,
        anchorPoint = cc.p(0, 0.5),
    })
    tempBgSpr:addChild(seasonIntroLabel)
    if self.mIsInTruce then
        seasonIntroLabel:setAnchorPoint(cc.p(cc.p(0.5, 0.5)))
        seasonIntroLabel:setPositionX(295.5)
        seasonIntroLabel:setString(TR("%s赛季已结束!", Enums.Color.eLabelTextH))
    else
        local seasonIntroLabelSize = seasonIntroLabel:getContentSize()
        local seasonTimeLabel = ui.newLabel({
            text = TR("%s%s", Enums.Color.eGreenH, MqTime.formatAsDay(self.mSeasonTime)), --赛季倒计时时间
            size = 28,
            anchorPoint = cc.p(0., 0.5),
            x = seasonIntroLabelSize.width,
            y = seasonIntroLabelSize.height / 2,
        })
        seasonTimeLabel:addTo(seasonIntroLabel)
        seasonIntroLabel:setPosition(cc.p(295.5 - (seasonIntroLabelSize.width + seasonTimeLabel:getContentSize().width) / 2, 20))

        Utility.schedule(seasonTimeLabel, function()
            if self.mSeasonTime > 0 then
                self.mSeasonTime = self.mSeasonTime - 1
                seasonTimeLabel:setString(TR("%s%s", Enums.Color.eGreenH, MqTime.formatAsDay(self.mSeasonTime)))
            else
                --停止调度 执行赛季结束应有的表现操作
                seasonTimeLabel:stopAllActions()
                -- todo
            end
        end, 1)
    end

    --创建宝箱
    local tempArr, tempArr2, maxValue = clone(PvpinterRewardBoxModel.items[self.mOfficerInfo.State]), {}, table.maxn(PvpinterRewardBoxModel.items[self.mOfficerInfo.State])
    for i, v in pairs(tempArr) do
        table.insert(tempArr2, v)
    end
    table.sort(tempArr2, function(a, b)
        return a.num < b.num
    end)
    for i, v in ipairs(tempArr2) do
        if v.num >= self.mOfficerInfo.FightCount then
            maxValue = v.num
            break
        end
    end

    local boxNodeOne = self:createBoxProgressBar({
        barImage = "gj_8.png",
        bgImage = "gj_7.png",
        normalImage = "tb_4003.png",
        openedImage = "tb_4004.png",
        barTitlePng = "gj_5.png",
        curValue = self.mOfficerInfo.FightCount,
        maxValue = maxValue,
        boxType = boxType.daily,
        eventName = boxEvent.daily,
        fightCount = self.mOfficerInfo.FightCount,
    })
    boxNodeOne:setPosition(cc.p(66, 110))
    roleInfoViewNode:addChild(boxNodeOne)
    
    tempArr, tempArr2, maxValue = clone(PvpinterSeasonWinRewardModel.items), {}, table.maxn(PvpinterSeasonWinRewardModel.items)
    for i, v in pairs(tempArr) do
        table.insert(tempArr2, v)
    end
    table.sort(tempArr2, function(a, b)
        return a.winNum < b.winNum
    end)
    for i, v in ipairs(tempArr2) do
        if v.winNum >= self.mOfficerInfo.TotalWinCount then
            maxValue = v.winNum
            break
        end
    end

    local boxNodeTwo = self:createBoxProgressBar({
        barImage = "gj_8.png",
        bgImage = "gj_7.png",
        normalImage = "tb_4001.png",
        openedImage = "tb_4002.png",
        barTitlePng = "gj_6.png",
        curValue = self.mOfficerInfo.TotalWinCount,
        maxValue = maxValue,
        boxType = boxType.season,
        eventName = boxEvent.season,
        fightCount = self.mOfficerInfo.TotalWinCount,
    })
    boxNodeTwo:setPosition(cc.p(360, 110))
    roleInfoViewNode:addChild(boxNodeTwo)
end

--创建官阶
--[[
    params:
        step:附
        state:品
    return:retNode
--]]
function OfficerHomeLayer:createOfficerNode(step, state)
    local retNode = cc.Node:create()
    retNode:setAnchorPoint(cc.p(0.5, 0.5))
    local gender = PlayerAttrObj:getPlayerAttrByName("Gender") --性别
    local sprOne = ui.newSprite(stepRes[step] or stepRes[1])
    sprOne:setAnchorPoint(cc.p(0, 0.5))
    local sprSize = sprOne:getContentSize()
    local sprTwo = ui.newSprite(officerRankRes[state])
    sprTwo:setAnchorPoint(cc.p(0, 0.5))
    sprTwo:setPosition(cc.p(sprSize.width, sprSize.height / 2 + 3))
    sprOne:addChild(sprTwo)
    local sprThree = ui.newSprite("gj_9.png")
    sprThree:setAnchorPoint(cc.p(0, 0.5))
    sprThree:setPosition(cc.p(sprTwo:getContentSize().width, sprSize.height / 2))
    sprTwo:addChild(sprThree)
    local sprFour = ui.newSprite(officerNameRes[gender + 1][state])
    sprFour:setAnchorPoint(cc.p(0, 0.5))
    sprFour:setPosition(cc.p(sprThree:getContentSize().width, sprThree:getContentSize().height / 2))
    sprThree:addChild(sprFour)
    local sprFive = ui.newSprite("c_53.png")
    sprFive:setAnchorPoint(cc.p(1, 0.5))
    sprFive:setPosition(cc.p(-10, sprSize.height / 2))
    if state == 1 or state == 10 then
        sprOne:setOpacity(0)
        sprOne:setCascadeOpacityEnabled(false)
        sprTwo:addChild(sprFive)
        local width = sprTwo:getContentSize().width + sprThree:getContentSize().width + sprFour:getContentSize().width
        + sprFive:getContentSize().width * 2 + 20
        retNode:setContentSize(cc.size(width, sprSize.height))
        sprOne:setPosition(cc.p(10, sprSize.height / 2))
    else
        sprOne:addChild(sprFive)
        local width = sprSize.width + sprTwo:getContentSize().width + sprThree:getContentSize().width + sprFour:getContentSize().width
        + sprFive:getContentSize().width * 2 + 20
        retNode:setContentSize(cc.size(width, sprSize.height))
        sprOne:setPosition(cc.p(sprFive:getContentSize().width + 10, sprSize.height / 2))
    end
    sprFive:setFlippedX(true)
    local sprSix = ui.newSprite("c_53.png")
    sprSix:setAnchorPoint(cc.p(0, 0.5))
    sprSix:setPosition(cc.p(sprFour:getContentSize().width + 10, sprSize.height / 2))
    sprFour:addChild(sprSix)
    retNode:addChild(sprOne)
    -- local s = ui.newScale9Sprite("c_15.png", retNode:getContentSize())
    -- s:setAnchorPoint(cc.p(0, 0))
    -- retNode:addChild(s, -1)
    -- s:setPosition(cc.p(0, 0))
    return retNode
end

--创建星星node
--[[
    params:
        totalNum:总的星星个数
        lightNum:点亮的星星个数
    return:
        retNode
--]]
function OfficerHomeLayer:createStarsPlugin(totalNum, lightNum)
    local starSize = ui.getImageSize("c_38.png")
    local retSize = cc.size(starSize.width * 1.8 * totalNum, starSize.height * 1.2)
    local retNode = cc.Node:create()
    -- local c = ui.newScale9Sprite("c_15.png", retSize)
    -- c:setPosition(cc.p(retSize.width / 2, retSize.height / 2))
    -- retNode:addChild(c, -1)
    retNode:setContentSize(retSize)
    for i = 1, totalNum do
        local starSpr = ui.newSprite(i <= lightNum and "c_38.png" or "c_83.png")
        starSpr:setPosition(cc.p(starSize.width + (i - 1) * 1.8 * starSize.width, retSize.height / 2))
        retNode:addChild(starSpr)
    end
    function retNode:hideStars() --隐藏星星
        if totalNum <= 0 then
            return
        end
        for i, v in ipairs(self:getChildren()) do
            v:setTexture("c_83.png")
        end
    end
    function retNode:showStars(nowLightNum) --显示星星
        if totalNum <= 0 then
            return
        end
        local childrenPool = self:getChildren() --子节点池
        if lightNum < nowLightNum then
            for i = lightNum + 1, math.min(nowLightNum, #childrenPool) do
                childrenPool[i]:setTexture("c_38.png")
                childrenPool[i]:setScale(3)
                childrenPool[i]:runAction(cc.ScaleTo:create(0.3, 1))
            end
        else
            self:hideStars()
            for i = 1, nowLightNum do
                childrenPool[i]:setTexture("c_38.png")
                childrenPool[i]:setScale(3)
                childrenPool[i]:runAction(cc.ScaleTo:create(0.3, 1))
            end
        end
    end
    return retNode
end


--创建五阿哥提示UI
--[[
    params:
        parentNode:父节点
        pos:位置
        winCount:连胜场次
    return:
        retNode
--]]
function OfficerHomeLayer:createWagTipsNode(parentNode, pos, winCount)
    --创建五阿哥
    local retNode = cc.Sprite:create("bj_19.png")
    retNode:setFlippedX(true)
    retNode:setScale(0.37)
    retNode:setPosition(pos)
    parentNode:addChild(retNode, zorder.tips)
    --创建气泡
    local tipsSize = ui.getImageSize("c_202.png")
    tipsContentNode = cc.Sprite:create("c_202.png")
    tipsContentNode:setFlippedX(true)
    tipsContentNode:setPosition(cc.p(-ui.getImageSize("c_202.png").width / 2 + 10, ui.getImageSize("bj_19.png").height / 2 - 20))
    tipsContentNode:setScale(3)
    retNode:addChild(tipsContentNode)
    --创建连胜提示
    local winCountLabel = ui.newNumberLabel({
        text = TR("%s", winCount),
        imgFile = "c_112.png",
        charCount = 11,
    })

    local winCountSpr = ui.newSprite("gj_3.png")
    winCountSpr:setScale(0.9)
    winCountSpr:setAnchorPoint(cc.p(1, 0.5))
    winCountSpr:setPosition(cc.p(tipsSize.width - (winCount < 10 and 30 or 24), tipsSize.height / 2))
    tipsContentNode:addChild(winCountSpr)

    local tempSize = winCountSpr:getContentSize()
    winCountLabel:setScale(0.8)
    winCountLabel:setAnchorPoint(cc.p(1, 0.5))
    winCountLabel:setPosition(cc.p(0, tempSize.height / 2))
    winCountLabel:addTo(winCountSpr)

    return retNode
end

--创建宝箱进度条:有3个成员变量  bar boxBtn mBarLabel
--[[
    table params:
    {
        barImage:进度条资源
        bgImage :背景资源
        normalImage:宝箱关闭状态资源
        openedImage:宝箱开启状态资源
        barTitlePng:进度条标题
        curValue:进度条当前值
        maxValue:进度条最大值
        boxType:宝箱类型枚举
        eventName:宝箱事件
        fightCount:场次数
    }
    return:retNode
--]]
function OfficerHomeLayer:createBoxProgressBar(params)
    local barSize = ui.getImageSize(params.barImage)
    local retNode = cc.Node:create()
    retNode:setContentSize(barSize)
    --创建进度条sp
    local barSpr = ui.newSprite(params.barImage)
    local progressBar = require("common.ProgressBar").new({
        bgImage = params.bgImage,
        barImage = params.barImage,
        currValue = params.curValue,
        maxValue = params.maxValue
    })
    progressBar:setAnchorPoint(cc.p(0.5, 0.5))
    progressBar:setPosition(cc.p(barSize.width / 2, barSize.height / 2))
    retNode:addChild(progressBar)
    retNode.bar = progressBar
    --创建进度条标题
    local titleSpr = cc.Sprite:create(params.barTitlePng)
    titleSpr:setAnchorPoint(cc.p(0.5, 1))
    titleSpr:setPosition(cc.p(barSize.width / 2, barSize.height - 5))
    retNode:addChild(titleSpr, zorder.ui)
    --创建标签
    local word = {"挑战", "胜利"}
    local barLabel = ui.newLabel({
        text = TR("%s%d/%d", word[params.boxType], params.curValue, params.maxValue),
        color = Enums.Color.eWhite,
        size = 24,
        anchorPoint = cc.p(0.5, 0),
        x = barSize.width / 2,
        y = 5
    })
    retNode:addChild(barLabel, zorder.ui)
    retNode.mBarLabel = barLabel
    --创建宝箱
    local boxBtn = ui.newButton({
        normalImage = params.normalImage,
        clickAction = function(pSender)
            --进入宝箱领取奖励页面
            LayerManager.addLayer({
                name = "officerSystem.OfficerRewardBoxLayer",
                data = {
                    layerType = params.boxType,
                    state = self.mOfficerInfo.State,
                    boxStatus = (params.boxType == boxType.daily) and self.mOfficerInfo.ChallengeBox or self.mOfficerInfo.SeasonWinBox,
                    eventName = params.eventName,
                    fightCount = params.fightCount,
                },
                cleanUp = false,
            })
        end,    
    })
    boxBtn:setPosition(cc.p(8, barSize.height - 20))
    retNode:addChild(boxBtn)
    retNode.boxBtn = boxBtn

    --注册事件
    local function boxStatusSet(node, status)
        if node and not tolua.isnull(node) then
            if status ~= 1 then
                node:stopAllActions()
                if node.flashNode and not tolua.isnull(node.flashNode) then
                    node.flashNode:removeFromParent()
                end
            end
            if status == 0 then
                node:loadTextures(params.normalImage, params.normalImage)
            elseif status == 1 then
                node:loadTextures(params.normalImage, params.normalImage)
                ui.setWaveAnimation(node)
            elseif status == 2 then
                node:loadTextures(params.openedImage, params.openedImage)
            end
        end
    end
    Notification:registerAutoObserver(boxBtn, boxStatusSet, params.eventName)

    local flag0Time, flag1Time = 0, 0
    for i, val in pairs(params.boxType == boxType.daily and self.mOfficerInfo.ChallengeBox or self.mOfficerInfo.SeasonWinBox) do
        if val == 1 then
            flag1Time = flag1Time + 1
        elseif val == 0 then
            flag0Time = flag0Time + 1
        end
    end
    if flag1Time > 0 then
        Notification:postNotification(params.eventName, 1) --可领取
    elseif flag0Time > 0 then
        Notification:postNotification(params.eventName, 0) --不可领取
    else
        Notification:postNotification(params.eventName, 2) --已领取
    end
    
    return retNode
end

--创建匹配动画
--[[
    params:
        callFunc:回调函数
--]]
function OfficerHomeLayer:createMatchProcessAnimation(callFunc)
    math.randomseed(os.time())
    local actionArr, fashionModelId = {}, {}
    local heroModelId = {12010003, 12010006}
    for id, val in pairs(FashionModel.items) do
        table.insert(fashionModelId, id)
    end
    for time = 1, 10 do
        local i = math.random(12)
        local tempData = {
            heroModelID = heroModelId[i % 2 + 1],
            fashionModelID = i <= FashionModel.items_count and fashionModelId[i] or nil,
            parent = self.mFigureNode,
            position = cc.p(490, 15),
            scale = 0.55,
        }
        table.insert(actionArr, cc.CallFunc:create(function() self:refreshEnemyRole(tempData) end))
        table.insert(actionArr, cc.DelayTime:create(0.1))
    end
    table.insert(actionArr, cc.CallFunc:create(callFunc))
    self.mFigureNode:runAction(cc.Sequence:create(actionArr))
end

--获取官阶系统信息
function OfficerHomeLayer:getOfficerSystemInfo()
    HttpClient:request({
        moduleName = "PVPinter",
        methodName = "GetPVPInterInfo",
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            local returnData = response.Value
            --判断是否开放
            if not returnData.IsOpen then
                ui.showFlashView(TR("暂未开放"))
                return
            end
            self.mIsInTruce = returnData.IsInTruce --是处于休战状态中
            self.mOfficerInfo = returnData.PVPinterInfo
            self.mOfficerSeasonInfo = returnData.PVPinterSeasonInfo --跨服战赛季信息
            self.mSeasonTime = self.mOfficerSeasonInfo.ClearDate - Player:getCurrentTime()
            self:initUI()
        end,
    })
end

return OfficerHomeLayer