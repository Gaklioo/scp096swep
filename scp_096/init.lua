AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_shared.lua")
include("sh_shared.lua")

function SWEP:PrimaryAttack()
    local ply = self:GetOwner()

    local ent = ply:GetEyeTrace().Entity

    if not IsValid(ent) then return end
    if not ent:IsPlayer() then return end

    if not self.MarkedPlayers[ent:SteamID()] then return end

    local entPos = ent:GetPos()

    if ply:GetPos():Distance2DSqr(entPos) <= 10000 then
        ent:Kill()
    end
end

function SWEP:Think()
    for _, ply in player.Iterator() do
        local ent = ply:GetEyeTrace().Entity
        if self.MarkedPlayers[ply:SteamID()] then return end

        if IsValid(ent) and ent == self:GetOwner() and ent:Alive() then
            self:AddDeathTarget(ply:SteamID())
        end
    end
end

function SWEP:AddDeathTarget(ply)
    if not self.MarkedPlayers[ply] then
        self.MarkedPlayers[ply] = true

        self:addHook(ply)
        self:SendPlayer()
    end
end

util.AddNetworkString("SCP_096_SendList")
function SWEP:SendPlayer()
    local ply = self:GetOwner()
    local tablestr = util.TableToJSON(self.MarkedPlayers)
    
    net.Start("SCP_096_SendList")
    net.WriteString(tablestr)
    net.Send(ply)
end

function SWEP:addHook(ply)
    local hookName = "SCP_096" .. ply
    hook.Add("PlayerDeath", hookName, function(victim)
        victimIndex = victim:SteamID()
        if self.MarkedPlayers[victimIndex] then
            self.MarkedPlayers[victimIndex] = false 
            hook.Remove("PlayerDeath", hookName)
            timer.Simple(0.1, function()
                self:SendPlayer()
            end)
        end
    end)
end