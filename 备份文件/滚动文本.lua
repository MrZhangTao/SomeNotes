DIYUiCallback = function(layerObj, bgSpr, bgSize)
    layerObj.mMsgLabel:removeFromParent()
    local tempBgSpr = ui.newScale9Sprite("sjzt_34.png", cc.size(500, 255))
    tempBgSpr:setAnchorPoint(cc.p(0.5, 0))
    tempBgSpr:setPosition(cc.p(bgSize.width / 2, 25))
    bgSpr:addChild(tempBgSpr)

    --创建遮罩
    local viewSize = cc.size(500, 240)
    local completeView = cc.ClippingNode:create()
    completeView:setContentSize(viewSize)
    completeView:setAnchorPoint(cc.p(0.5, 0.5))
    completeView:setPosition(cc.p(viewSize.width / 2, viewSize.height / 2 + 4))
    tempBgSpr:addChild(completeView)

    --创建模板
    local stencilNode = ui.newScale9Sprite("c_234.png", viewSize)
    stencilNode:setPosition(cc.p(viewSize.width / 2, viewSize.height / 2))
    completeView:setStencil(stencilNode)

    --初始化数据
    local itemSize = cc.size(viewSize.width, 48)
    completeView._children = {}
    completeView._maxCount = 6 -- 5+1

    Utility.schedule(completeView, function()
        if #completeView._children < completeView._maxCount then
            --先创建足够的label
            local label = self:createOneInfoLabel()
            label:setDimensions(cc.size(itemSize.width - 30, 0))
            label:setAnchorPoint(cc.p(0, 0.5))
            table.insert(completeView._children, label)
            local posy = viewSize.height - itemSize.height * (#completeView._children - 0.5)
            label:setPosition(cc.p(10, posy))
            completeView:addChild(label)

            if posy < 0 then --保证全部创建完成后最后一个label是显示在屏幕上的
                for i, label in ipairs(completeView._children) do
                    if label then
                        label:runAction(cc.MoveBy:create(1, cc.p(0, itemSize.height)))
                    end
                end
            end
        else
            --全部向上移动一个单位
            local lastOneLabel = completeView._children[1]
            for i = 1, completeView._maxCount - 1 do
                completeView._children[i] = completeView._children[i + 1]
            end
            completeView._children[completeView._maxCount] = lastOneLabel
            --获取更新_children之前最后一个label的位置
            local x, y = completeView._children[completeView._maxCount - 1]:getPosition()
            lastOneLabel:setPosition(cc.p(x, y - itemSize.height))

            --更新内容
            local text = self:getOneLabelInfo()
            lastOneLabel:setString(text)

            for i, label in ipairs(completeView._children) do
                if label then
                    label:runAction(cc.MoveBy:create(1, cc.p(0, itemSize.height)))
                end
            end 
        end
    end, 2)
end