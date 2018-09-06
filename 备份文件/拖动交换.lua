--注册拖动事件
function LayerObj:registerMoveEvent(layout)
    local posOffset = cc.p(0, 0)
    layout:addTouchEventListener(function(pSender, eventType)
        if eventType == ccui.TouchEventType.began then
            pSender:setLocalZOrder(1024)
            local touchPos = pSender:getTouchBeganPosition()
            touchPos = self.mTopBgSpr:convertToNodeSpace(touchPos)
            local centerPos = self.mNodeInfo[pSender.posId][pSender.locationId].pos
            --获取偏移量：拖动点到中心位置的距离
            posOffset.x, posOffset.y = touchPos.x - centerPos.x, touchPos.y - centerPos.y
            return true
        elseif eventType == ccui.TouchEventType.moved then
            local touchPos = pSender:getTouchMovePosition()
            touchPos = self.mTopBgSpr:convertToNodeSpace(touchPos)
            pSender:setPosition(cc.p(touchPos.x - posOffset.x, touchPos.y - posOffset.y))
        else
            -- local touchPos = pSender:getTouchEndPosition()
            -- touchPos = self.mTopBgSpr:convertToNodeSpace(touchPos)
            -- local centerPos = cc.p(touchPos.x - posOffset.x, touchPos.y - posOffset.y)
            --判断移动
            for tempPosId = 1, 3 do
                for tempLocationId = 1, GuildWarfareConfig.items[1].armyMaxNum do
                    if not (tempPosId == pSender.posId and tempLocationId == pSender.locationId)
                        and cc.rectContainsPoint(self.mNodeInfo[tempPosId][tempLocationId].node:getBoundingBox(), cc.p(pSender:getPosition())) then
                        self:changeNode(pSender.posId, pSender.locationId, tempPosId, tempLocationId)
                        return
                    end
                end
            end
            --复原
            self:moveTo(pSender, self.mNodeInfo[pSender.posId][pSender.locationId].pos)
            pSender:setLocalZOrder(1)
        end
    end)
    layout:setTouchEnabled(self.mCanSetTeam) --只有可布阵时才可拖动
end